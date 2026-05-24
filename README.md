# Quotify

A daily quotes application built with Flutter, featuring a glassmorphism design language and multi-source quote aggregation. Quotify retrieves content from the ZenQuotes and Quotable APIs with automatic offline fallback to a curated local library, ensuring uninterrupted access to inspirational content across all connectivity states.

Delivered as an internship project for **CodeAlpha** — May 2026.

---

## Features

- **Multi-source Quote Delivery** — Aggregates quotes from ZenQuotes and Quotable APIs with automatic retry logic and graceful degradation to 70+ offline quotes when network is unavailable
- **Favorites and Collections** — Persistent storage of preferred quotes with support for custom collections, search, and sort by author, category, or date
- **Image-based Sharing** — Renders quotes as styled images via the screenshot package for sharing on social media and messaging platforms
- **Adaptive Theming** — Full dark and light mode support with animated transitions; bottom navigation bar with safe-area-aware layout for iOS
- **Scheduled Notifications** — Configurable daily reminders using flutter_local_notifications with timezone-aware scheduling
- **Category and Mood Filtering** — Browse quotes across seven categories (Motivated, Calm, Funny, Sad, Love, Success, Growth) with client-side filtering
- **Android Home Screen Widget** — Displays a rotating quote on the home screen via the home_widget package

---

## Technology Stack

| Layer | Dependency |
|-------|-----------|
| Framework | Flutter 3.41 / Dart 3.11 |
| State Management | flutter_riverpod |
| Local Persistence | hive, shared_preferences |
| HTTP Client | http |
| Notifications | flutter_local_notifications, timezone |
| Typography | google_fonts (Playfair Display, Lato) |
| Animation | flutter_animate |
| Image Capture | screenshot |
| Sharing | share_plus |
| Home Widget | home_widget |
| Static Analysis | flutter_lints |

---

## Screenshots

| Quote Feed | Favorites | Collections / Settings |
|:---:|:---:|:---:|
| *Placeholder* | *Placeholder* | *Placeholder* |

---

## Setup

### Prerequisites

- Flutter SDK >= 3.29.0
- Dart SDK >= 3.5.0
- Android SDK (for APK builds) or Xcode (for iOS builds)

### Installation

```bash
git clone https://github.com/Khalifa125/code_alpha_Quotify.git
cd code_alpha_Quotify

cp .env.example .env
flutter pub get
flutter run
```

### Release Builds

```bash
# Android
flutter build apk --release

# iOS (unsigned simulator)
flutter build ios --simulator --no-codesign

# iOS (unsigned release)
flutter build ios --release --no-codesign
```

---

## Architecture

```
lib/
├── core/utils/              Color and gradient utilities
├── data/                    Offline quote corpus
├── features/
│   ├── favorites/           Favorites list, search, sort
│   ├── onboarding/          First-launch experience
│   ├── quotes/              Quote display, action sheet, card widget
│   ├── settings/            Theme toggle, notifications, collections
│   └── splash/              Animated splash with async initialization
├── models/                  Quote and Collection data classes
├── screens/                 Tab-based root navigation
├── services/                Quote service, notifications, home widget
├── storage/                 Hive-backed favorites persistence
├── theme/                   Light and dark ThemeData definitions
├── widgets/                 Reusable glassmorphism components
├── providers.dart           Centralised Riverpod state providers
└── main.dart                Application entry point
```

State management follows the Riverpod pattern: `StateNotifier` classes encapsulate business logic while `Provider` and `StateProvider` instances expose reactive state to the widget tree.

---

## License

This project is submitted as an internship deliverable for **CodeAlpha**. Not licensed for commercial distribution.
