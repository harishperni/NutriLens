# NutriLens Flutter App (MVP)

This Flutter app connects to the NutriLens FastAPI backend and includes:

- Login and register
- Dashboard with calories/macros/water progress
- Food search and quick meal logging
- Quick hydration logging

## 1. Install Flutter SDK

Android Studio alone is not enough. Install Flutter SDK first.

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/macos/mobile-android
2. Unzip, for example to `~/development/flutter`
3. Add Flutter to PATH in your shell config:

```bash
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

4. Verify:

```bash
flutter --version
flutter doctor
```

## 2. Configure Android Studio

1. Open Android Studio
2. Install plugins:
   - Flutter
   - Dart
3. Open `Preferences > Languages & Frameworks > Flutter`
4. Set Flutter SDK path (example: `~/development/flutter`)
5. Accept Android licenses:

```bash
flutter doctor --android-licenses
```

6. Create an Android emulator from `Device Manager` and start it

## 3. Run backend first

In one terminal:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The app uses `http://10.0.2.2:8000` so Android emulator can reach host backend.

## 4. Run Flutter app

In another terminal:

```bash
cd mobile
flutter pub get
flutter run
```

## 5. First test flow

1. Register a user
2. Search `oats` in food search
3. Log food
4. Add water with `+250ml`
5. Return to dashboard and refresh

## 6. Project structure

- `lib/main.dart`: app root and auth state
- `lib/src/api_client.dart`: HTTP API client
- `lib/src/models.dart`: app models
- `lib/src/screens/login_screen.dart`: login/register
- `lib/src/screens/dashboard_screen.dart`: daily summary
- `lib/src/screens/food_search_screen.dart`: search and meal logging

