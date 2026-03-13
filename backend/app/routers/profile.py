from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.deps import get_current_user, get_db
from app.models import User, UserGoal
from app.schemas import GoalOut, GoalUpdateRequest, MeResponse


router = APIRouter(tags=["profile"])


@router.get("/me", response_model=MeResponse)
def get_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    goal = db.query(UserGoal).filter(UserGoal.user_id == current_user.id).first()
    return MeResponse(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        goal=GoalOut.model_validate(goal),
    )


@router.patch("/me/goals", response_model=GoalOut)
def update_goals(
    payload: GoalUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = db.query(UserGoal).filter(UserGoal.user_id == current_user.id).first()
    goal.calorie_target = payload.calorie_target
    goal.protein_target_g = payload.protein_target_g
    goal.carbs_target_g = payload.carbs_target_g
    goal.fat_target_g = payload.fat_target_g
    goal.water_target_ml = payload.water_target_ml
    db.commit()
    db.refresh(goal)
    return GoalOut.model_validate(goal)

