# Quotify

A beautifully crafted daily quotes app that delivers curated inspiration to your fingertips. Built with Flutter and a glassmorphism design language, Quotify fetches quotes from multiple APIs with a seamless offline fallback — so you always have something meaningful to read, save, and share.

Built as part of an internship program at **CodeAlpha** (May 2026).

---

## Features

- 📜 **Daily Quotes** — Fetches from ZenQuotes and Quotable APIs; falls back to a curated offline library of 70+ quotes when offline
- ❤️ **Favorites & Collections** — Save quotes, organize them into custom collections, sort and search by author or category
- 📸 **Share as Image** — Capture any quote as a gorgeous styled image and share it anywhere
- 🌗 **Adaptive Theme** — Dark and light modes with animated transitions and an iOS-fitted bottom nav bar
- 🔔 **Daily Reminders** — Schedule a daily notification with your favourite quote at a time that suits you
- 🏠 **Home Widget** — Android home screen widget that shows a fresh quote on every glance
- 🎨 **Mood Browsing** — Filter quotes by mood or category (Motivated, Calm, Funny, Sad, Love, Success, Growth)

---

## Built With

| Layer | Tool |
|-------|------|
| Framework | Flutter 3.41 / Dart 3.11 |
| State Management | flutter_riverpod |
| Local Storage | hive, shared_preferences |
| Networking | http |
| Notifications | flutter_local_notifications, timezone |
| Typography | google_fonts (Playfair Display + Lato) |
| Animations | flutter_animate, Lottie-style custom animations |
| Sharing | share_plus, screenshot |
| Home Widget | home_widget |
| Linting | flutter_lints |

---

## Screenshots

| Quote Screen | Favorites | Collections |
|:---:|:---:|:---:|
| *Coming soon* | *Coming soon* | *Coming soon* |

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.29.0
- Dart SDK >= 3.5.0
- An Android or iOS device / emulator

### Setup

```bash
# Clone the repository
git clone https://github.com/Khalifa125/code_alpha_Quotify.git
cd code_alpha_Quotify

# Create environment file
cp .env.example .env

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# iOS (unsigned, simulator)
flutter build ios --simulator --no-codesign

# iOS (unsigned, release)
flutter build ios --release --no-codesign
```

---

## Project Structure

```
lib/
├── core/utils/          # Gradient helpers, color utilities
├── data/                # Offline quotes data source
├── features/
│   ├── favorites/       # Favorites screen + logic
│   ├── onboarding/      # First-run onboarding flow
│   ├── quotes/          # Quote display, modern quote card
│   ├── settings/        # Theme, notifications, collections
│   └── splash/          # Animated splash screen
├── models/              # Quote & Collection data models
├── screens/             # Main screen with tab navigation
├── services/            # Quote API, notifications, home widget
├── storage/             # Hive-based favorites persistence
├── theme/               # Light & dark theme definitions
├── widgets/             # Reusable glassmorphism widgets
├── main.dart            # App entry point
└── providers.dart       # Centralised Riverpod providers
```

---

## License

This project is submitted as an internship deliverable for **CodeAlpha**.  
Not licensed for commercial use.
