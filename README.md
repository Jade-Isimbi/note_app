# Notes App

A Flutter notes app with Firebase authentication and Firestore database.

## Architecture

```
UI (Screens) → BLoC (State Management) → Repository → Firebase
```

## Quick Start

1. **Setup**
   ```bash
   git clone note_app
   cd notes_app
   flutter pub get
   ```

2. **Firebase Setup**
   - Create Firebase project
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Add `google-services.json` to `android/app/`

3. **Run**
   ```bash
   flutter run
   ```

## Build Commands

```bash
# Development
flutter run

# Production
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart
├── blocs/          # State management
├── models/         # Data models
├── repositories/   # Firebase operations
├── screens/        # UI screens
└── widgets/        # Reusable components
```

## Troubleshooting

**Firebase Web Issues:**
```bash
flutter clean
flutter pub get
```

**Android Build Issues:**
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter run
```

## Dependencies

- `flutter_bloc` - State management
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
