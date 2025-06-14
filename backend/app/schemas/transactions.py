import datetime as dt
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, field_serializer

from app.schemas.common import Category


class TransactionIn(BaseModel):
    amount: Annotated[float, Field(gt=0)]
    category: Category
    date: dt.date


class TransactionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: str = Field(serialization_alias="_id")
    amount: float
    category: str
    date: dt.date

    @field_serializer("date")
    def _serialize_date(self, value: dt.date) -> str:
        return value.isoformat()


class TransactionResponse(BaseModel):
    data: TransactionOut


class TransactionListResponse(BaseModel):
    data: list[TransactionOut]


class BucketsResponse(BaseModel):
    buckets: list[float]


class CategoryShare(BaseModel):
    category: str
    total: float
    percentage: float


class CategoryShareResponse(BaseModel):
    data: list[CategoryShare]
