from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from app.dependencies import CurrentUser, DbSession
from app.models import Transaction
from app.schemas.common import Category, MessageResponse, MonthStr
from app.schemas.transactions import (
    BucketsResponse,
    CategoryShare,
    CategoryShareResponse,
    TransactionIn,
    TransactionListResponse,
    TransactionOut,
    TransactionResponse,
)
from app.services import analytics

router = APIRouter(prefix="/transactions", tags=["transactions"])

MonthQuery = Annotated[MonthStr, Query(description="Month in YYYY-MM format")]
CategoryQuery = Annotated[Category, Query()]


def _entries(db: DbSession, user_id: str, category: str | None = None) -> list[analytics.Entry]:
    stmt = select(Transaction.date, Transaction.amount).where(Transaction.user_id == user_id)
    if category is not None:
        stmt = stmt.where(Transaction.category == category)
    return [(row.date, row.amount) for row in db.execute(stmt)]


def _get_owned(db: DbSession, user_id: str, transaction_id: str) -> Transaction:
    transaction = db.get(Transaction, transaction_id)
    if transaction is None or transaction.user_id != user_id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    return transaction


@router.get("", response_model=TransactionListResponse)
def list_transactions(user: CurrentUser, db: DbSession) -> TransactionListResponse:
    stmt = (
        select(Transaction)
        .where(Transaction.user_id == user.id)
        .order_by(Transaction.date.desc(), Transaction.created_at.desc())
    )
    items = [TransactionOut.model_validate(t) for t in db.scalars(stmt)]
    return TransactionListResponse(data=items)


@router.post("", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def create_transaction(
    body: TransactionIn, user: CurrentUser, db: DbSession
) -> TransactionResponse:
    transaction = Transaction(user_id=user.id, **body.model_dump())
    db.add(transaction)
    db.commit()
    return TransactionResponse(data=TransactionOut.model_validate(transaction))


@router.get("/general-buckets-by-month", response_model=BucketsResponse)
def general_buckets_by_month(
    month: MonthQuery, user: CurrentUser, db: DbSession
) -> BucketsResponse:
    year, month_num = analytics.parse_month(month)
    return BucketsResponse(buckets=analytics.month_buckets(_entries(db, user.id), year, month_num))


@router.get("/category-buckets-by-month", response_model=BucketsResponse)
def category_buckets_by_month(
    category: CategoryQuery, month: MonthQuery, user: CurrentUser, db: DbSession
) -> BucketsResponse:
    year, month_num = analytics.parse_month(month)
    entries = _entries(db, user.id, category)
    return BucketsResponse(buckets=analytics.month_buckets(entries, year, month_num))


@router.get("/general-buckets", response_model=BucketsResponse)
def general_buckets(user: CurrentUser, db: DbSession) -> BucketsResponse:
    return BucketsResponse(buckets=analytics.average_buckets(_entries(db, user.id)))


@router.get("/category-buckets", response_model=BucketsResponse)
def category_buckets(category: CategoryQuery, user: CurrentUser, db: DbSession) -> BucketsResponse:
    return BucketsResponse(buckets=analytics.average_buckets(_entries(db, user.id, category)))


@router.get("/monthly-category-percentages", response_model=CategoryShareResponse)
def monthly_category_percentages(
    month: MonthQuery, user: CurrentUser, db: DbSession
) -> CategoryShareResponse:
    year, month_num = analytics.parse_month(month)
    stmt = select(Transaction.category, Transaction.amount, Transaction.date).where(
        Transaction.user_id == user.id
    )
    entries = [
        (row.category, row.amount)
        for row in db.execute(stmt)
        if row.date.year == year and row.date.month == month_num
    ]
    shares = [CategoryShare.model_validate(s) for s in analytics.category_percentages(entries)]
    return CategoryShareResponse(data=shares)


@router.put("/{transaction_id}", response_model=TransactionResponse)
def update_transaction(
    transaction_id: str, body: TransactionIn, user: CurrentUser, db: DbSession
) -> TransactionResponse:
    transaction = _get_owned(db, user.id, transaction_id)
    for field, value in body.model_dump().items():
        setattr(transaction, field, value)
    db.commit()
    return TransactionResponse(data=TransactionOut.model_validate(transaction))


@router.delete("/{transaction_id}", response_model=MessageResponse)
def delete_transaction(transaction_id: str, user: CurrentUser, db: DbSession) -> MessageResponse:
    db.delete(_get_owned(db, user.id, transaction_id))
    db.commit()
    return MessageResponse(message="Transaction deleted")
