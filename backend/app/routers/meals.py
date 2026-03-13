from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import and_
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db
from app.models import Food, HydrationLog, MealLog, MealLogItem, User
from app.schemas import (
    HydrationCreateRequest,
    MealLogDayResponse,
    MealLogItemCreateRequest,
    MealLogItemOut,
    MealLogItemUpdateRequest,
)


router = APIRouter(tags=["meals"])


def _get_or_create_meal_log(db: Session, user_id: int, log_date: date) -> MealLog:
    meal_log = db.query(MealLog).filter(MealLog.user_id == user_id, MealLog.log_date == log_date).first()
    if meal_log:
        return meal_log

    meal_log = MealLog(user_id=user_id, log_date=log_date)
    db.add(meal_log)
    db.flush()
    return meal_log


def _from_food(food: Food, grams: float) -> dict[str, float]:
    factor = grams / 100.0
    return {
        "calories": round(food.calories_per_100g * factor, 2),
        "protein_g": round(food.protein_g_per_100g * factor, 2),
        "carbs_g": round(food.carbs_g_per_100g * factor, 2),
        "fat_g": round(food.fat_g_per_100g * factor, 2),
        "sodium_mg": round(food.sodium_mg_per_100g * factor, 2),
        "iron_mg": round(food.iron_mg_per_100g * factor, 2),
        "calcium_mg": round(food.calcium_mg_per_100g * factor, 2),
    }


@router.get("/meal-logs", response_model=MealLogDayResponse)
def get_meal_logs(
    date_value: date = Query(alias="date"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    meal_log = db.query(MealLog).filter(MealLog.user_id == current_user.id, MealLog.log_date == date_value).first()
    if not meal_log:
        return MealLogDayResponse(date=date_value, items=[])

    items = [MealLogItemOut.model_validate(item) for item in meal_log.items]
    return MealLogDayResponse(date=date_value, items=items)


@router.post("/meal-logs/items", response_model=MealLogItemOut, status_code=status.HTTP_201_CREATED)
def add_meal_log_item(
    payload: MealLogItemCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    meal_log = _get_or_create_meal_log(db, current_user.id, payload.date)

    if payload.food_id:
        food = db.query(Food).filter(Food.id == payload.food_id).first()
        if not food:
            raise HTTPException(status_code=404, detail="Food not found")
        nutrients = _from_food(food, payload.grams)
        food_name = food.name if not food.brand else f"{food.brand} {food.name}"
        item = MealLogItem(
            meal_log_id=meal_log.id,
            meal_type=payload.meal_type,
            food_id=food.id,
            food_name=food_name,
            quantity=payload.quantity,
            unit=payload.unit,
            grams=payload.grams,
            **nutrients,
        )
    else:
        if not payload.custom_food_name:
            raise HTTPException(status_code=400, detail="custom_food_name is required for manual entries")
        if payload.calories is None:
            raise HTTPException(status_code=400, detail="calories is required for manual entries")
        item = MealLogItem(
            meal_log_id=meal_log.id,
            meal_type=payload.meal_type,
            food_id=None,
            food_name=payload.custom_food_name,
            quantity=payload.quantity,
            unit=payload.unit,
            grams=payload.grams,
            calories=payload.calories,
            protein_g=payload.protein_g or 0.0,
            carbs_g=payload.carbs_g or 0.0,
            fat_g=payload.fat_g or 0.0,
            sodium_mg=payload.sodium_mg or 0.0,
            iron_mg=payload.iron_mg or 0.0,
            calcium_mg=payload.calcium_mg or 0.0,
        )

    db.add(item)
    db.commit()
    db.refresh(item)
    return MealLogItemOut.model_validate(item)


@router.delete("/meal-logs/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_meal_log_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    item = (
        db.query(MealLogItem)
        .join(MealLog, MealLog.id == MealLogItem.meal_log_id)
        .filter(MealLogItem.id == item_id, MealLog.user_id == current_user.id)
        .first()
    )
    if not item:
        raise HTTPException(status_code=404, detail="Meal log item not found")
    db.delete(item)
    db.commit()


@router.patch("/meal-logs/items/{item_id}", response_model=MealLogItemOut)
def update_meal_log_item(
    item_id: int,
    payload: MealLogItemUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    item = (
        db.query(MealLogItem)
        .join(MealLog, MealLog.id == MealLogItem.meal_log_id)
        .filter(MealLogItem.id == item_id, MealLog.user_id == current_user.id)
        .first()
    )
    if not item:
        raise HTTPException(status_code=404, detail="Meal log item not found")

    item.meal_type = payload.meal_type
    item.grams = payload.grams
    if item.food_id:
        food = db.query(Food).filter(Food.id == item.food_id).first()
        if food:
            nutrients = _from_food(food, payload.grams)
            item.calories = nutrients["calories"]
            item.protein_g = nutrients["protein_g"]
            item.carbs_g = nutrients["carbs_g"]
            item.fat_g = nutrients["fat_g"]
            item.sodium_mg = nutrients["sodium_mg"]
            item.iron_mg = nutrients["iron_mg"]
            item.calcium_mg = nutrients["calcium_mg"]
    db.commit()
    db.refresh(item)
    return MealLogItemOut.model_validate(item)


@router.get("/meal-logs/range", response_model=list[MealLogDayResponse])
def get_meal_logs_range(
    date_from: date = Query(alias="date_from"),
    date_to: date = Query(alias="date_to"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(MealLog)
        .filter(
            and_(
                MealLog.user_id == current_user.id,
                MealLog.log_date >= date_from,
                MealLog.log_date <= date_to,
            )
        )
        .order_by(MealLog.log_date.asc())
        .all()
    )
    response: list[MealLogDayResponse] = []
    for row in rows:
        response.append(
            MealLogDayResponse(
                date=row.log_date,
                items=[MealLogItemOut.model_validate(item) for item in row.items],
            )
        )
    return response


@router.post("/hydration/logs", status_code=status.HTTP_201_CREATED)
def add_hydration_log(
    payload: HydrationCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    entry = HydrationLog(
        user_id=current_user.id,
        log_date=payload.date,
        amount_ml=payload.amount_ml,
    )
    db.add(entry)
    db.commit()
    return {"status": "ok"}
