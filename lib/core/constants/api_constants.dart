class ApiConstants {
  static const String baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String model = 'claude-sonnet-4-20250514';
  static const String anthropicVersion = '2023-06-01';
  static const int maxTokens = 300;
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

class AppConstants {
  static const String appName = 'Quotify';
  static const int gradientCount = 8;
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
}