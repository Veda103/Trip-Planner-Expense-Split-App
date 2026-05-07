# ✈️ VGo — Trip Planner & Expense Splitter

A beautiful, playful, and functional Flutter application to plan your trips, manage itineraries, and track expenses with automated splitting logic.

## ✨ Features

- **Trip Management**: Create and search trips with custom participants.
- **Itinerary Planning**: Organize your daily activities with time and descriptions.
- **Expense Tracking**: Log expenses, filter by participant or date.
- **Smart Splitting**: Automatically calculate "who owes whom" using a greedy settlement algorithm.
- **Offline First**: Work seamlessly without internet. All data is saved locally.
- **Aesthetic UI**: Warm playful theme, cursive headings, and smooth transitions.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) (NoSQL)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (Pacifico & Poppins)
- **Connectivity**: [Connectivity Plus](https://pub.dev/packages/connectivity_plus)

## 📂 Project Structure

```text
lib/
├── main.dart               # App entry, theme, and providers
├── models/                 # Data models (Hive adapters)
├── providers/              # Business logic & state management
├── services/               # Hive database operations
├── theme/                  # Design system (colors & styles)
└── screens/                # UI screens (Home, Trips, Expenses, etc.)
```

## 💾 Offline Storage Details

This app uses **Hive**, a lightweight and blazing-fast key-value database written in pure Dart.

### Where is the data stored?
- **Android**: `app_flutter/` directory inside the app's internal storage.
- **iOS**: `Documents/` directory of the app container.
- **Windows**: `Documents/` or app data folder.

Data is persisted as `.hive` files (e.g., `trips.hive`, `expenses.hive`). Even if you close the app or lose internet connection, your data remains safe on your device.

## 🚀 Getting Started

1.  Ensure you have Flutter installed.
2.  Run `flutter pub get` to install dependencies.
3.  Connect a device or start an emulator.
4.  Run `flutter run`.

---
Made with ❤️ for travelers.
