from collections.abc import Iterator

import httpx
import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.dependencies import get_suggestion_client
from app.main import app
from app.services.ai import AIServiceError, OpenRouterClient, build_prompt

BODY = {
    "category": "Food & Drinks",
    "month": "Jun 2025",
    "monthTotal": 320.0,
    "monthlyAverage": 250.75,
    "currency": "EUR",
}


class FakeClient:
    def __init__(self, reply: str = "  Try cooking at home.  ", error: Exception | None = None):
        self.reply = reply
        self.error = error
        self.prompts: list[str] = []

    def complete(self, prompt: str) -> str:
        self.prompts.append(prompt)
        if self.error:
            raise self.error
        return self.reply.strip()


@pytest.fixture
def fake_client() -> Iterator[FakeClient]:
    fake = FakeClient()
    app.dependency_overrides[get_suggestion_client] = lambda: fake
    yield fake
    app.dependency_overrides.pop(get_suggestion_client, None)


def test_build_prompt_formats_numbers_and_currency() -> None:
    prompt = build_prompt("Bills", "Jun 2025", 320.0, 250.75, "USD")
    assert prompt.startswith("The user selected the category: Bills for the month: Jun 2025.")
    assert (
        "They spent 320 USD in this month, while their average monthly spending is 250.75 USD."
        in prompt
    )
    assert "$" not in prompt


def test_suggestion_success(
    client: TestClient, auth_headers: dict[str, str], fake_client: FakeClient
) -> None:
    response = client.post("/ai/suggestion", json=BODY, headers=auth_headers)
    assert response.status_code == 200
    assert response.json() == {"suggestion": "Try cooking at home."}
    assert "Food & Drinks" in fake_client.prompts[0]
    assert "320 EUR" in fake_client.prompts[0]


def test_suggestion_upstream_error_returns_502(
    client: TestClient, auth_headers: dict[str, str], fake_client: FakeClient
) -> None:
    fake_client.error = AIServiceError("boom")
    response = client.post("/ai/suggestion", json=BODY, headers=auth_headers)
    assert response.status_code == 502


def test_suggestion_missing_key_returns_503(
    client: TestClient, auth_headers: dict[str, str]
) -> None:
    app.dependency_overrides[get_suggestion_client] = lambda: OpenRouterClient(
        Settings(openrouter_api_key=None)
    )
    try:
        response = client.post("/ai/suggestion", json=BODY, headers=auth_headers)
    finally:
        app.dependency_overrides.pop(get_suggestion_client, None)
    assert response.status_code == 503
    assert "OPENROUTER_API_KEY" in response.json()["detail"]


def test_suggestion_validation(
    client: TestClient, auth_headers: dict[str, str], fake_client: FakeClient
) -> None:
    for override in [{"category": "Nope"}, {"monthTotal": "abc"}, {"currency": ""}]:
        response = client.post("/ai/suggestion", json={**BODY, **override}, headers=auth_headers)
        assert response.status_code == 422, override

    general = client.post(
        "/ai/suggestion", json={**BODY, "category": "General"}, headers=auth_headers
    )
    assert general.status_code == 200


def test_openrouter_client_request_shape() -> None:
    captured: dict = {}

    def handler(request: httpx.Request) -> httpx.Response:
        captured["auth"] = request.headers["Authorization"]
        captured["json"] = request.read()
        return httpx.Response(200, json={"choices": [{"message": {"content": "  Hi there. "}}]})

    settings = Settings(openrouter_api_key="sk-test", openrouter_model="test/model")
    http = httpx.Client(transport=httpx.MockTransport(handler))
    assert OpenRouterClient(settings, http).complete("prompt") == "Hi there."
    assert captured["auth"] == "Bearer sk-test"
    assert b'"model":"test/model"' in captured["json"].replace(b" ", b"")
    assert b'"max_tokens":100' in captured["json"].replace(b" ", b"")


def test_openrouter_client_upstream_failure() -> None:
    settings = Settings(openrouter_api_key="sk-test")
    http = httpx.Client(transport=httpx.MockTransport(lambda _: httpx.Response(500)))
    with pytest.raises(AIServiceError):
        OpenRouterClient(settings, http).complete("prompt")

    def timeout(_: httpx.Request) -> httpx.Response:
        raise httpx.ReadTimeout("timed out")

    http = httpx.Client(transport=httpx.MockTransport(timeout))
    with pytest.raises(AIServiceError):
        OpenRouterClient(settings, http).complete("prompt")
