"""Pure spending-analytics helpers.

A month is split into five day-buckets: 1-6, 7-12, 13-18, 19-24 and 25-31.
These functions operate on plain ``(date, amount)`` pairs so they are easy to test.
"""

import datetime as dt
from collections import defaultdict
from collections.abc import Iterable

BUCKET_COUNT = 5

Entry = tuple[dt.date, float]


def bucket_index(day: int) -> int:
    """Map a day of month (1-31) to its bucket index (0-4)."""
    if not 1 <= day <= 31:
        raise ValueError(f"day must be between 1 and 31, got {day}")
    return min((day - 1) // 6, BUCKET_COUNT - 1)


def parse_month(month: str) -> tuple[int, int]:
    """Parse a ``YYYY-MM`` string into ``(year, month)``."""
    year_str, month_str = month.split("-")
    year, month_num = int(year_str), int(month_str)
    if not 1 <= month_num <= 12:
        raise ValueError(f"invalid month: {month}")
    return year, month_num


def month_buckets(entries: Iterable[Entry], year: int, month: int) -> list[float]:
    """Sum amounts per bucket for a single calendar month."""
    buckets = [0.0] * BUCKET_COUNT
    for day, amount in entries:
        if day.year == year and day.month == month:
            buckets[bucket_index(day.day)] += amount
    return [round(value, 2) for value in buckets]


def average_buckets(entries: Iterable[Entry]) -> list[float]:
    """Average per-bucket spending over every month that has at least one entry."""
    per_month: dict[tuple[int, int], list[float]] = defaultdict(lambda: [0.0] * BUCKET_COUNT)
    for day, amount in entries:
        per_month[(day.year, day.month)][bucket_index(day.day)] += amount

    if not per_month:
        return [0.0] * BUCKET_COUNT

    months = len(per_month)
    totals = [sum(buckets[i] for buckets in per_month.values()) for i in range(BUCKET_COUNT)]
    return [round(total / months, 2) for total in totals]


def category_percentages(entries: Iterable[tuple[str, float]]) -> list[dict[str, float | str]]:
    """Return each category's total and share of overall spending, largest first."""
    totals: dict[str, float] = defaultdict(float)
    for category, amount in entries:
        totals[category] += amount

    grand_total = sum(totals.values())
    if grand_total <= 0:
        return []

    shares = [
        {
            "category": category,
            "total": round(total, 2),
            "percentage": round(total / grand_total * 100, 2),
        }
        for category, total in totals.items()
        if total > 0
    ]
    shares.sort(key=lambda item: (-float(item["total"]), str(item["category"])))
    return shares
