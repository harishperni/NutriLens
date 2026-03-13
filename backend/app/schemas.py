from __future__ import annotations

from datetime import date
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class GoalOut(BaseModel):
    calorie_target: int
    protein_target_g: int
    carbs_target_g: int
    fat_target_g: int
    water_target_ml: int

    model_config = ConfigDict(from_attributes=True)


class MeResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    goal: GoalOut

    model_config = ConfigDict(from_attributes=True)


class GoalUpdateRequest(BaseModel):
    calorie_target: int = Field(default=2000, ge=1000, le=6000)
    protein_target_g: int = Field(default=120, ge=20, le=400)
    carbs_target_g: int = Field(default=220, ge=20, le=700)
    fat_target_g: int = Field(default=70, ge=10, le=300)
    water_target_ml: int = Field(default=2500, ge=200, le=10000)


class FoodOut(BaseModel):
    id: int
    name: str
    brand: Optional[str]
    barcode: Optional[str]
    source: str
    serving_description: str
    calories_per_100g: float
    protein_g_per_100g: float
    carbs_g_per_100g: float
    fat_g_per_100g: float
    sodium_mg_per_100g: float
    iron_mg_per_100g: float
    calcium_mg_per_100g: float

    model_config = ConfigDict(from_attributes=True)


class MealLogItemCreateRequest(BaseModel):
    date: date
    meal_type: str = Field(pattern="^(breakfast|lunch|dinner|snacks)$")
    food_id: Optional[int] = None
    custom_food_name: Optional[str] = None
    quantity: float = Field(default=1.0, gt=0)
    unit: str = Field(default="grams")
    grams: float = Field(default=100.0, gt=0)
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None
    sodium_mg: Optional[float] = None
    iron_mg: Optional[float] = None
    calcium_mg: Optional[float] = None


class MealLogItemOut(BaseModel):
    id: int
    meal_type: str
    food_id: Optional[int]
    food_name: str
    quantity: float
    unit: str
    grams: float
    calories: float
    protein_g: float
    carbs_g: float
    fat_g: float
    sodium_mg: float
    iron_mg: float
    calcium_mg: float

    model_config = ConfigDict(from_attributes=True)


class MealLogDayResponse(BaseModel):
    date: date
    items: list[MealLogItemOut]


class HydrationCreateRequest(BaseModel):
    date: date
    amount_ml: int = Field(gt=0, le=2000)


class DashboardResponse(BaseModel):
    date: date
    total_calories: float
    total_protein_g: float
    total_carbs_g: float
    total_fat_g: float
    total_sodium_mg: float
    total_iron_mg: float
    total_calcium_mg: float
    water_ml: int
    targets: GoalOut
