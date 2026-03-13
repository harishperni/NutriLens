from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db
from app.models import HydrationLog, MealLog, MealLogItem, User, UserGoal
from app.schemas import DashboardResponse, GoalOut


router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardResponse)
def get_dashboard(
    date_value: date = Query(alias="date"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sums = (
        db.query(
            func.coalesce(func.sum(MealLogItem.calories), 0.0),
            func.coalesce(func.sum(MealLogItem.protein_g), 0.0),
            func.coalesce(func.sum(MealLogItem.carbs_g), 0.0),
            func.coalesce(func.sum(MealLogItem.fat_g), 0.0),
            func.coalesce(func.sum(MealLogItem.sodium_mg), 0.0),
            func.coalesce(func.sum(MealLogItem.iron_mg), 0.0),
            func.coalesce(func.sum(MealLogItem.calcium_mg), 0.0),
        )
        .join(MealLog, MealLog.id == MealLogItem.meal_log_id)
        .filter(MealLog.user_id == current_user.id, MealLog.log_date == date_value)
        .one()
    )

    water_ml = (
        db.query(func.coalesce(func.sum(HydrationLog.amount_ml), 0))
        .filter(HydrationLog.user_id == current_user.id, HydrationLog.log_date == date_value)
        .scalar()
    )

    goal = db.query(UserGoal).filter(UserGoal.user_id == current_user.id).first()

    return DashboardResponse(
        date=date_value,
        total_calories=round(float(sums[0]), 2),
        total_protein_g=round(float(sums[1]), 2),
        total_carbs_g=round(float(sums[2]), 2),
        total_fat_g=round(float(sums[3]), 2),
        total_sodium_mg=round(float(sums[4]), 2),
        total_iron_mg=round(float(sums[5]), 2),
        total_calcium_mg=round(float(sums[6]), 2),
        water_ml=int(water_ml),
        targets=GoalOut.model_validate(goal),
    )

