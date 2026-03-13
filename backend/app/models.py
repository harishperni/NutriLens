from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from sqlalchemy import Date, DateTime, Float, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    email: Mapped[str] = mapped_column(String(120), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    goal: Mapped["UserGoal"] = relationship(back_populates="user", uselist=False, cascade="all, delete-orphan")


class UserGoal(Base):
    __tablename__ = "user_goals"
    __table_args__ = (UniqueConstraint("user_id", name="uq_user_goals_user"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    calorie_target: Mapped[int] = mapped_column(Integer, default=2000, nullable=False)
    protein_target_g: Mapped[int] = mapped_column(Integer, default=120, nullable=False)
    carbs_target_g: Mapped[int] = mapped_column(Integer, default=220, nullable=False)
    fat_target_g: Mapped[int] = mapped_column(Integer, default=70, nullable=False)
    water_target_ml: Mapped[int] = mapped_column(Integer, default=2500, nullable=False)

    user: Mapped[User] = relationship(back_populates="goal")


class Food(Base):
    __tablename__ = "foods"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(160), nullable=False, index=True)
    brand: Mapped[Optional[str]] = mapped_column(String(120), nullable=True, index=True)
    barcode: Mapped[Optional[str]] = mapped_column(String(64), unique=True, nullable=True, index=True)
    source: Mapped[str] = mapped_column(String(32), nullable=False, default="USDA")
    serving_description: Mapped[str] = mapped_column(String(120), default="100 g", nullable=False)
    calories_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    protein_g_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    carbs_g_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    fat_g_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    fiber_g_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    sugar_g_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    sodium_mg_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    iron_mg_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    calcium_mg_per_100g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)


class MealLog(Base):
    __tablename__ = "meal_logs"
    __table_args__ = (UniqueConstraint("user_id", "log_date", name="uq_meal_logs_user_date"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    log_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)

    items: Mapped[list["MealLogItem"]] = relationship(
        back_populates="meal_log",
        cascade="all, delete-orphan",
    )


class MealLogItem(Base):
    __tablename__ = "meal_log_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    meal_log_id: Mapped[int] = mapped_column(ForeignKey("meal_logs.id"), nullable=False, index=True)
    meal_type: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    food_id: Mapped[Optional[int]] = mapped_column(ForeignKey("foods.id"), nullable=True)
    food_name: Mapped[str] = mapped_column(String(180), nullable=False)
    quantity: Mapped[float] = mapped_column(Float, default=1.0, nullable=False)
    unit: Mapped[str] = mapped_column(String(30), default="serving", nullable=False)
    grams: Mapped[float] = mapped_column(Float, default=100.0, nullable=False)
    calories: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    protein_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    carbs_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    fat_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    sodium_mg: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    iron_mg: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    calcium_mg: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    meal_log: Mapped[MealLog] = relationship(back_populates="items")


class HydrationLog(Base):
    __tablename__ = "hydration_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    log_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    amount_ml: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)


class FavoriteFood(Base):
    __tablename__ = "favorite_foods"
    __table_args__ = (UniqueConstraint("user_id", "food_id", name="uq_favorite_food_user_food"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    food_id: Mapped[int] = mapped_column(ForeignKey("foods.id"), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)


class SavedMeal(Base):
    __tablename__ = "saved_meals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    items: Mapped[list["SavedMealItem"]] = relationship(
        back_populates="saved_meal",
        cascade="all, delete-orphan",
    )


class SavedMealItem(Base):
    __tablename__ = "saved_meal_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    saved_meal_id: Mapped[int] = mapped_column(ForeignKey("saved_meals.id"), nullable=False, index=True)
    meal_type: Mapped[str] = mapped_column(String(20), nullable=False, default="lunch")
    food_id: Mapped[Optional[int]] = mapped_column(ForeignKey("foods.id"), nullable=True)
    food_name: Mapped[str] = mapped_column(String(180), nullable=False)
    grams: Mapped[float] = mapped_column(Float, default=100.0, nullable=False)
    calories: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    protein_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    carbs_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    fat_g: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)

    saved_meal: Mapped[SavedMeal] = relationship(back_populates="items")


class NotificationPreference(Base):
    __tablename__ = "notification_preferences"
    __table_args__ = (UniqueConstraint("user_id", name="uq_notification_preferences_user"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    breakfast_enabled: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    lunch_enabled: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    dinner_enabled: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    snacks_enabled: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    water_enabled: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    breakfast_time: Mapped[str] = mapped_column(String(5), default="08:00", nullable=False)
    lunch_time: Mapped[str] = mapped_column(String(5), default="13:00", nullable=False)
    dinner_time: Mapped[str] = mapped_column(String(5), default="19:00", nullable=False)
    water_interval_minutes: Mapped[int] = mapped_column(Integer, default=120, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
