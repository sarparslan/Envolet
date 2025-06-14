from typing import Annotated, Literal

from pydantic import BaseModel, Field, StringConstraints

from app.schemas.common import Category


class SuggestionRequest(BaseModel):
    category: Category | Literal["General"]
    month: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=50)]
    monthTotal: Annotated[float, Field(ge=0)]  # noqa: N815 - matches the client's JSON keys
    monthlyAverage: Annotated[float, Field(ge=0)]  # noqa: N815
    currency: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=10)]


class SuggestionResponse(BaseModel):
    suggestion: str
