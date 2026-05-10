// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/utils/gradient_helper.dart';
import 'features/quotes/screens/quote_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'providers.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';

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

  runApp(const ProviderScope(child: QuotifyApp()));
}

Future<void> _initNotificationService() async {
  try {
    await NotificationService().init();
  } catch (_) {}
}

class QuotifyApp extends ConsumerWidget {
  const QuotifyApp({super.key});

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
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    FavoritesScreen(),
    QuoteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0A1A), Color(0xFF151025)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F5FC), Color(0xFFEEEDF5)],
                ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        favoritesCount: favorites.length,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
