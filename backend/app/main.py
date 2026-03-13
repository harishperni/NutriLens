from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db import Base, SessionLocal, engine
from app.routers import auth, dashboard, foods, meals, profile
from app.seed import seed_foods_if_empty


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_foods_if_empty(db)
    finally:
        db.close()
    yield


app = FastAPI(
    title="NutriLens API",
    version="0.1.0",
    description="MVP backend for nutrition tracking with auth, foods, meal logging, hydration, and dashboard summaries.",
    lifespan=lifespan,
)

app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(foods.router)
app.include_router(meals.router)
app.include_router(dashboard.router)


@app.get("/health")
def health():
    return {"status": "ok"}

