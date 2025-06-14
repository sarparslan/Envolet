import pytest
from fastapi.testclient import TestClient

from tests.conftest import add_transaction, register


@pytest.fixture
def seeded(client: TestClient, auth_headers: dict[str, str]) -> dict[str, str]:
    rows = [
        (10, "Food & Drinks", "2025-06-01"),
        (20, "Food & Drinks", "2025-06-06"),
        (5, "Bills", "2025-06-07"),
        (7, "Food & Drinks", "2025-06-12"),
        (3, "Food & Drinks", "2025-06-13"),
        (4, "Bills", "2025-06-18"),
        (6, "Food & Drinks", "2025-06-19"),
        (8, "Food & Drinks", "2025-06-24"),
        (10, "Travel", "2025-06-25"),
        (1, "Food & Drinks", "2025-06-30"),
        (40, "Food & Drinks", "2025-05-02"),
        (12, "Bills", "2025-04-28"),
    ]
    for amount, category, date in rows:
        add_transaction(client, auth_headers, amount, category, date)
    return auth_headers


def test_general_buckets_by_month(client: TestClient, seeded: dict[str, str]) -> None:
    response = client.get(
        "/transactions/general-buckets-by-month", params={"month": "2025-06"}, headers=seeded
    )
    assert response.status_code == 200
    assert response.json() == {"buckets": [30.0, 12.0, 7.0, 14.0, 11.0]}


def test_category_buckets_by_month(client: TestClient, seeded: dict[str, str]) -> None:
    response = client.get(
        "/transactions/category-buckets-by-month",
        params={"month": "2025-06", "category": "Food & Drinks"},
        headers=seeded,
    )
    assert response.status_code == 200
    assert response.json() == {"buckets": [30.0, 7.0, 3.0, 14.0, 1.0]}


def test_general_buckets_average(client: TestClient, seeded: dict[str, str]) -> None:
    # Three active months (Apr, May, Jun).
    response = client.get("/transactions/general-buckets", headers=seeded)
    assert response.status_code == 200
    assert response.json() == {"buckets": [23.33, 4.0, 2.33, 4.67, 7.67]}


def test_category_buckets_average(client: TestClient, seeded: dict[str, str]) -> None:
    # Food & Drinks appears in two months (May, Jun).
    response = client.get(
        "/transactions/category-buckets", params={"category": "Food & Drinks"}, headers=seeded
    )
    assert response.status_code == 200
    assert response.json() == {"buckets": [35.0, 3.5, 1.5, 7.0, 0.5]}


def test_buckets_empty_user(client: TestClient) -> None:
    headers = register(client, "empty@example.com")
    assert client.get("/transactions/general-buckets", headers=headers).json() == {
        "buckets": [0.0] * 5
    }
    response = client.get(
        "/transactions/general-buckets-by-month", params={"month": "2025-06"}, headers=headers
    )
    assert response.json() == {"buckets": [0.0] * 5}


def test_monthly_category_percentages(client: TestClient, seeded: dict[str, str]) -> None:
    response = client.get(
        "/transactions/monthly-category-percentages", params={"month": "2025-06"}, headers=seeded
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert [item["category"] for item in data] == ["Food & Drinks", "Travel", "Bills"]
    assert data[0] == {"category": "Food & Drinks", "total": 55.0, "percentage": 74.32}
    assert sum(item["percentage"] for item in data) == pytest.approx(100, abs=0.05)

    empty = client.get(
        "/transactions/monthly-category-percentages", params={"month": "2020-01"}, headers=seeded
    )
    assert empty.json() == {"data": []}


def test_analytics_isolated_per_user(client: TestClient, seeded: dict[str, str]) -> None:
    other = register(client, "other@example.com")
    response = client.get(
        "/transactions/general-buckets-by-month", params={"month": "2025-06"}, headers=other
    )
    assert response.json() == {"buckets": [0.0] * 5}


@pytest.mark.parametrize("month", ["2025-6", "2025-13", "June", "2025-06-01", ""])
def test_invalid_month_rejected(
    client: TestClient, auth_headers: dict[str, str], month: str
) -> None:
    response = client.get(
        "/transactions/general-buckets-by-month", params={"month": month}, headers=auth_headers
    )
    assert response.status_code == 422


def test_invalid_category_rejected(client: TestClient, auth_headers: dict[str, str]) -> None:
    response = client.get(
        "/transactions/category-buckets", params={"category": "Nope"}, headers=auth_headers
    )
    assert response.status_code == 422
