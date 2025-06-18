# Envolet – Flutter Client

Mobile client for Envolet. It talks to the FastAPI service in [`../backend`](../backend).

## Tech Stack

- **Flutter / Dart 3**
- **Provider** for app-wide state (session, user settings)
- **http** with a typed `ApiService` and model classes
- **flutter_secure_storage** for the auth token (Keychain / Keystore)
- **shared_preferences** for non-sensitive preferences such as currency
- **fl_chart** for line and pie charts

## Project Structure

```
lib/
├── core/          # App-wide constants (categories, currencies, colors)
├── models/        # Typed API models: User, Transaction, Asset, CategoryShare
├── providers/     # SessionProvider, SettingsProvider (ChangeNotifier)
├── screens/       # Home, Tracker, Transactions, Settings, auth/
├── services/      # ApiService (REST client) and TokenStorage
├── utils/         # Dialogs, navigation, formatters, validators
├── widgets/       # Reusable UI (cards, forms, nav bar, tracker charts)
└── main.dart      # Dependency setup and MaterialApp
test/              # Unit and widget tests
```

`ApiService` receives its `http.Client` and `TokenStorage` through the constructor,
so tests can use `MockClient` and an in-memory token store without any network access.

## Getting Started

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5001
```

| Variable       | Description                     | Default                 |
| -------------- | ------------------------------- | ----------------------- |
| `API_BASE_URL` | Base URL of the Envolet backend | `http://localhost:5001` |

The OpenRouter key for AI suggestions is configured on the backend, not in the app.

## Tests

```bash
flutter analyze
flutter test
```
