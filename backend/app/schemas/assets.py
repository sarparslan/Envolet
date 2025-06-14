from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StringConstraints

NonEmpty = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=100)]


class AssetIn(BaseModel):
    bankName: NonEmpty  # noqa: N815 - matches the client's JSON keys
    amount: Annotated[int, Field(ge=0)]
    lastFourDigits: Annotated[str, StringConstraints(pattern=r"^\d{4}$")]  # noqa: N815
    brand: NonEmpty
    color: Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=20)]


class AssetOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str = Field(serialization_alias="_id")
    bank_name: str = Field(serialization_alias="bankName")
    amount: int
    last_four_digits: str = Field(serialization_alias="lastFourDigits")
    brand: str
    color: str


class AssetResponse(BaseModel):
    data: AssetOut


class AssetListResponse(BaseModel):
    data: list[AssetOut]
