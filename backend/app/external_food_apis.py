from __future__ import annotations

from functools import lru_cache
from typing import Dict, List, Optional, Tuple

import httpx

from app.config import get_spoonacular_api_key, get_usda_api_key


def _to_float(value, default: float = 0.0) -> float:
    try:
        if value is None:
            return default
        return float(value)
    except (TypeError, ValueError):
        return default


NUTRIENT_KEYS = {
    "calories": "calories_per_100g",
    "protein": "protein_g_per_100g",
    "carbs": "carbs_g_per_100g",
    "fat": "fat_g_per_100g",
    "fiber": "fiber_g_per_100g",
    "sugar": "sugar_g_per_100g",
    "added_sugar": "added_sugar_g_per_100g",
    "net_carbs": "net_carbs_g_per_100g",
    "saturated_fat": "saturated_fat_g_per_100g",
    "trans_fat": "trans_fat_g_per_100g",
    "monounsaturated_fat": "monounsaturated_fat_g_per_100g",
    "polyunsaturated_fat": "polyunsaturated_fat_g_per_100g",
    "cholesterol_mg": "cholesterol_mg_per_100g",
    "sodium_mg": "sodium_mg_per_100g",
    "potassium_mg": "potassium_mg_per_100g",
    "magnesium_mg": "magnesium_mg_per_100g",
    "phosphorus_mg": "phosphorus_mg_per_100g",
    "zinc_mg": "zinc_mg_per_100g",
    "iron_mg": "iron_mg_per_100g",
    "calcium_mg": "calcium_mg_per_100g",
    "vitamin_a_mcg": "vitamin_a_mcg_per_100g",
    "vitamin_c_mg": "vitamin_c_mg_per_100g",
    "vitamin_d_mcg": "vitamin_d_mcg_per_100g",
    "vitamin_b12_mcg": "vitamin_b12_mcg_per_100g",
    "folate_mcg": "folate_mcg_per_100g",
}


def _empty_nutrients() -> Dict[str, float]:
    return {key: 0.0 for key in NUTRIENT_KEYS}


def _food_payload(
    *,
    name: str,
    brand: Optional[str],
    barcode: Optional[str],
    source: str,
    serving_description: str,
    nutrients: Dict[str, float],
) -> Dict:
    payload = {
        "name": name,
        "brand": brand,
        "barcode": barcode,
        "source": source,
        "serving_description": serving_description,
    }
    for nutrient_key, payload_key in NUTRIENT_KEYS.items():
        payload[payload_key] = nutrients.get(nutrient_key, 0.0)
    return payload


@lru_cache(maxsize=256)
def fetch_usda_foods(query: str, limit: int = 12) -> List[Dict]:
    usda_api_key = get_usda_api_key()
    if not usda_api_key:
        return []

    try:
        with httpx.Client(timeout=8.0) as client:
            response = client.post(
                "https://api.nal.usda.gov/fdc/v1/foods/search",
                params={"api_key": usda_api_key},
                json={
                    "query": query,
                    "pageSize": limit,
                    "dataType": ["Foundation", "SR Legacy", "Branded"],
                },
            )
            response.raise_for_status()
            payload = response.json()
    except Exception:
        return []

    items = payload.get("foods", [])
    results: List[Dict] = []
    for item in items:
        nutrients = _usda_nutrient_map(item.get("foodNutrients", []))
        upc = item.get("gtinUpc")
        results.append(
            _food_payload(
                name=item.get("description") or "Unknown Food",
                brand=item.get("brandOwner") or item.get("brandName"),
                barcode=str(upc) if upc else None,
                source="USDA",
                serving_description="100 g",
                nutrients=nutrients,
            )
        )
    return results


def _usda_nutrient_map(food_nutrients: List[Dict]) -> Dict[str, float]:
    mapped = _empty_nutrients()

    for nutrient in food_nutrients:
        name = str(nutrient.get("nutrientName", "")).lower()
        value = _to_float(nutrient.get("value"))
        if "energy" in name and mapped["calories"] == 0.0:
            mapped["calories"] = value
        elif name == "protein":
            mapped["protein"] = value
        elif "carbohydrate" in name and "by difference" in name:
            mapped["carbs"] = value
        elif "carbohydrate" in name and "sum of monosaccharides" in name:
            mapped["net_carbs"] = value
        elif name == "total lipid (fat)":
            mapped["fat"] = value
        elif "fatty acids, total saturated" in name:
            mapped["saturated_fat"] = value
        elif "fatty acids, total trans" in name:
            mapped["trans_fat"] = value
        elif "fatty acids, total monounsaturated" in name:
            mapped["monounsaturated_fat"] = value
        elif "fatty acids, total polyunsaturated" in name:
            mapped["polyunsaturated_fat"] = value
        elif name == "cholesterol":
            mapped["cholesterol_mg"] = value
        elif "fiber" in name:
            mapped["fiber"] = value
        elif "sugars, total including nlea" in name or name == "sugars, total":
            mapped["sugar"] = value
        elif "added sugars" in name:
            mapped["added_sugar"] = value
        elif name == "sodium, na":
            mapped["sodium_mg"] = value
        elif name == "potassium, k":
            mapped["potassium_mg"] = value
        elif name == "magnesium, mg":
            mapped["magnesium_mg"] = value
        elif name == "phosphorus, p":
            mapped["phosphorus_mg"] = value
        elif name == "zinc, zn":
            mapped["zinc_mg"] = value
        elif name == "iron, fe":
            mapped["iron_mg"] = value
        elif name == "calcium, ca":
            mapped["calcium_mg"] = value
        elif "vitamin a, rae" in name:
            mapped["vitamin_a_mcg"] = value
        elif name == "vitamin c, total ascorbic acid":
            mapped["vitamin_c_mg"] = value
        elif name in {"vitamin d (d2 + d3)", "vitamin d"}:
            mapped["vitamin_d_mcg"] = value
        elif name == "vitamin b-12":
            mapped["vitamin_b12_mcg"] = value
        elif name in {"folate, total", "folate, food"}:
            mapped["folate_mcg"] = value
    return mapped


@lru_cache(maxsize=256)
def fetch_open_food_facts_search(query: str, limit: int = 12) -> List[Dict]:
    try:
        with httpx.Client(timeout=8.0) as client:
            response = client.get(
                "https://world.openfoodfacts.org/cgi/search.pl",
                params={
                    "search_terms": query,
                    "search_simple": 1,
                    "action": "process",
                    "json": 1,
                    "page_size": limit,
                },
            )
            response.raise_for_status()
            payload = response.json()
    except Exception:
        return []

    products = payload.get("products", [])
    results: List[Dict] = []
    for product in products:
        converted = _off_product_to_food(product)
        if converted is not None:
            results.append(converted)
    return results


@lru_cache(maxsize=256)
def fetch_open_food_facts_barcode(barcode: str) -> Optional[Dict]:
    try:
        with httpx.Client(timeout=8.0) as client:
            response = client.get(f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json")
            response.raise_for_status()
            payload = response.json()
    except Exception:
        return None

    product = payload.get("product")
    if not product:
        return None
    return _off_product_to_food(product)


@lru_cache(maxsize=256)
def fetch_spoonacular_foods(query: str, limit: int = 8) -> List[Dict]:
    api_key = get_spoonacular_api_key()
    if not api_key:
        return []

    try:
        with httpx.Client(timeout=9.0) as client:
            search_response = client.get(
                "https://api.spoonacular.com/food/ingredients/search",
                params={
                    "query": query,
                    "number": max(1, min(limit, 12)),
                    "apiKey": api_key,
                },
            )
            search_response.raise_for_status()
            payload = search_response.json()
    except Exception:
        return []

    results: List[Dict] = []
    ingredients = payload.get("results", [])
    with httpx.Client(timeout=9.0) as client:
        for ingredient in ingredients:
            ingredient_id = ingredient.get("id")
            name = ingredient.get("name")
            if not name:
                continue

            # Always return a basic Spoonacular result even if detail lookup fails.
            nutrients = _empty_nutrients()
            if ingredient_id:
                try:
                    detail_response = client.get(
                        f"https://api.spoonacular.com/food/ingredients/{ingredient_id}/information",
                        params={
                            "amount": 100,
                            "unit": "g",
                            "apiKey": api_key,
                        },
                    )
                    detail_response.raise_for_status()
                    detail = detail_response.json()
                    detail_name = detail.get("name")
                    if detail_name:
                        name = detail_name
                    nutrients = _spoonacular_nutrient_map(detail.get("nutrition", {}).get("nutrients", []))
                except Exception:
                    # Keep basic result without nutrition when detail call fails.
                    pass

            results.append(
                _food_payload(
                    name=str(name).title(),
                    brand=None,
                    barcode=None,
                    source="SPOONACULAR",
                    serving_description="100 g",
                    nutrients=nutrients,
                )
            )

    if results:
        return results

    # Fallback to recipe search to ensure spoon provider can still return results.
    return fetch_spoonacular_recipe_foods(query, limit=limit)


@lru_cache(maxsize=256)
def fetch_spoonacular_recipe_foods(query: str, limit: int = 8) -> List[Dict]:
    api_key = get_spoonacular_api_key()
    if not api_key:
        return []

    recipe_payload = None
    try:
        with httpx.Client(timeout=8.0) as client:
            recipe_response = client.get(
                "https://api.spoonacular.com/recipes/complexSearch",
                params={
                    "query": query,
                    "number": max(1, min(limit, 12)),
                    "addRecipeNutrition": "true",
                    "apiKey": api_key,
                },
            )
            recipe_response.raise_for_status()
            recipe_payload = recipe_response.json()
    except Exception:
        # Some plans may not support addRecipeNutrition. Retry without it.
        try:
            with httpx.Client(timeout=8.0) as client:
                recipe_response = client.get(
                    "https://api.spoonacular.com/recipes/complexSearch",
                    params={
                        "query": query,
                        "number": max(1, min(limit, 12)),
                        "apiKey": api_key,
                    },
                )
                recipe_response.raise_for_status()
                recipe_payload = recipe_response.json()
        except Exception:
            return []

    recipe_items = recipe_payload.get("results", [])
    fallback_results: List[Dict] = []
    for recipe in recipe_items:
        title = recipe.get("title")
        if not title:
            continue
        nutrients = _spoon_recipe_nutrient_map(recipe.get("nutrition", {}).get("nutrients", []))
        fallback_results.append(
            _food_payload(
                name=str(title).title(),
                brand="Spoonacular Recipe",
                barcode=None,
                source="SPOONACULAR",
                serving_description="1 serving (estimated)",
                nutrients=nutrients,
            )
        )
    return fallback_results


def debug_spoonacular(query: str, limit: int = 5) -> Dict:
    api_key = get_spoonacular_api_key()
    if not api_key:
        return {
            "key_present": False,
            "ingredient_status": "missing_key",
            "recipe_status": "missing_key",
            "ingredient_count": 0,
            "recipe_count": 0,
        }

    ingredient_status, ingredient_count = _spoon_ingredient_probe(query, limit, api_key)
    recipe_status, recipe_count = _spoon_recipe_probe(query, limit, api_key)

    return {
        "key_present": True,
        "ingredient_status": ingredient_status,
        "recipe_status": recipe_status,
        "ingredient_count": ingredient_count,
        "recipe_count": recipe_count,
    }


def _spoon_ingredient_probe(query: str, limit: int, api_key: str) -> Tuple[str, int]:
    try:
        with httpx.Client(timeout=8.0) as client:
            response = client.get(
                "https://api.spoonacular.com/food/ingredients/search",
                params={
                    "query": query,
                    "number": max(1, min(limit, 12)),
                    "apiKey": api_key,
                },
            )
            if response.status_code != 200:
                return (f"http_{response.status_code}", 0)
            payload = response.json()
            return ("ok", len(payload.get("results", [])))
    except Exception as exc:
        return (f"error:{exc.__class__.__name__}", 0)


def _spoon_recipe_probe(query: str, limit: int, api_key: str) -> Tuple[str, int]:
    try:
        with httpx.Client(timeout=8.0) as client:
            response = client.get(
                "https://api.spoonacular.com/recipes/complexSearch",
                params={
                    "query": query,
                    "number": max(1, min(limit, 12)),
                    "apiKey": api_key,
                },
            )
            if response.status_code != 200:
                return (f"http_{response.status_code}", 0)
            payload = response.json()
            return ("ok", len(payload.get("results", [])))
    except Exception as exc:
        return (f"error:{exc.__class__.__name__}", 0)


def _spoon_recipe_nutrient_map(nutrients: List[Dict]) -> Dict[str, float]:
    return _spoon_nutrient_map(nutrients)


def _spoon_nutrient_map(nutrients: List[Dict]) -> Dict[str, float]:
    mapped = _empty_nutrients()
    for nutrient in nutrients:
        name = str(nutrient.get("name", "")).lower()
        amount = _to_float(nutrient.get("amount"))
        unit = str(nutrient.get("unit", "")).lower()
        if name == "calories":
            mapped["calories"] = amount
        elif name == "protein":
            mapped["protein"] = amount
        elif name in {"carbohydrates", "carbohydrate"}:
            mapped["carbs"] = amount
        elif name == "net carbohydrates":
            mapped["net_carbs"] = amount
        elif name == "fat":
            mapped["fat"] = amount
        elif name == "saturated fat":
            mapped["saturated_fat"] = amount
        elif name == "trans fat":
            mapped["trans_fat"] = amount
        elif name in {"mono unsaturated fat", "monounsaturated fat"}:
            mapped["monounsaturated_fat"] = amount
        elif name in {"poly unsaturated fat", "polyunsaturated fat"}:
            mapped["polyunsaturated_fat"] = amount
        elif name == "cholesterol":
            mapped["cholesterol_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "fiber":
            mapped["fiber"] = amount
        elif name in {"sugar", "sugars"}:
            mapped["sugar"] = amount
        elif name == "added sugar":
            mapped["added_sugar"] = amount
        elif name == "sodium":
            mapped["sodium_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "potassium":
            mapped["potassium_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "magnesium":
            mapped["magnesium_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "phosphorus":
            mapped["phosphorus_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "zinc":
            mapped["zinc_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "iron":
            mapped["iron_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "calcium":
            mapped["calcium_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "vitamin a":
            mapped["vitamin_a_mcg"] = amount
        elif name == "vitamin c":
            mapped["vitamin_c_mg"] = amount if unit == "mg" else amount * 1000
        elif name == "vitamin d":
            mapped["vitamin_d_mcg"] = amount
        elif name == "vitamin b12":
            mapped["vitamin_b12_mcg"] = amount
        elif name in {"folate", "folic acid"}:
            mapped["folate_mcg"] = amount
    return mapped


def _off_product_to_food(product: Dict) -> Optional[Dict]:
    name = product.get("product_name") or product.get("generic_name")
    if not name:
        return None

    nutriments = product.get("nutriments", {})
    sodium_g = _to_float(nutriments.get("sodium_100g"), default=-1)
    sodium_mg = sodium_g * 1000 if sodium_g >= 0 else 0.0
    if sodium_mg == 0.0:
        salt_g = _to_float(nutriments.get("salt_100g"))
        sodium_mg = salt_g * 400

    brands = str(product.get("brands") or "").split(",")
    brand = brands[0].strip() if brands and brands[0].strip() else None

    nutrients = _empty_nutrients()
    nutrients.update(
        {
            "calories": _to_float(nutriments.get("energy-kcal_100g")),
            "protein": _to_float(nutriments.get("proteins_100g")),
            "carbs": _to_float(nutriments.get("carbohydrates_100g")),
            "fat": _to_float(nutriments.get("fat_100g")),
            "fiber": _to_float(nutriments.get("fiber_100g")),
            "sugar": _to_float(nutriments.get("sugars_100g")),
            "added_sugar": _to_float(nutriments.get("added-sugars_100g")),
            "saturated_fat": _to_float(nutriments.get("saturated-fat_100g")),
            "trans_fat": _to_float(nutriments.get("trans-fat_100g")),
            "monounsaturated_fat": _to_float(nutriments.get("monounsaturated-fat_100g")),
            "polyunsaturated_fat": _to_float(nutriments.get("polyunsaturated-fat_100g")),
            "cholesterol_mg": _to_float(nutriments.get("cholesterol_100g")),
            "sodium_mg": sodium_mg,
            "potassium_mg": _to_float(nutriments.get("potassium_100g")),
            "magnesium_mg": _to_float(nutriments.get("magnesium_100g")),
            "phosphorus_mg": _to_float(nutriments.get("phosphorus_100g")),
            "zinc_mg": _to_float(nutriments.get("zinc_100g")),
            "iron_mg": _to_float(nutriments.get("iron_100g")),
            "calcium_mg": _to_float(nutriments.get("calcium_100g")),
            "vitamin_a_mcg": _to_float(nutriments.get("vitamin-a_100g")),
            "vitamin_c_mg": _to_float(nutriments.get("vitamin-c_100g")),
            "vitamin_d_mcg": _to_float(nutriments.get("vitamin-d_100g")),
            "vitamin_b12_mcg": _to_float(nutriments.get("vitamin-b12_100g")),
            "folate_mcg": _to_float(nutriments.get("folates_100g") or nutriments.get("folate_100g")),
        }
    )
    if nutrients["carbs"] > 0:
        nutrients["net_carbs"] = max(nutrients["carbs"] - nutrients["fiber"], 0.0)

    return _food_payload(
        name=name,
        brand=brand,
        barcode=product.get("code"),
        source="OPEN_FOOD_FACTS",
        serving_description="100 g",
        nutrients=nutrients,
    )


def _spoonacular_nutrient_map(nutrients: List[Dict]) -> Dict[str, float]:
    return _spoon_nutrient_map(nutrients)
