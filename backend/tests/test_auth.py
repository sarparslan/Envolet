from fastapi.testclient import TestClient

from tests.conftest import add_transaction, register

USER = {"name": "Jane", "surname": "Doe", "email": "jane@example.com", "password": "secret123"}


def test_health(client: TestClient) -> None:
    assert client.get("/health").json() == {"status": "ok"}


def test_register_returns_token_and_user(client: TestClient) -> None:
    response = client.post("/auth/register", json=USER)
    assert response.status_code == 201
    body = response.json()
    assert isinstance(body["token"], str) and body["token"]
    assert body["user"] == {"name": "Jane", "surname": "Doe", "email": "jane@example.com"}


def test_register_duplicate_email_conflicts(client: TestClient) -> None:
    client.post("/auth/register", json=USER)
    response = client.post("/auth/register", json={**USER, "email": "JANE@example.com"})
    assert response.status_code == 409


def test_register_validation(client: TestClient) -> None:
    assert client.post("/auth/register", json={**USER, "password": "123"}).status_code == 422
    assert client.post("/auth/register", json={**USER, "email": "nope"}).status_code == 422


def test_register_allows_single_word_names(client: TestClient) -> None:
    response = client.post("/auth/register", json={**USER, "surname": ""})
    assert response.status_code == 201
    assert response.json()["user"]["surname"] == ""
    assert client.post("/auth/register", json={**USER, "name": " "}).status_code == 422


def test_login_success_and_failure(client: TestClient) -> None:
    client.post("/auth/register", json=USER)

    ok = client.post("/auth/login", json={"email": USER["email"], "password": USER["password"]})
    assert ok.status_code == 200
    assert ok.json()["user"]["email"] == USER["email"]
    assert ok.json()["token"]

    bad = client.post("/auth/login", json={"email": USER["email"], "password": "wrongpass"})
    assert bad.status_code == 401

    unknown = client.post("/auth/login", json={"email": "x@example.com", "password": "secret123"})
    assert unknown.status_code == 401


def test_me_requires_valid_token(client: TestClient, auth_headers: dict[str, str]) -> None:
    response = client.get("/auth/me", headers=auth_headers)
    assert response.status_code == 200
    assert response.json() == {
        "user": {"name": "Jane", "surname": "Doe", "email": "jane@example.com"}
    }

    assert client.get("/auth/me").status_code == 401
    assert client.get("/auth/me", headers={"Authorization": "Bearer garbage"}).status_code == 401


def test_protected_endpoints_require_auth(client: TestClient) -> None:
    for method, path in [
        ("get", "/transactions"),
        ("get", "/assets"),
        ("get", "/transactions/general-buckets"),
        ("post", "/ai/suggestion"),
        ("delete", "/auth/delete"),
    ]:
        assert getattr(client, method)(path).status_code == 401, path


def test_delete_account_cascades(client: TestClient, auth_headers: dict[str, str]) -> None:
    add_transaction(client, auth_headers, 10, "Food & Drinks", "2025-06-01")
    client.post(
        "/assets",
        json={
            "bankName": "Bank",
            "amount": 100,
            "lastFourDigits": "1234",
            "brand": "Visa",
            "color": "#FF1E88E5",
        },
        headers=auth_headers,
    )

    response = client.delete("/auth/delete", headers=auth_headers)
    assert response.status_code == 200
    assert "message" in response.json()

    assert client.get("/auth/me", headers=auth_headers).status_code == 401
    login = client.post("/auth/login", json={"email": USER["email"], "password": USER["password"]})
    assert login.status_code == 401

    # Re-registering with the same email starts with a clean slate.
    headers = register(client)
    assert client.get("/transactions", headers=headers).json() == {"data": []}
    assert client.get("/assets", headers=headers).json() == {"data": []}
