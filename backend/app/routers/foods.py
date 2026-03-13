from difflib import SequenceMatcher
import re
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session
from typing import List, Optional

from app.config import external_food_apis_enabled
from app.deps import get_current_user, get_db
from app.external_food_apis import (
    debug_spoonacular,
    fetch_open_food_facts_barcode,
    fetch_open_food_facts_search,
    fetch_spoonacular_foods,
    fetch_spoonacular_recipe_foods,
    fetch_usda_foods,
)
from app.food_store import upsert_foods
from app.models import Food, User
from app.schemas import FoodOut


router = APIRouter(prefix="/foods", tags=["foods"])
SYNONYM_TERMS = {
    "beef": ["ground beef", "steak", "sirloin"],
    "chicken": ["chicken breast", "chicken thigh"],
    "rice": ["white rice", "brown rice", "basmati"],
    "egg": ["eggs", "boiled egg"],
    "potato": ["sweet potato", "baked potato"],
    "yogurt": ["greek yogurt"],
    "milk": ["whole milk", "2% milk"],
    "fish": ["salmon", "tuna"],
}


def _query_local_foods(db: Session, term: str, limit: int = 25, source: Optional[str] = None) -> list[Food]:
    query = db.query(Food).filter(or_(Food.name.ilike(f"%{term}%"), Food.brand.ilike(f"%{term}%")))
    if source:
        query = query.filter(Food.source == source)
    return query.order_by(Food.name.asc()).limit(limit).all()


def _normalize(text: str) -> str:
    return re.sub(r"[^a-z0-9 ]+", " ", text.lower()).strip()


def _tokenize(text: str) -> List[str]:
    return [token for token in _normalize(text).split() if token]


def _expand_terms(query: str) -> List[str]:
    terms = [_normalize(query)]
    tokens = [token for token in re.split(r"[^a-zA-Z0-9]+", query.lower()) if token]
    for token in tokens:
        terms.append(token)
        terms.extend(SYNONYM_TERMS.get(token, []))
    unique = []
    seen = set()
    for term in terms:
        term = term.strip()
        if not term or term in seen:
            continue
        seen.add(term)
        unique.append(term)
    return unique


def _merge_unique_foods(foods: List[Food]) -> List[Food]:
    merged = []
    seen_ids = set()
    for item in foods:
        if item.id in seen_ids:
            continue
        seen_ids.add(item.id)
        merged.append(item)
    return merged


def _fuzzy_rank(query: str, foods: List[Food], limit: int = 30) -> List[Food]:
    query_normalized = _normalize(query)
    query_tokens = _tokenize(query)
    scored = []
    for food in foods:
        name_normalized = _normalize(food.name or "")
        brand_normalized = _normalize(food.brand or "")
        combined = f"{brand_normalized} {name_normalized}".strip()
        if not combined:
            continue

        name_tokens = set(_tokenize(name_normalized))
        brand_tokens = set(_tokenize(brand_normalized))

        exact_name_matches = 0
        prefix_name_matches = 0
        loose_name_matches = 0
        brand_matches = 0
        for token in query_tokens:
            if token in name_tokens:
                exact_name_matches += 1
            elif any(name_token.startswith(token) for name_token in name_tokens):
                prefix_name_matches += 1
            elif token in name_normalized:
                loose_name_matches += 1

            if token in brand_tokens:
                brand_matches += 1

        score = 0.0
        if query_normalized and query_normalized in name_normalized:
            score += 12.0
        elif query_normalized and query_normalized in combined:
            score += 7.0

        if query_normalized and name_normalized.startswith(query_normalized):
            score += 6.0

        score += exact_name_matches * 4.5
        score += prefix_name_matches * 2.2
        score += loose_name_matches * 0.7
        score += brand_matches * 1.0

        # Phrase similarity is useful as a weak tiebreaker.
        score += SequenceMatcher(None, query_normalized, name_normalized).ratio() * 2.0
        score += SequenceMatcher(None, query_normalized, combined).ratio() * 0.8

        # If query has multiple tokens, heavily de-prioritize brand-only matches.
        if len(query_tokens) >= 2 and exact_name_matches == 0 and prefix_name_matches == 0 and loose_name_matches == 0:
            score -= 4.0

        # Avoid returning completely unrelated rows.
        if score > 0.2:
            scored.append((score, food))

    scored.sort(key=lambda row: row[0], reverse=True)
    return [food for _, food in scored[:limit]]


@router.get("/search", response_model=list[FoodOut])
def search_foods(
    q: str,
    provider: Optional[str] = None,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user),
):
    query = q.strip()
    if not query:
        return []

    provider_normalized = (provider or "all").strip().lower()
    spoon_only = provider_normalized in {"spoon", "spoonacular"}
    spoon_recipe_only = provider_normalized in {"spoon_recipe", "spoonacular_recipe", "spoon-recipes"}
    usda_only = provider_normalized == "usda"
    off_only = provider_normalized in {"off", "open_food_facts"}
    local_only = provider_normalized == "local"

    terms = _expand_terms(query)
    local_candidates = []
    local_source = "SPOONACULAR" if (spoon_only or spoon_recipe_only) else ("USDA" if usda_only else ("OPEN_FOOD_FACTS" if off_only else None))
    for term in terms:
        local_candidates.extend(_query_local_foods(db, term, limit=18, source=local_source))
    foods = _merge_unique_foods(local_candidates)
    if foods and not (spoon_only or spoon_recipe_only):
        foods = _fuzzy_rank(query, foods, limit=35)

    if external_food_apis_enabled() and len(query) >= 2 and not local_only:
        try:
            external_results = []
            if spoon_recipe_only:
                for term in terms[:5]:
                    external_results.extend(fetch_spoonacular_recipe_foods(term, limit=8))
            elif spoon_only:
                for term in terms[:5]:
                    external_results.extend(fetch_spoonacular_foods(term, limit=8))
            elif usda_only:
                for term in terms[:5]:
                    external_results.extend(fetch_usda_foods(term, limit=10))
            elif off_only:
                for term in terms[:5]:
                    external_results.extend(fetch_open_food_facts_search(term, limit=10))
            else:
                for term in terms[:5]:
                    external_results.extend(fetch_usda_foods(term, limit=7))
                    external_results.extend(fetch_open_food_facts_search(term, limit=7))
                for term in terms[:3]:
                    external_results.extend(fetch_spoonacular_foods(term, limit=5))
            if external_results:
                upsert_foods(db, external_results)
                local_candidates = []
                for term in terms:
                    local_candidates.extend(_query_local_foods(db, term, limit=20, source=local_source))
                foods = _merge_unique_foods(local_candidates)
                if not (spoon_only or spoon_recipe_only):
                    foods = _fuzzy_rank(query, foods, limit=40)

                # For spoon-specific providers, return latest spoon entries directly if term match is sparse.
                if (spoon_only or spoon_recipe_only) and not foods:
                    foods = (
                        db.query(Food)
                        .filter(Food.source == "SPOONACULAR")
                        .order_by(Food.id.desc())
                        .limit(40)
                        .all()
                    )
        except Exception:
            # Keep local search working even when external providers fail.
            pass

    if not foods:
        query_all = db.query(Food)
        if local_source:
            query_all = query_all.filter(Food.source == local_source)
        foods = query_all.order_by(Food.name.asc()).limit(25).all()

    return [FoodOut.model_validate(food) for food in foods]


@router.get("/barcode/{barcode}", response_model=FoodOut)
def find_by_barcode(
    barcode: str,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user),
):
    food = db.query(Food).filter(Food.barcode == barcode).first()
    if not food:
        if external_food_apis_enabled():
            off_food = fetch_open_food_facts_barcode(barcode)
            if off_food:
                upsert_foods(db, [off_food])
                food = db.query(Food).filter(Food.barcode == barcode).first()
    if not food:
        raise HTTPException(status_code=404, detail="Barcode not found")
    return FoodOut.model_validate(food)


@router.get("/debug/spoon")
def spoon_debug(
    q: str = "pizza",
    _: User = Depends(get_current_user),
):
    return debug_spoonacular(q, limit=5)
