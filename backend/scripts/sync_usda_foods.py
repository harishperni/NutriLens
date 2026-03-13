from __future__ import annotations

import argparse
import time

from app.config import get_usda_api_key
from app.db import SessionLocal
from app.external_food_apis import fetch_usda_foods
from app.food_store import upsert_foods


COMMON_TERMS = [
    "chicken",
    "beef",
    "pork",
    "turkey",
    "fish",
    "salmon",
    "tuna",
    "egg",
    "milk",
    "yogurt",
    "cheese",
    "rice",
    "quinoa",
    "oats",
    "bread",
    "pasta",
    "potato",
    "sweet potato",
    "broccoli",
    "spinach",
    "tomato",
    "onion",
    "carrot",
    "apple",
    "banana",
    "orange",
    "berries",
    "avocado",
    "beans",
    "lentils",
    "chickpeas",
    "tofu",
    "almonds",
    "peanut butter",
    "olive oil",
    "cereal",
    "protein bar",
    "soup",
    "sandwich",
    "pizza",
]


def main() -> None:
    parser = argparse.ArgumentParser(description="Bulk sync USDA foods into local NutriLens database")
    parser.add_argument("--limit-per-term", type=int, default=25, help="USDA results per term")
    parser.add_argument("--sleep-ms", type=int, default=120, help="Pause between requests in milliseconds")
    parser.add_argument("--terms", nargs="*", help="Optional custom terms list")
    args = parser.parse_args()

    api_key = get_usda_api_key()
    if not api_key:
        raise SystemExit("USDA_API_KEY not set. Export it first, then run this script.")

    terms = args.terms if args.terms else COMMON_TERMS
    db = SessionLocal()
    inserted_total = 0
    fetched_total = 0
    try:
        for idx, term in enumerate(terms, start=1):
            foods = fetch_usda_foods(term, limit=args.limit_per_term)
            fetched_total += len(foods)
            inserted = upsert_foods(db, foods)
            inserted_total += inserted
            print(f"[{idx}/{len(terms)}] term='{term}' fetched={len(foods)} inserted={inserted}")
            time.sleep(max(args.sleep_ms, 0) / 1000.0)
    finally:
        db.close()

    print("")
    print(f"Done. fetched_total={fetched_total} inserted_total={inserted_total}")


if __name__ == "__main__":
    main()

