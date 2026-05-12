import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/gradient_helper.dart';
import '../features/quotes/screens/quote_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../providers.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    QuoteScreen(),
    FavoritesScreen(),
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
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
