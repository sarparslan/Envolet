# 📱 Envolet – Smart Personal Finance Tracker

[![CI](https://github.com/sarparslan/Envolet/actions/workflows/ci.yml/badge.svg)](https://github.com/sarparslan/Envolet/actions/workflows/ci.yml)

**Envolet** is a personal finance app that helps users track expenses, manage their bank cards and understand their spending habits, with AI-generated saving tips.

The repository contains both parts of the project:

| Folder | Description | Stack |
| --- | --- | --- |
| [`frontend/`](frontend) | Mobile client | Flutter, Provider, fl_chart |
| [`backend/`](backend) | REST API | FastAPI, SQLAlchemy, JWT, OpenRouter |

```
Flutter app  ──HTTP/JSON──▶  FastAPI backend  ──▶  SQLite / any SQLAlchemy DB
                                   │
                                   └──▶  OpenRouter (AI suggestions)
```

The AI provider is only called from the backend, so no API keys ship inside the mobile app.

---

## 🔐 User Authentication

- Register and login with your email and password  
- Sessions are saved automatically (no need to log in again)  
- Secure logout and account deletion  

<p float="left">
  <img src="https://github.com/user-attachments/assets/997681a2-05c3-4c40-bccc-5951730bc2a3" width="250"/>
  <img src="https://github.com/user-attachments/assets/077224e0-ca97-41dd-a68c-c2b36f40f28a" width="250"/>
</p>

---

## 🏠 Home Page

- See your stored financial assets (like bank cards)  
- View your latest 3 transactions  
- Add, edit, or delete your assets easily with user-friendly dialogs  

<p float="left">
  <img src="https://github.com/user-attachments/assets/d84ecd09-f12e-46d1-b11f-c75609794952" width="250"/>
  <img src="https://github.com/user-attachments/assets/4f5f0d72-5756-4b54-9c65-284145bafad5" width="250"/>
</p>

---

## 📈 Tracker Page

- Visualize your financial activity with a line chart  
- Compare monthly spending with overall average  
- Filter results by date and category  
- Get AI-generated saving tips based on your spending (served by the backend)  

<p float="left">
  <img src="https://github.com/user-attachments/assets/9c9a6058-568d-48d0-bb95-1bbaebde2e62" width="250"/>
  <img src="https://github.com/user-attachments/assets/f35636a1-c756-437f-bcfd-dc925ae8b2c8" width="250"/>
</p>

---

## 🥧 Analytics Tab

- See how your spending is distributed across categories  
- Interactive pie chart visualization  
- Helps you understand where most of your money goes  

<p float="left">
  <img src="https://github.com/user-attachments/assets/69bb0375-a0e1-47de-b43c-361c10a16b05" width="250"/>
  <img src="https://github.com/user-attachments/assets/7abbf3dc-ffd7-4c18-a0f2-610cc78576b4" width="250"/>
</p>

---

## ➕ Transactions

- Add transactions with amount, category, and date  
- Update or delete transactions anytime  
- Choose from various currencies (USD, EUR, TL, GBP, JPY, CHF)  
- Clean and responsive input dialogs with category icons  

<p float="left">
  <img src="https://github.com/user-attachments/assets/e8cc0a6f-8871-48b5-8a11-7edd09536b8f" width="250"/>
  <img src="https://github.com/user-attachments/assets/85b0169e-2fd2-4dbd-bff3-ad10de1450f1" width="250"/>
</p>

---

## 🚀 Quick Start

**1. Start the backend** (Python 3.11+, [uv](https://docs.astral.sh/uv/)):

```bash
cd backend
cp .env.example .env
uv sync
uv run uvicorn app.main:app --reload --port 5001
```

API docs are then available at http://localhost:5001/docs.

**2. Run the app** (Flutter 3.x):

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5001
```

On an Android emulator use `http://10.0.2.2:5001` instead of `localhost`.

See [`backend/README.md`](backend/README.md) and [`frontend/README.md`](frontend/README.md) for configuration, project structure and tests.

## 🧪 Tests

```bash
cd backend && uv run pytest && uv run ruff check .
cd frontend && flutter analyze && flutter test
```

Both suites run on every push via GitHub Actions.
