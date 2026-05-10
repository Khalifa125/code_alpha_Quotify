import 'dart:math';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';
import '../models/collection.dart';
import '../services/quote_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../storage/favorites_storage.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final widgetServiceProvider = Provider<WidgetService>((ref) => WidgetService());

final notificationsEnabledProvider = StateProvider<bool>((ref) => false);
final notificationHourProvider = StateProvider<int>((ref) => 8);
final notificationMinuteProvider = StateProvider<int>((ref) => 0);
final homeWidgetEnabledProvider = StateProvider<bool>((ref) => false);

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final showSwipeHintProvider = StateProvider<bool>((ref) => true);

final searchQueryProvider = StateProvider<String>((ref) => '');

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) => FavoritesStorage());

class FavoritesNotifier extends StateNotifier<List<Quote>> {
  final FavoritesStorage _storage;

  FavoritesNotifier(this._storage) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _storage.init();
    state = _storage.getFavorites();
  }

  bool isFavorite(Quote quote) {
    return state.any((q) => q.text == quote.text && q.author == quote.author);
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (isFavorite(quote)) {
      await _storage.removeFavorite(quote);
    } else {
      await _storage.addFavorite(quote);
    }
    state = List.from(_storage.getFavorites());
  }

  Future<void> removeFavorite(Quote quote) async {
    await _storage.removeFavorite(quote);
    state = List.from(_storage.getFavorites());
  }

  Future<void> restoreFavorite(Quote quote) async {
    await _storage.addFavorite(quote);
    state = List.from(_storage.getFavorites());
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Quote>>((ref) {
  final storage = ref.watch(favoritesStorageProvider);
  return FavoritesNotifier(storage);
});

final collectionsProvider = StateNotifierProvider<CollectionsNotifier, List<Collection>>((ref) {
  return CollectionsNotifier();
});

class CollectionsNotifier extends StateNotifier<List<Collection>> {
  CollectionsNotifier() : super([]) {
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionsJson = prefs.getStringList('collections') ?? [];
    state = collectionsJson.map((json) {
      final parts = json.split('|');
      return Collection(
        id: parts[0],
        name: parts[1],
        quoteIds: parts[2].split(',').where((s) => s.isNotEmpty).toList(),
        createdAt: DateTime.parse(parts[3]),
      );
    }).toList();
  }

  Future<void> _saveCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionsJson = state.map((c) =>
      '${c.id}|${c.name}|${c.quoteIds.join(',')}|${c.createdAt.toIso8601String()}'
    ).toList();
    await prefs.setStringList('collections', collectionsJson);
  }

  Future<void> createCollection(String name) async {
    final collection = Collection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quoteIds: [],
      createdAt: DateTime.now(),
    );
    state = [...state, collection];
    await _saveCollections();
  }

  Future<void> addQuoteToCollection(String collectionId, String quoteId) async {
    state = state.map((c) {
      if (c.id == collectionId && !c.quoteIds.contains(quoteId)) {
        return c.copyWith(
          quoteIds: [...c.quoteIds, quoteId],
          coverQuoteId: quoteId,
        );
      }
      return c;
    }).toList();
    await _saveCollections();
  }

  Future<void> removeQuoteFromCollection(String collectionId, String quoteId) async {
    state = state.map((c) {
      if (c.id == collectionId) {
        final newIds = c.quoteIds.where((id) => id != quoteId).toList();
        return c.copyWith(quoteIds: newIds);
      }
      return c;
    }).toList();
    await _saveCollections();
  }

  Future<void> deleteCollection(String collectionId) async {
    state = state.where((c) => c.id != collectionId).toList();
    await _saveCollections();
  }
}

final quoteServiceProvider = Provider<QuoteService>((ref) {
  final service = QuoteService();
  ref.onDispose(() => service.dispose());
  return service;
});

class QuoteState {
  final Quote? quote;
  final List<Quote> quotes;
  final bool isLoading;
  final String? error;
  final int gradientIndex;
  final List<Quote> cachedQuotes;

  const QuoteState({
    this.quote,
    this.quotes = const [],
    this.isLoading = false,
    this.error,
    this.gradientIndex = 0,
    this.cachedQuotes = const [],
  });

  QuoteState copyWith({
    Quote? quote,
    List<Quote>? quotes,
    bool? isLoading,
    String? error,
    int? gradientIndex,
    List<Quote>? cachedQuotes,
    bool clearError = false,
  }) {
    return QuoteState(
      quote: quote ?? this.quote,
      quotes: quotes ?? this.quotes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      gradientIndex: gradientIndex ?? this.gradientIndex,
      cachedQuotes: cachedQuotes ?? this.cachedQuotes,
    );
  }
}

class QuoteController extends StateNotifier<QuoteState> {
  final QuoteService _service;
  final Random _random = Random();
  final List<Quote> _history = [];
  int _historyIndex = -1;

  QuoteController(this._service) : super(const QuoteState()) {
    _init();
  }

  int _gradientIndex = 0;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final cached = await _service.getCachedQuote();
    if (cached != null) {
      _addToHistory(cached);
      _gradientIndex = _random.nextInt(6);
      state = state.copyWith(
        quote: cached,
        quotes: [cached, ..._service.getCachedQuotes()],
        isLoading: false,
        gradientIndex: _gradientIndex,
      );
    } else {
      await fetchQuote();
    }
    _service.prefetch();
  }

  void _addToHistory(Quote quote) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(quote);
    if (_history.length > 10) {
      _history.removeAt(0);
    }
    _historyIndex = _history.length - 1;
  }

  Future<void> fetchQuote() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final quotes = await _service.fetchQuotes();
      _gradientIndex = _random.nextInt(6);
      final quote = quotes.isNotEmpty ? quotes.first : null;
      if (quote != null) {
        _addToHistory(quote);
      }
      state = state.copyWith(
        quote: quote,
        quotes: quotes,
        isLoading: false,
        gradientIndex: _gradientIndex,
        cachedQuotes: _service.getCachedQuotes(),
      );
      HapticFeedback.mediumImpact();
      _service.prefetch();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Couldn't load quote. Showing a saved one.",
      );
    }
  }

  Future<void> fetchByCategory(String category) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final quotes = await _service.fetchByCategory(category);
      _gradientIndex = _random.nextInt(6);
      state = state.copyWith(
        quote: quotes.isNotEmpty ? quotes.first : null,
        quotes: quotes,
        isLoading: false,
        gradientIndex: _gradientIndex,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void nextQuote() {
    if (state.quotes.isEmpty) return;
    final currentIndex = state.quote != null
        ? state.quotes.indexWhere((q) => q.text == state.quote!.text)
        : -1;
    final nextIndex = (currentIndex + 1) % state.quotes.length;
    _gradientIndex = _random.nextInt(6);
    final quote = state.quotes[nextIndex];
    _addToHistory(quote);
    state = state.copyWith(
      quote: quote,
      gradientIndex: _gradientIndex,
    );
    HapticFeedback.lightImpact();
    _service.prefetch();
  }

  void previousQuote() {
    if (_history.isNotEmpty && _historyIndex > 0) {
      _historyIndex--;
      _gradientIndex = _random.nextInt(6);
      state = state.copyWith(
        quote: _history[_historyIndex],
        gradientIndex: _gradientIndex,
      );
      HapticFeedback.lightImpact();
      return;
    }
    if (state.quotes.isEmpty) return;
    final currentIndex = state.quote != null
        ? state.quotes.indexWhere((q) => q.text == state.quote!.text)
        : 0;
    final prevIndex = currentIndex > 0 ? currentIndex - 1 : state.quotes.length - 1;
    _gradientIndex = _random.nextInt(6);
    final quote = state.quotes[prevIndex];
    _addToHistory(quote);
    state = state.copyWith(
      quote: quote,
      gradientIndex: _gradientIndex,
    );
    HapticFeedback.lightImpact();
  }
}

final quoteControllerProvider = StateNotifierProvider<QuoteController, QuoteState>((ref) {
  final service = ref.watch(quoteServiceProvider);
  return QuoteController(service);
});