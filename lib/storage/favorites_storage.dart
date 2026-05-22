import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';

class FavoritesStorage {
  static const String _boxName = 'favorites';
  late Box<Map<dynamic, dynamic>> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    _initialized = true;
  }

  List<Quote> getFavorites() {
    final quotes = <Quote>[];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        quotes.add(Quote.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return quotes.reversed.toList();
  }

  Future<void> addFavorite(Quote quote) async {
    final key = _generateKey(quote);
    if (!_box.containsKey(key)) {
      await _box.put(key, quote.toJson());
    }
  }

  Future<void> removeFavorite(Quote quote) async {
    final key = _generateKey(quote);
    await _box.delete(key);
  }

  String _generateKey(Quote quote) {
    return '${quote.text.hashCode}_${quote.author.hashCode}';
  }

}