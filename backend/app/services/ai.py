"""OpenRouter client used to generate spending suggestions."""

from typing import Protocol

import httpx

from app.core.config import Settings

PROMPT_TEMPLATE = (
    "The user selected the category: {category} for the month: {month}.\n\n"
    "They spent {month_total} {currency} in this month, while their average monthly "
    "spending is {monthly_average} {currency}.\n\n"
    "Based on this, briefly suggest a friendly, actionable, and sustainable way they can "
    "reduce or improve spending in this category.\n\n"
    "Keep the response short and clear — strictly no more than 3 sentences. "
    "Avoid numeric advice. Focus on helpful habits like cooking at home, using public "
    "transport, or spending more time in nature."
)


class AIServiceError(Exception):
    """Raised when the upstream model provider fails or returns an unusable response."""


class AINotConfiguredError(AIServiceError):
    """Raised when no API key is configured."""


class SuggestionClient(Protocol):
    def complete(self, prompt: str) -> str: ...


def format_number(value: float) -> str:
    """Format a number without a trailing ``.0`` for whole values."""
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.2f}".rstrip("0").rstrip(".")


def build_prompt(
    category: str, month: str, month_total: float, monthly_average: float, currency: str
) -> str:
    return PROMPT_TEMPLATE.format(
        category=category,
        month=month,
        month_total=format_number(month_total),
        monthly_average=format_number(monthly_average),
        currency=currency,
    )


class OpenRouterClient:
    def __init__(self, settings: Settings, http_client: httpx.Client | None = None) -> None:
        self._settings = settings
        self._http_client = http_client

    def complete(self, prompt: str) -> str:
        if not self._settings.openrouter_api_key:
            raise AINotConfiguredError("OPENROUTER_API_KEY is not configured")

        payload = {
            "model": self._settings.openrouter_model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 100,
            "temperature": 0.7,
        }
        headers = {
            "Authorization": f"Bearer {self._settings.openrouter_api_key}",
            "Content-Type": "application/json",
        }
        client = self._http_client or httpx.Client(
            timeout=self._settings.openrouter_timeout_seconds
        )
        try:
            response = client.post(self._settings.openrouter_url, json=payload, headers=headers)
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
        except (httpx.HTTPError, ValueError, KeyError, IndexError, TypeError) as exc:
            raise AIServiceError(f"OpenRouter request failed: {exc}") from exc
        finally:
            if self._http_client is None:
                client.close()

        if not isinstance(content, str) or not content.strip():
            raise AIServiceError("OpenRouter returned an empty response")
        return content.strip()
