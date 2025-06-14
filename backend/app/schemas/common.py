from typing import Annotated, Literal

from pydantic import BaseModel, StringConstraints

CATEGORIES: tuple[str, ...] = (
    "Food & Drinks",
    "Transportation",
    "Housing",
    "Bills",
    "Health",
    "Entertainment",
    "Shopping",
    "Education",
    "Travel",
)

Category = Literal[
    "Food & Drinks",
    "Transportation",
    "Housing",
    "Bills",
    "Health",
    "Entertainment",
    "Shopping",
    "Education",
    "Travel",
]

MonthStr = Annotated[str, StringConstraints(pattern=r"^\d{4}-(0[1-9]|1[0-2])$")]


class MessageResponse(BaseModel):
    message: str
