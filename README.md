# 📱 Envolet

[![CI](https://github.com/sarparslan/Envolet/actions/workflows/ci.yml/badge.svg)](https://github.com/sarparslan/Envolet/actions/workflows/ci.yml)

A personal finance tracker: log expenses, manage your bank cards, see where your money goes and get AI-generated saving tips.

## Screens

**Authentication** – register, log in, stay signed in; log out or delete your account.

<p float="left">
  <img src="https://github.com/user-attachments/assets/997681a2-05c3-4c40-bccc-5951730bc2a3" width="250"/>
  <img src="https://github.com/user-attachments/assets/077224e0-ca97-41dd-a68c-c2b36f40f28a" width="250"/>
</p>

**Home** – your cards and the latest 3 transactions; add, edit or delete cards.

<p float="left">
  <img src="https://github.com/user-attachments/assets/d84ecd09-f12e-46d1-b11f-c75609794952" width="250"/>
  <img src="https://github.com/user-attachments/assets/4f5f0d72-5756-4b54-9c65-284145bafad5" width="250"/>
</p>

**Tracker** – this month's spending vs. your average, filtered by month and category, with an AI saving tip.

<p float="left">
  <img src="https://github.com/user-attachments/assets/9c9a6058-568d-48d0-bb95-1bbaebde2e62" width="250"/>
  <img src="https://github.com/user-attachments/assets/f35636a1-c756-437f-bcfd-dc925ae8b2c8" width="250"/>
</p>

**Analytics** – how your spending splits across categories.

<p float="left">
  <img src="https://github.com/user-attachments/assets/69bb0375-a0e1-47de-b43c-361c10a16b05" width="250"/>
  <img src="https://github.com/user-attachments/assets/7abbf3dc-ffd7-4c18-a0f2-610cc78576b4" width="250"/>
</p>

**Transactions** – add, edit and delete expenses in USD, EUR, TL, GBP, JPY or CHF.

<p float="left">
  <img src="https://github.com/user-attachments/assets/e8cc0a6f-8871-48b5-8a11-7edd09536b8f" width="250"/>
  <img src="https://github.com/user-attachments/assets/85b0169e-2fd2-4dbd-bff3-ad10de1450f1" width="250"/>
</p>

## Architecture

![System overview](docs/diagrams/architecture.svg)

| Folder | Stack |
| --- | --- |
| [`frontend/`](frontend) | Flutter, Provider, fl_chart |
| [`backend/`](backend) | FastAPI, SQLAlchemy, JWT, OpenRouter |

The AI provider is only called from the backend, so no API keys ship inside the app. More diagrams (session flow, auth, spending analytics, tracker page) are in [`docs/diagrams/`](docs/diagrams).

## Quick start

```bash
cd backend && cp .env.example .env && uv sync
uv run uvicorn app.main:app --reload --port 5001
```

```bash
cd frontend && flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5001
```

API docs: http://localhost:5001/docs. On an Android emulator use `http://10.0.2.2:5001`.

## Tests

```bash
cd backend && uv run pytest && uv run ruff check .
cd frontend && flutter analyze && flutter test
```

Both run on every push via GitHub Actions.
