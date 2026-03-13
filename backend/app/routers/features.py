from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db
from app.models import (
    FavoriteFood,
    Food,
    HydrationLog,
    MealLog,
    MealLogItem,
    NotificationPreference,
    SavedMeal,
    SavedMealItem,
    User,
)
from app.schemas import (
    FavoriteFoodCreateRequest,
    FavoriteFoodOut,
    NotificationPreferenceOut,
    NotificationPreferenceUpdateRequest,
    SavedMealCreateRequest,
    SavedMealLogRequest,
    SavedMealOut,
    WeeklySummaryDay,
    WeeklySummaryResponse,
)


router = APIRouter(tags=["features"])


def _get_or_create_notification_pref(db: Session, user_id: int) -> NotificationPreference:
    pref = db.query(NotificationPreference).filter(NotificationPreference.user_id == user_id).first()
    if pref:
        return pref
    pref = NotificationPreference(user_id=user_id)
    db.add(pref)
    db.commit()
    db.refresh(pref)
    return pref


@router.get("/favorites", response_model=list[FavoriteFoodOut])
def get_favorites(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(FavoriteFood, Food)
        .join(Food, Food.id == FavoriteFood.food_id)
        .filter(FavoriteFood.user_id == current_user.id)
        .order_by(FavoriteFood.created_at.desc())
        .all()
    )
    return [
        FavoriteFoodOut(
            id=favorite.id,
            food_id=food.id,
            food_name=(food.name if not food.brand else f"{food.brand} {food.name}"),
            source=food.source,
        )
        for favorite, food in rows
    ]


@router.post("/favorites", response_model=FavoriteFoodOut, status_code=status.HTTP_201_CREATED)
def add_favorite(
    payload: FavoriteFoodCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    food = db.query(Food).filter(Food.id == payload.food_id).first()
    if not food:
        raise HTTPException(status_code=404, detail="Food not found")
    existing = (
        db.query(FavoriteFood)
        .filter(FavoriteFood.user_id == current_user.id, FavoriteFood.food_id == payload.food_id)
        .first()
    )
    if existing:
        return FavoriteFoodOut(
            id=existing.id,
            food_id=food.id,
            food_name=(food.name if not food.brand else f"{food.brand} {food.name}"),
            source=food.source,
        )
    favorite = FavoriteFood(user_id=current_user.id, food_id=payload.food_id)
    db.add(favorite)
    db.commit()
    db.refresh(favorite)
    return FavoriteFoodOut(
        id=favorite.id,
        food_id=food.id,
        food_name=(food.name if not food.brand else f"{food.brand} {food.name}"),
        source=food.source,
    )


@router.delete("/favorites/{favorite_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favorite(
    favorite_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = (
        db.query(FavoriteFood)
        .filter(FavoriteFood.id == favorite_id, FavoriteFood.user_id == current_user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Favorite not found")
    db.delete(row)
    db.commit()


@router.get("/foods/recent", response_model=list[FavoriteFoodOut])
def get_recent_foods(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(MealLogItem, Food)
        .join(MealLog, MealLog.id == MealLogItem.meal_log_id)
        .join(Food, Food.id == MealLogItem.food_id, isouter=True)
        .filter(MealLog.user_id == current_user.id)
        .order_by(MealLogItem.created_at.desc())
        .limit(40)
        .all()
    )
    unique = []
    seen = set()
    for item, food in rows:
        key = item.food_id if item.food_id else f"manual:{item.food_name}"
        if key in seen:
            continue
        seen.add(key)
        source = food.source if food else "MANUAL"
        food_name = item.food_name
        unique.append(FavoriteFoodOut(id=item.id, food_id=item.food_id or -item.id, food_name=food_name, source=source))
        if len(unique) >= 20:
            break
    return unique


@router.post("/saved-meals", response_model=SavedMealOut, status_code=status.HTTP_201_CREATED)
def create_saved_meal(
    payload: SavedMealCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved = SavedMeal(user_id=current_user.id, name=payload.name)
    db.add(saved)
    db.flush()
    for item in payload.items:
        db.add(
            SavedMealItem(
                saved_meal_id=saved.id,
                meal_type=item.meal_type,
                food_id=item.food_id,
                food_name=item.food_name,
                grams=item.grams,
                calories=item.calories,
                protein_g=item.protein_g,
                carbs_g=item.carbs_g,
                fat_g=item.fat_g,
            )
        )
    db.commit()
    db.refresh(saved)
    return SavedMealOut(
        id=saved.id,
        name=saved.name,
        items=list(saved.items),
    )


@router.get("/saved-meals", response_model=list[SavedMealOut])
def get_saved_meals(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(SavedMeal)
        .filter(SavedMeal.user_id == current_user.id)
        .order_by(SavedMeal.created_at.desc())
        .all()
    )
    return [SavedMealOut(id=row.id, name=row.name, items=list(row.items)) for row in rows]


@router.delete("/saved-meals/{saved_meal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_saved_meal(
    saved_meal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = db.query(SavedMeal).filter(SavedMeal.id == saved_meal_id, SavedMeal.user_id == current_user.id).first()
    if not row:
        raise HTTPException(status_code=404, detail="Saved meal not found")
    db.delete(row)
    db.commit()


@router.post("/saved-meals/{saved_meal_id}/log", status_code=status.HTTP_201_CREATED)
def log_saved_meal(
    saved_meal_id: int,
    payload: SavedMealLogRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved = db.query(SavedMeal).filter(SavedMeal.id == saved_meal_id, SavedMeal.user_id == current_user.id).first()
    if not saved:
        raise HTTPException(status_code=404, detail="Saved meal not found")

    meal_log = db.query(MealLog).filter(MealLog.user_id == current_user.id, MealLog.log_date == payload.date).first()
    if not meal_log:
        meal_log = MealLog(user_id=current_user.id, log_date=payload.date)
        db.add(meal_log)
        db.flush()

    for item in saved.items:
        db.add(
            MealLogItem(
                meal_log_id=meal_log.id,
                meal_type=item.meal_type,
                food_id=item.food_id,
                food_name=item.food_name,
                grams=item.grams,
                quantity=1,
                unit="grams",
                calories=item.calories,
                protein_g=item.protein_g,
                carbs_g=item.carbs_g,
                fat_g=item.fat_g,
                sodium_mg=0.0,
                iron_mg=0.0,
                calcium_mg=0.0,
            )
        )
    db.commit()
    return {"status": "ok"}


@router.get("/analytics/weekly", response_model=WeeklySummaryResponse)
def get_weekly_summary(
    end_date: date = Query(default_factory=date.today),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    start_date = end_date - timedelta(days=6)
    day_rows: list[WeeklySummaryDay] = []
    for offset in range(7):
        day = start_date + timedelta(days=offset)
        sums = (
            db.query(
                func.coalesce(func.sum(MealLogItem.calories), 0.0),
                func.coalesce(func.sum(MealLogItem.protein_g), 0.0),
                func.coalesce(func.sum(MealLogItem.carbs_g), 0.0),
                func.coalesce(func.sum(MealLogItem.fat_g), 0.0),
            )
            .join(MealLog, MealLog.id == MealLogItem.meal_log_id)
            .filter(MealLog.user_id == current_user.id, MealLog.log_date == day)
            .one()
        )
        water_ml = (
            db.query(func.coalesce(func.sum(HydrationLog.amount_ml), 0))
            .filter(HydrationLog.user_id == current_user.id, HydrationLog.log_date == day)
            .scalar()
        )
        day_rows.append(
            WeeklySummaryDay(
                date=day,
                calories=float(sums[0]),
                protein_g=float(sums[1]),
                carbs_g=float(sums[2]),
                fat_g=float(sums[3]),
                water_ml=int(water_ml),
            )
        )

    def _avg(values: list[float]) -> float:
        return round(sum(values) / len(values), 2) if values else 0.0

    return WeeklySummaryResponse(
        days=day_rows,
        average_calories=_avg([row.calories for row in day_rows]),
        average_protein_g=_avg([row.protein_g for row in day_rows]),
        average_carbs_g=_avg([row.carbs_g for row in day_rows]),
        average_fat_g=_avg([row.fat_g for row in day_rows]),
        average_water_ml=_avg([float(row.water_ml) for row in day_rows]),
    )


@router.get("/notifications/preferences", response_model=NotificationPreferenceOut)
def get_notification_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pref = _get_or_create_notification_pref(db, current_user.id)
    return NotificationPreferenceOut.model_validate(pref)


@router.patch("/notifications/preferences", response_model=NotificationPreferenceOut)
def update_notification_preferences(
    payload: NotificationPreferenceUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pref = _get_or_create_notification_pref(db, current_user.id)
    pref.breakfast_enabled = payload.breakfast_enabled
    pref.lunch_enabled = payload.lunch_enabled
    pref.dinner_enabled = payload.dinner_enabled
    pref.snacks_enabled = payload.snacks_enabled
    pref.water_enabled = payload.water_enabled
    pref.breakfast_time = payload.breakfast_time
    pref.lunch_time = payload.lunch_time
    pref.dinner_time = payload.dinner_time
    pref.water_interval_minutes = payload.water_interval_minutes
    db.commit()
    db.refresh(pref)
    return NotificationPreferenceOut.model_validate(pref)

