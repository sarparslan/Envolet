from typing import Annotated

from pydantic import BaseModel, ConfigDict, EmailStr, StringConstraints

NameStr = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=100)]
# Users with a single-word name register without a surname.
SurnameStr = Annotated[str, StringConstraints(strip_whitespace=True, max_length=100)]


class RegisterRequest(BaseModel):
    name: NameStr
    surname: SurnameStr = ""
    email: EmailStr
    password: Annotated[str, StringConstraints(min_length=6, max_length=72)]


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: str
    surname: str
    email: str


class AuthResponse(BaseModel):
    token: str
    user: UserOut


class MeResponse(BaseModel):
    user: UserOut
