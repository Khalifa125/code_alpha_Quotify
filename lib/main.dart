import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'providers.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: '.env');

  await Future.wait([
    Hive.initFlutter(),
    _initNotificationService(),
  ]);

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(ProviderScope(
    child: QuotifyApp(showOnboarding: !onboardingComplete),
  ));
}

Future<void> _initNotificationService() async {
  try {
    await NotificationService().init();
  } catch (_) {}
}

class QuotifyApp extends ConsumerWidget {
  final bool showOnboarding;

  const QuotifyApp({super.key, this.showOnboarding = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return AnimatedTheme(
      data: themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      duration: const Duration(milliseconds: 300),
      child: MaterialApp(
        title: 'Quotify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: showOnboarding ? '/onboarding' : '/home',
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}
