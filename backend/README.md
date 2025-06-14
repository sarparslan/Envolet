# Envolet Backend

REST API for **Envolet**, a personal finance tracker. It provides authentication,
expense tracking, bank-card (asset) management, spending analytics and AI-generated
saving suggestions for the Envolet Flutter client.

## Tech stack

- **FastAPI** with **pydantic v2** for request/response validation
- **SQLAlchemy 2.0** (typed `Mapped[]` models), SQLite by default
- **pydantic-settings** for configuration from environment variables / `.env`
- **PyJWT** (HS256 bearer tokens) and **bcrypt** for password hashing
- **httpx** for the OpenRouter chat-completions call
- **pytest** + FastAPI `TestClient`, **ruff** for linting and formatting
- **uv** for dependency management, plus a small **Dockerfile**

## Project layout

```
backend/
├── app/
│   ├── main.py             # App factory, CORS, lifespan (creates tables), /health
│   ├── db.py               # Engine, session factory, declarative base
│   ├── models.py           # User, Transaction, Asset
│   ├── dependencies.py     # DB session, current user, AI client dependencies
│   ├── core/
│   │   ├── config.py       # Settings
│   │   └── security.py     # bcrypt hashing, JWT encode/decode
│   ├── schemas/            # Pydantic request/response models
│   ├── routers/            # auth, transactions, assets, ai
│   └── services/
│       ├── analytics.py    # Pure bucket / percentage calculations
│       └── ai.py           # Prompt builder and OpenRouter client
├── tests/                  # pytest suite (isolated in-memory SQLite per test)
├── pyproject.toml
├── Dockerfile
└── .env.example
```

## Getting started

Requires Python 3.11+.

With [uv](https://docs.astral.sh/uv/):

```bash
cd backend
cp .env.example .env        # then set JWT_SECRET (and OPENROUTER_API_KEY if needed)
uv sync
uv run uvicorn app.main:app --reload --port 5001
```

With plain pip:

```bash
cd backend
python3.11 -m venv .venv && source .venv/bin/activate
pip install -e . pytest ruff
uvicorn app.main:app --reload --port 5001
```

The API is served at `http://localhost:5001` (the client's default base URL).
Interactive docs are available at `/docs`. Tables are created automatically on startup.

With Docker:

```bash
docker build -t envolet-backend .
docker run -p 5001:5001 --env-file .env envolet-backend
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `DATABASE_URL` | `sqlite:///./envolet.db` | SQLAlchemy database URL |
| `JWT_SECRET` | insecure dev value | Secret used to sign tokens. **Set this in any real deployment**; a warning is logged when the default is used |
| `JWT_ALGORITHM` | `HS256` | JWT signing algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `10080` (7 days) | Token lifetime |
| `OPENROUTER_API_KEY` | _empty_ | OpenRouter API key. When empty, `/ai/suggestion` returns `503` |
| `OPENROUTER_MODEL` | `google/gemini-2.0-flash-exp:free` | Model used for suggestions |
| `CORS_ORIGINS` | `*` | Comma-separated list of allowed origins |

## Testing and linting

```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
```

Each test runs against its own in-memory SQLite database, and the AI client is replaced
with a fake through FastAPI dependency overrides, so the suite needs no network access.

## API

All endpoints except `/health`, `/auth/register` and `/auth/login` require an
`Authorization: Bearer <token>` header and return `401` otherwise. Resource IDs are
UUID4 hex strings returned under the `_id` key. Requests for another user's resources
return `404`. Validation errors return `422`.

| Method | Path | Description |
| --- | --- | --- |
| GET | `/health` | Liveness check |
| POST | `/auth/register` | Create an account → `201 {token, user}`; `409` if the email exists |
| POST | `/auth/login` | Log in → `200 {token, user}`; `401` on bad credentials |
| GET | `/auth/me` | Current user → `{user}` |
| DELETE | `/auth/delete` | Delete the account with all its transactions and assets |
| GET | `/transactions` | List transactions, newest first → `{data: [...]}` |
| POST | `/transactions` | Create a transaction `{amount, category, date}` → `201 {data}` |
| PUT | `/transactions/{id}` | Update a transaction → `{data}` |
| DELETE | `/transactions/{id}` | Delete a transaction → `{message}` |
| GET | `/transactions/general-buckets-by-month?month=YYYY-MM` | Spending per day-bucket for one month |
| GET | `/transactions/category-buckets-by-month?category=X&month=YYYY-MM` | Same, for one category |
| GET | `/transactions/general-buckets` | Average per-bucket spending across active months |
| GET | `/transactions/category-buckets?category=X` | Same, for one category |
| GET | `/transactions/monthly-category-percentages?month=YYYY-MM` | Category share of a month's spending |
| GET | `/assets` | List bank cards → `{data: [...]}` |
| POST | `/assets` | Create a card `{bankName, amount, lastFourDigits, brand, color}` → `201 {data}` |
| PUT | `/assets/{id}` | Update a card → `{data}` |
| DELETE | `/assets/{id}` | Delete a card → `{message}` |
| POST | `/ai/suggestion` | Generate a short saving tip → `{suggestion}` |

### Notes

- **Categories:** `Food & Drinks`, `Transportation`, `Housing`, `Bills`, `Health`,
  `Entertainment`, `Shopping`, `Education`, `Travel`. Transaction amounts must be positive;
  dates use `YYYY-MM-DD`.
- **Day buckets:** a month is split into days 1–6, 7–12, 13–18, 19–24 and 25–31. Bucket
  endpoints return `{"buckets": [five floats]}`. The averaged variants sum each bucket per
  month and divide by the number of months that contain at least one matching transaction.
- **AI suggestions:** the request body is
  `{category, month, monthTotal, monthlyAverage, currency}`, where `category` is `General`
  or one of the categories above and `month` is a display label such as `Jun 2025`. The
  server builds the prompt and calls OpenRouter, so the API key never reaches the client.
  Upstream failures and timeouts return `502`.
