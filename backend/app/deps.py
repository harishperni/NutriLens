from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.db import SessionLocal
from app.models import User, UserGoal
from app.security import decode_access_token


auth_scheme = HTTPBearer(auto_error=False)


def _get_or_create_guest_user(db: Session) -> User:
    user = db.query(User).filter(User.username == "guest").first()
    if not user:
        user = User(
            username="guest",
            email="guest@nutrilens.local",
            password_hash="guest-mode-no-password",
        )
        db.add(user)
        db.flush()
        db.add(
            UserGoal(
                user_id=user.id,
                calorie_target=2000,
                protein_target_g=120,
                carbs_target_g=220,
                fat_target_g=70,
                water_target_ml=2500,
            )
        )
        db.commit()
        db.refresh(user)
        return user

    goal = db.query(UserGoal).filter(UserGoal.user_id == user.id).first()
    if not goal:
        db.add(
            UserGoal(
                user_id=user.id,
                calorie_target=2000,
                protein_target_g=120,
                carbs_target_g=220,
                fat_target_g=70,
                water_target_ml=2500,
            )
        )
        db.commit()
        db.refresh(user)
    return user


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(auth_scheme),
    db: Session = Depends(get_db),
) -> User:
    if credentials is None:
        return _get_or_create_guest_user(db)

    token = credentials.credentials
    try:
        username = decode_access_token(token)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
        )

    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
        )
    return user
