# NutriLens Backend (MVP)

This is a runnable `FastAPI` backend that implements core MVP flows:

- Auth (`register`, `login`)
- User profile and goal targets
- Food search and barcode lookup
- Meal logging (catalog foods or manual entry)
- Hydration logging
- Daily dashboard totals (calories, macros, micronutrients, water)
- Optional live food search from USDA + Open Food Facts
- Optional Spoonacular ingredient search integration

## 1. Run locally

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The API will run at `http://127.0.0.1:8000`.

### Optional: enable live USDA search

Set your USDA API key before starting the backend:

```bash
export USDA_API_KEY="your_usda_api_key"
```

Or put it in `backend/.env`:

```bash
USDA_API_KEY=your_usda_api_key
```

Without this key:

- Open Food Facts live search still works
- USDA live search is skipped
- local seeded foods still work

### Optional: enable Spoonacular search

Set Spoonacular key before starting backend:

```bash
export SPOONACULAR_API_KEY="your_spoonacular_key"
```

Or put it in `backend/.env`:

```bash
SPOONACULAR_API_KEY=your_spoonacular_key
```

Notes:

- Spoonacular is used as an additional source in `/foods/search`
- Results are cached into local DB after first fetch
- If key is missing or rate-limited, local/USDA/OFF search still works
- To force Spoon recipe-mode results only: `/foods/search?q=pizza&provider=spoon_recipe`

### Optional: bulk preload many USDA foods

After setting `USDA_API_KEY`, run:

```bash
python -m scripts.sync_usda_foods --limit-per-term 30
```

This pre-imports a broad set of common food categories into your local DB so search is richer even if live API calls fail.

## 2. Open docs

- Swagger UI: `http://127.0.0.1:8000/docs`
- Health check: `GET /health`

## 3. Quick flow

### Register

```bash
curl -X POST http://127.0.0.1:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demo_user",
    "email": "demo@example.com",
    "password": "strongpassword"
  }'
```

Copy the `access_token` from the response.

### Search foods

```bash
curl "http://127.0.0.1:8000/foods/search?q=oats" \
  -H "Authorization: Bearer <TOKEN>"
```

### Barcode lookup

```bash
curl "http://127.0.0.1:8000/foods/barcode/1234567890123" \
  -H "Authorization: Bearer <TOKEN>"
```

### Add meal item from food id

```bash
curl -X POST http://127.0.0.1:8000/meal-logs/items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "date": "2026-03-12",
    "meal_type": "breakfast",
    "food_id": 1,
    "grams": 80,
    "quantity": 1,
    "unit": "grams"
  }'
```

### Add hydration

```bash
curl -X POST http://127.0.0.1:8000/hydration/logs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "date": "2026-03-12",
    "amount_ml": 350
  }'
```

### Get dashboard

```bash
curl "http://127.0.0.1:8000/dashboard?date=2026-03-12" \
  -H "Authorization: Bearer <TOKEN>"
```

## 4. Seed data

The app seeds a small food catalog on first run:

- USDA-style generic foods
- Open Food Facts-style packaged foods with barcodes

This is local seed data for MVP testing and can be replaced with live API integrations.
