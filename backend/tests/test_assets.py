from fastapi.testclient import TestClient

from tests.conftest import register

CARD = {
    "bankName": "Envo Bank",
    "amount": 1500,
    "lastFourDigits": "4242",
    "brand": "Visa",
    "color": "#FF1E88E5",
}


def test_asset_crud(client: TestClient, auth_headers: dict[str, str]) -> None:
    response = client.post("/assets", json=CARD, headers=auth_headers)
    assert response.status_code == 201
    asset = response.json()["data"]
    assert asset == {"_id": asset["_id"], **CARD}

    listed = client.get("/assets", headers=auth_headers).json()["data"]
    assert listed == [asset]

    updated_body = {**CARD, "amount": 0, "color": "FF000000", "brand": "Mastercard"}
    response = client.put(f"/assets/{asset['_id']}", json=updated_body, headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["data"] == {"_id": asset["_id"], **updated_body}

    response = client.delete(f"/assets/{asset['_id']}", headers=auth_headers)
    assert response.status_code == 200
    assert "message" in response.json()
    assert client.get("/assets", headers=auth_headers).json() == {"data": []}


def test_asset_validation(client: TestClient, auth_headers: dict[str, str]) -> None:
    for override in [{"lastFourDigits": "123"}, {"lastFourDigits": "12a4"}, {"amount": -1}]:
        response = client.post("/assets", json={**CARD, **override}, headers=auth_headers)
        assert response.status_code == 422, override


def test_asset_ownership(client: TestClient) -> None:
    alice = register(client, "alice@example.com")
    bob = register(client, "bob@example.com")
    asset = client.post("/assets", json=CARD, headers=alice).json()["data"]

    assert client.get("/assets", headers=bob).json() == {"data": []}
    assert client.put(f"/assets/{asset['_id']}", json=CARD, headers=bob).status_code == 404
    assert client.delete(f"/assets/{asset['_id']}", headers=bob).status_code == 404
