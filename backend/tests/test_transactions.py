from fastapi.testclient import TestClient

from tests.conftest import add_transaction, register


def test_create_and_list(client: TestClient, auth_headers: dict[str, str]) -> None:
    created = add_transaction(client, auth_headers, 12.5, "Food & Drinks", "2025-06-03")
    assert set(created) == {"_id", "amount", "category", "date"}
    assert created["amount"] == 12.5
    assert created["date"] == "2025-06-03"
    assert len(created["_id"]) == 32

    add_transaction(client, auth_headers, 30, "Bills", "2025-06-20")
    add_transaction(client, auth_headers, 5, "Travel", "2025-05-01")

    response = client.get("/transactions", headers=auth_headers)
    assert response.status_code == 200
    dates = [t["date"] for t in response.json()["data"]]
    assert dates == ["2025-06-20", "2025-06-03", "2025-05-01"]


def test_update_and_delete(client: TestClient, auth_headers: dict[str, str]) -> None:
    tx = add_transaction(client, auth_headers, 10, "Health", "2025-06-01")

    response = client.put(
        f"/transactions/{tx['_id']}",
        json={"amount": 42, "category": "Shopping", "date": "2025-07-15"},
        headers=auth_headers,
    )
    assert response.status_code == 200
    assert response.json()["data"] == {
        "_id": tx["_id"],
        "amount": 42.0,
        "category": "Shopping",
        "date": "2025-07-15",
    }

    response = client.delete(f"/transactions/{tx['_id']}", headers=auth_headers)
    assert response.status_code == 200
    assert "message" in response.json()
    assert client.get("/transactions", headers=auth_headers).json() == {"data": []}

    missing = client.delete(f"/transactions/{tx['_id']}", headers=auth_headers)
    assert missing.status_code == 404


def test_validation(client: TestClient, auth_headers: dict[str, str]) -> None:
    bad_bodies = [
        {"amount": 0, "category": "Bills", "date": "2025-06-01"},
        {"amount": -5, "category": "Bills", "date": "2025-06-01"},
        {"amount": 5, "category": "Groceries", "date": "2025-06-01"},
        {"amount": 5, "category": "Bills", "date": "2025-13-01"},
        {"amount": 5, "category": "Bills"},
    ]
    for body in bad_bodies:
        response = client.post("/transactions", json=body, headers=auth_headers)
        assert response.status_code == 422, body


def test_ownership_isolation(client: TestClient) -> None:
    alice = register(client, "alice@example.com")
    bob = register(client, "bob@example.com")
    tx = add_transaction(client, alice, 10, "Bills", "2025-06-01")

    assert client.get("/transactions", headers=bob).json() == {"data": []}

    body = {"amount": 1, "category": "Bills", "date": "2025-06-01"}
    assert client.put(f"/transactions/{tx['_id']}", json=body, headers=bob).status_code == 404
    assert client.delete(f"/transactions/{tx['_id']}", headers=bob).status_code == 404

    assert len(client.get("/transactions", headers=alice).json()["data"]) == 1
