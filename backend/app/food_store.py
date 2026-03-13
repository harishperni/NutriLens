from __future__ import annotations

from typing import Dict, Iterable, Optional

from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.models import Food


def find_existing_food(db: Session, payload: Dict) -> Optional[Food]:
    barcode = (payload.get("barcode") or "").strip()
    if barcode:
        found = db.query(Food).filter(Food.barcode == barcode).first()
        if found:
            return found

    name = (payload.get("name") or "").strip()
    brand = (payload.get("brand") or "").strip()
    source = (payload.get("source") or "").strip()
    if not name:
        return None

    query = db.query(Food).filter(Food.name == name, Food.source == source)
    if brand:
        query = query.filter(Food.brand == brand)
    else:
        query = query.filter(Food.brand.is_(None))
    return query.first()


def upsert_foods(db: Session, foods: Iterable[Dict]) -> int:
    inserted = 0
    for payload in foods:
        if not payload.get("name"):
            continue
        payload = dict(payload)
        payload["name"] = str(payload.get("name", ""))[:160]
        brand = payload.get("brand")
        payload["brand"] = str(brand)[:120] if brand is not None else None
        barcode = payload.get("barcode")
        payload["barcode"] = str(barcode)[:64] if barcode else None
        payload["source"] = str(payload.get("source", "UNKNOWN"))[:32]
        payload["serving_description"] = str(payload.get("serving_description", "100 g"))[:120]
        existing = find_existing_food(db, payload)
        if existing:
            continue
        try:
            db.add(Food(**payload))
            db.commit()
            inserted += 1
        except SQLAlchemyError:
            db.rollback()
    return inserted
