# Quotify - Daily Quotes

A premium Flutter daily quotes app with glassmorphism UI, Riverpod state management, and iOS/Android support.

## Features

- **Daily Quotes** — Fetch inspiring quotes with one tap, swipe between them
- **Glassmorphism Design** — Frosted glass cards, blur effects, gradient backgrounds
- **Mood Categories** — Filter quotes by mood (Motivation, Calm, Love, Success, etc.)
- **Favorites** — Save quotes, sort by newest/oldest/author/category, search
- **Collections** — Organize quotes into custom collections
- **Daily Notifications** — Schedule a daily quote notification at your preferred time
- **Share** — Share quotes as text or image
- **Light & Dark Mode** — Full theme support with smooth 300ms transition
- **Offline Support** — Cached quotes work without internet
- **Onboarding** — 4-page intro with glass cards and staggered animations

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.29 (Dart 3.5+) |
| State | Riverpod (StateNotifier + StateProvider) |
| Animations | flutter_animate, built-in AnimationController |
| Typography | Google Fonts (Playfair Display, Lato) |
| Storage | Hive (favorites), SharedPreferences (settings) |
| Notifications | flutter_local_notifications + timezone |
| Sharing | share_plus + screenshot |

## Architecture

```
lib/
├── main.dart
├── providers.dart              # All Riverpod providers
├── screens/main_screen.dart    # Tab scaffold with AnimatedSwitcher
├── core/utils/
│   └── gradient_helper.dart    # Gradients, glass colors, text colors
├── theme/
│   └── app_theme.dart          # Light/dark ThemeData with glass-aware themes
├── models/
│   ├── quote.dart
│   └── collection.dart
├── services/
│   ├── quote_service.dart      # API fetching with retry + fallback
│   ├── notification_service.dart
│   └── widget_service.dart
├── storage/
│   └── favorites_storage.dart  # Hive-backed persistence
├── features/
│   ├── onboarding/screens/     # OnboardingScreen (PageView + GlassCard)
│   ├── quotes/
│   │   ├── screens/            # QuoteScreen (search, mood chips, card)
│   │   └── widgets/            # ModernQuoteCard, FavoriteButtonWidget
│   ├── favorites/screens/      # FavoritesScreen (sort, search, glass cards)
│   └── settings/screens/       # SettingsScreen (theme, notifications, collections)
└── widgets/
    ├── glass_container.dart    # GlassContainer, GlassCard, GlassIconContainer
    ├── bottom_nav_bar.dart     # Glass nav bar with scale animation
    ├── mood_chips.dart         # Horizontal chip list with spring bounce
    ├── new_quote_button.dart   # Shimmer button with scale press
    ├── loading_skeleton.dart   # Shimmer placeholder
    └── error_widget.dart       # Error state with retry
```

## Getting Started

### Prerequisites

- Flutter SDK 3.29+
- Dart SDK 3.5+
- API key (configured via `.env`)

### Installation

```bash
git clone https://github.com/Khalifa125/code_alpha_Quotify.git
cd code_alpha_Quotify
flutter pub get
```

Copy `.env.example` to `.env` and add your API key, then run:

```bash
flutter run
```

### Building

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

## Design System

- **Primary**: `#8B5CF6` (purple) / `#6366F1` (indigo)
- **Glass** — Cards use `BackdropFilter` + `ImageFilter.blur` (sigma 8-12)
- **Glass opacity** — Light: 0.3-0.5 frosted white; Dark: 0.04-0.06 subtle tint
- **Border radius** — Consistent 20px on cards, 14px on buttons
- **Typography** — Playfair Display for quotes/headlines, Lato for body/UI
- **Staggered animations** — 500ms fadeIn + slideY with 100-200ms delays

## License

MIT
