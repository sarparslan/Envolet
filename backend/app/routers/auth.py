from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.core.security import create_access_token, hash_password, verify_password
from app.dependencies import CurrentUser, DbSession
from app.models import User
from app.schemas.auth import AuthResponse, LoginRequest, MeResponse, RegisterRequest, UserOut
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/auth", tags=["auth"])


def _auth_response(user: User) -> AuthResponse:
    return AuthResponse(token=create_access_token(user.id), user=UserOut.model_validate(user))


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest, db: DbSession) -> AuthResponse:
    email = body.email.lower()
    if db.scalar(select(User).where(User.email == email)) is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, detail="Email is already registered")

    user = User(
        name=body.name,
        surname=body.surname,
        email=email,
        password_hash=hash_password(body.password),
    )
    db.add(user)
    db.commit()
    return _auth_response(user)


@router.post("/login", response_model=AuthResponse)
def login(body: LoginRequest, db: DbSession) -> AuthResponse:
    user = db.scalar(select(User).where(User.email == body.email.lower()))
    if user is None or not verify_password(body.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    return _auth_response(user)


@router.get("/me", response_model=MeResponse)
def me(user: CurrentUser) -> MeResponse:
    return MeResponse(user=UserOut.model_validate(user))


@router.delete("/delete", response_model=MessageResponse)
def delete_account(user: CurrentUser, db: DbSession) -> MessageResponse:
    db.delete(user)
    db.commit()
    return MessageResponse(message="Account and all associated data deleted")
