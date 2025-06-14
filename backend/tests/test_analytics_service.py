import datetime as dt

import pytest

from app.services.analytics import (
    average_buckets,
    bucket_index,
    category_percentages,
    month_buckets,
    parse_month,
)


@pytest.mark.parametrize(
    ("day", "expected"),
    [(1, 0), (6, 0), (7, 1), (12, 1), (13, 2), (18, 2), (19, 3), (24, 3), (25, 4), (31, 4)],
)
def test_bucket_boundaries(day: int, expected: int) -> None:
    assert bucket_index(day) == expected


@pytest.mark.parametrize("day", [0, 32])
def test_bucket_index_rejects_invalid_day(day: int) -> None:
    with pytest.raises(ValueError):
        bucket_index(day)


def test_parse_month() -> None:
    assert parse_month("2025-06") == (2025, 6)
    with pytest.raises(ValueError):
        parse_month("2025-13")


def test_month_buckets_only_counts_that_month() -> None:
    entries = [
        (dt.date(2025, 6, 1), 10.0),
        (dt.date(2025, 6, 6), 5.0),
        (dt.date(2025, 6, 7), 3.0),
        (dt.date(2025, 6, 18), 2.0),
        (dt.date(2025, 6, 19), 4.0),
        (dt.date(2025, 6, 30), 7.0),
        (dt.date(2025, 7, 1), 100.0),
        (dt.date(2024, 6, 1), 100.0),
    ]
    assert month_buckets(entries, 2025, 6) == [15.0, 3.0, 2.0, 4.0, 7.0]


def test_month_buckets_empty() -> None:
    assert month_buckets([], 2025, 6) == [0.0] * 5


def test_average_buckets_over_active_months() -> None:
    entries = [
        (dt.date(2025, 5, 2), 10.0),
        (dt.date(2025, 5, 26), 20.0),
        (dt.date(2025, 6, 3), 30.0),
        (dt.date(2025, 6, 14), 9.0),
    ]
    # Two active months: bucket 0 = (10 + 30) / 2, bucket 2 = 9 / 2, bucket 4 = 20 / 2.
    assert average_buckets(entries) == [20.0, 0.0, 4.5, 0.0, 10.0]


def test_average_buckets_empty() -> None:
    assert average_buckets([]) == [0.0] * 5


def test_category_percentages() -> None:
    result = category_percentages(
        [("Bills", 50.0), ("Food & Drinks", 25.0), ("Bills", 25.0), ("Travel", 0.0)]
    )
    assert result == [
        {"category": "Bills", "total": 75.0, "percentage": 75.0},
        {"category": "Food & Drinks", "total": 25.0, "percentage": 25.0},
    ]
    assert category_percentages([]) == []
