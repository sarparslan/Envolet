# 📱 Envolet – Smart Personal Finance Tracker

**Envolet** is a mobile application designed to help users manage their finances, track expenses, and make smarter spending decisions — all from a clean, modern interface.

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
- Get smart AI-based suggestions based on your habits  

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

## 🛠 Tech Stack

- **Flutter / Dart** for the cross-platform mobile client
- **REST API** backend with token-based authentication
- **OpenRouter** (Gemini 2.0 Flash) for AI spending suggestions
- **fl_chart** for line and pie charts
- **shared_preferences** for session and user preferences

## 📂 Project Structure

```
lib/
├── auth/        # Login and registration screens
├── models/      # API response models
├── screens/     # Home, Tracker, Transactions, Settings
├── services/    # ApiService – all backend and AI calls
├── utils/       # Globals, dialogs, input formatters
├── widgets/     # Reusable UI components (cards, nav bar, splash)
└── main.dart
test/            # Unit tests
```

## 🚀 Getting Started

**Prerequisites:** Flutter SDK (3.x) and a running instance of the Envolet backend API.

```bash
git clone https://github.com/sarparslan/Envolet.git
cd Envolet
flutter pub get
```

## ⚙️ Configuration

The backend URL and the OpenRouter API key are provided at build time via `--dart-define`, so no secrets are stored in the source code:

| Variable             | Description                        | Default                 |
| -------------------- | ---------------------------------- | ----------------------- |
| `API_BASE_URL`       | Base URL of the Envolet backend    | `http://localhost:5001` |
| `OPENROUTER_API_KEY` | API key used for AI suggestions    | _(empty)_               |

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5001 \
  --dart-define=OPENROUTER_API_KEY=your_openrouter_key
```

## 🧪 Running Tests

```bash
flutter analyze
flutter test
```
