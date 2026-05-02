# Quotify - Random Quote Generator

A production-ready, premium Flutter application that delivers beautiful, inspiring quotes at the tap of a button. Designed with the same attention to detail as Calm, Notion, and Headspace.

---

## ✨ Premium Features

- **Beautiful Quote Display** - Large, elegant typography with Playfair Display font and decorative quotation mark
- **Glassmorphism Card** - Modern frosted glass effect with subtle blur and shadows
- **Animated Gradient Background** - Soft, shifting gradients that change with each new quote
- **Smooth Transitions** - Fade and slide animations when loading new quotes
- **Skeleton Loading** - Shimmer effect placeholder that mimics the final UI
- **Haptic Feedback** - Light vibrations on button interactions
- **Copy to Clipboard** - One-tap copy with beautiful toast notification
- **Native Sharing** - Share via system share sheet
- **Light & Dark Mode** - Full support for both themes with proper contrast
- **Error Handling** - Friendly error states with illustrations and retry button
- **Retry Logic** - Automatic retry with exponential backoff for failed requests
- **Responsive Design** - Works perfectly on phones and tablets

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/
│   │   └── api_constants.dart   # API configuration
│   ├── error/
│   │   ├── exceptions.dart      # Custom exceptions
│   │   └── failures.dart       # Failure types
│   └── utils/
│       ├── gradient_helper.dart # Gradient utilities
│       └── haptic_utils.dart    # Haptic feedback helper
├── models/
│   └── quote_model.dart         # Quote data model
├── services/
│   └── quote_service.dart      # Anthropic API service
├── controllers/
│   └── quote_controller.dart  # Riverpod state management
├── screens/
│   └── quote_screen.dart       # Main quote screen
├── widgets/
│   ├── quote_card.dart         # Glassmorphism quote card
│   ├── loading_skeleton.dart   # Shimmer loading placeholder
│   ├── error_widget.dart       # Error state with retry
│   ├── gradient_background.dart # Animated gradient
│   └── new_quote_button.dart   # Premium action button
└── theme/
    └── app_theme.dart          # Light/dark themes
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| API | Anthropic Claude (claude-sonnet-4-20250514) |
| Animations | flutter_animate |
| Typography | google_fonts (Playfair Display, Lato) |
| Loading | skeletonizer |
| Sharing | share_plus |
| Environment | flutter_dotenv |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Anthropic API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/CodeAlpha_Quotify.git
   cd CodeAlpha_Quotify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   
   Copy `.env.example` to `.env` and add your API key:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env`:
   ```
   ANTHROPIC_API_KEY=sk-ant-your-actual-api-key-here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔐 API Key Setup

### Step 1: Get Your Anthropic API Key

1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Create an account or sign in
3. Navigate to **API Keys** section
4. Create a new API key
5. Copy the key

### Step 2: Configure the App

The app uses `flutter_dotenv` to securely load your API key:

1. Open the `.env` file in the project root
2. Replace the placeholder with your actual key:
   ```
   ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxxx
   ```

### Important Notes

- Never commit your `.env` file to version control
- The `.env` file is already in `.gitignore`
- If you see an "API key not found" error, verify your `.env` file is correct

---

## 📱 Screenshots

| Light Mode | Dark Mode |
|------------|-----------|
| ![Light Mode](assets/screenshots/light_mode.png) | ![Dark Mode](assets/screenshots/dark_mode.png) |
| **Loading State** | **Error State** |
| ![Loading](assets/screenshots/loading.png) | ![Error](assets/screenshots/error.png) |

---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📦 Building

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

---

## 🎨 Design System

### Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #667eea | Buttons, accents |
| Secondary | #764ba2 | Gradients, highlights |
| Light BG | #F8F9FA | Light mode background |
| Dark BG | #0f0f1a | Dark mode background |

### Typography

- **Quote Text**: Playfair Display, 24-28px
- **Author Name**: Lato, 15px, Italic
- **UI Elements**: Lato, 14-17px

### Animations

- Quote fade-in: 500ms with slide
- Button bounce: 100ms scale
- Background transition: 800ms ease
- Skeleton shimmer: 2000ms loop

---

## 🔧 Configuration

### API Settings

| Setting | Default Value |
|---------|---------------|
| Model | claude-sonnet-4-20250514 |
| Max Tokens | 300 |
| Timeout | 30 seconds |
| Max Retries | 3 |

---

## 📄 License

MIT License - feel free to use this project for any purpose.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🙏 Acknowledgments

- Inspired by Calm, Notion, and Headspace
- Powered by Anthropic Claude API
- Built with Flutter and 💙

---

## 📞 Support

If you encounter any issues, please open an issue on GitHub.

---

**Quotify** - Daily inspiration, beautifully delivered.