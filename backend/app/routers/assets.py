from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.dependencies import CurrentUser, DbSession
from app.models import Asset
from app.schemas.assets import AssetIn, AssetListResponse, AssetOut, AssetResponse
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/assets", tags=["assets"])


def _apply(asset: Asset, body: AssetIn) -> None:
    asset.bank_name = body.bankName
    asset.amount = body.amount
    asset.last_four_digits = body.lastFourDigits
    asset.brand = body.brand
    asset.color = body.color


def _get_owned(db: DbSession, user_id: str, asset_id: str) -> Asset:
    asset = db.get(Asset, asset_id)
    if asset is None or asset.user_id != user_id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Asset not found")
    return asset


@router.get("", response_model=AssetListResponse)
def list_assets(user: CurrentUser, db: DbSession) -> AssetListResponse:
    stmt = select(Asset).where(Asset.user_id == user.id).order_by(Asset.created_at)
    return AssetListResponse(data=[AssetOut.model_validate(a) for a in db.scalars(stmt)])


@router.post("", response_model=AssetResponse, status_code=status.HTTP_201_CREATED)
def create_asset(body: AssetIn, user: CurrentUser, db: DbSession) -> AssetResponse:
    asset = Asset(user_id=user.id)
    _apply(asset, body)
    db.add(asset)
    db.commit()
    return AssetResponse(data=AssetOut.model_validate(asset))


@router.put("/{asset_id}", response_model=AssetResponse)
def update_asset(asset_id: str, body: AssetIn, user: CurrentUser, db: DbSession) -> AssetResponse:
    asset = _get_owned(db, user.id, asset_id)
    _apply(asset, body)
    db.commit()
    return AssetResponse(data=AssetOut.model_validate(asset))


@router.delete("/{asset_id}", response_model=MessageResponse)
def delete_asset(asset_id: str, user: CurrentUser, db: DbSession) -> MessageResponse:
    db.delete(_get_owned(db, user.id, asset_id))
    db.commit()
    return MessageResponse(message="Asset deleted")
