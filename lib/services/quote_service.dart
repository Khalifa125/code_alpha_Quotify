import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quotes_data.dart';
import '../models/quote.dart';

class QuoteService {
  final http.Client _client;
  final Random _random = Random();
  
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/random';
  static const String _quotableUrl = 'https://api.quotable.io/random';
  static const Duration _timeout = Duration(seconds: 3);
  static const int _maxRetries = 1;
  static const String _cacheKey = 'cached_quote';
  static const int _cacheLimit = 10;

  final List<Quote> _quoteCache = [];
  bool _isPrefetching = false;

  static const List<String> categories = [
    'All', 'Motivated', 'Calm', 'Funny', 'Sad', 'Love', 'Success', 'Growth'
  ];

  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Quote>> fetchQuotes() async {
    final offlineQuotes = _getOfflineQuotes();
    try {
      final quote = await _fetchWithRetry();
      if (quote != null) {
        _addToCache(quote);
        await _saveToPrefs(quote);
        return [quote, ...offlineQuotes];
      }
    } catch (_) {}
    final shuffled = List<Quote>.from(offlineQuotes)..shuffle(_random);
    return shuffled;
  }

  Future<Quote?> _fetchWithRetry() async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final quote = await _fetchFromApi();
        if (quote != null) return quote;
      } catch (_) {
        if (i < _maxRetries - 1) {
          final delay = Duration(milliseconds: 200 * (i + 1));
          await Future<void>.delayed(delay);
        }
      }
    }
    try {
      return await _fetchFromQuotable();
    } catch (_) {
      return null;
    }
  }

  Future<Quote?> _fetchFromApi() async {
    final response = await _client.get(Uri.parse(_zenQuotesUrl)).timeout(_timeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Quote(
          text: data[0]['q'] ?? '',
          author: data[0]['a'] ?? 'Unknown',
          category: _assignRandomCategory(),
        );
      }
    }
    return null;
  }

  Future<Quote?> _fetchFromQuotable() async {
    final response = await _client.get(Uri.parse(_quotableUrl)).timeout(_timeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Quote(
        text: data['content'] ?? '',
        author: data['author'] ?? 'Unknown',
        category: _assignRandomCategory(),
      );
    }
    return null;
  }

  void prefetch() {
    if (_isPrefetching) return;
    _isPrefetching = true;
    Future.microtask(() async {
      try {
        final quote = await _fetchWithRetry();
        if (quote != null) {
          _addToCache(quote);
        }
      } finally {
        _isPrefetching = false;
      }
    });
  }

  void _addToCache(Quote quote) {
    _quoteCache.removeWhere((q) => q.text == quote.text);
    _quoteCache.insert(0, quote);
    if (_quoteCache.length > _cacheLimit) {
      _quoteCache.removeLast();
    }
  }

  List<Quote> getCachedQuotes() => List.from(_quoteCache);

  Future<void> _saveToPrefs(Quote quote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode({
        'text': quote.text,
        'author': quote.author,
        'category': quote.category,
      }));
    } catch (_) {}
  }

  Future<Quote?> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cacheKey);
      if (json != null) {
        final data = jsonDecode(json);
        return Quote(
          text: data['text'] ?? '',
          author: data['author'] ?? 'Unknown',
          category: data['category'] ?? 'Motivated',
        );
      }
    } catch (_) {}
    return null;
  }

  Future<Quote?> getCachedQuote() => _loadFromPrefs();

  String _assignRandomCategory() {
    final cats = categories.where((c) => c != 'All').toList();
    return cats[_random.nextInt(cats.length)];
  }

  List<Quote> _getOfflineQuotes() => parseOfflineQuotes();

  static const Map<String, String> _categoryTags = {
    'Motivated': 'motivation',
    'Calm': 'calm',
    'Funny': 'humor',
    'Sad': 'sadness',
    'Love': 'love',
    'Success': 'success',
    'Growth': 'growth',
  };

  Future<List<Quote>> fetchByCategory(String category) async {
    if (category == 'All') return fetchQuotes();
    final offline = _getOfflineQuotes().where((q) => q.category == category).toList();
    final tag = _categoryTags[category] ?? category.toLowerCase();
    try {
      final url = '$_quotableUrl?tags=$tag';
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data is List ? data : (data['results'] ?? [data]);
        if (results.isNotEmpty) {
          final quote = Quote(
            text: results[0]['content'] ?? results[0]['q'] ?? '',
            author: results[0]['author'] ?? 'Unknown',
            category: category,
          );
          _addToCache(quote);
          return [quote, ...offline.where((q) => q.text != quote.text)];
        }
      }
    } catch (_) {}
    if (offline.isEmpty) {
      final allQuotes = await fetchQuotes();
      if (allQuotes.isNotEmpty) {
        final quote = allQuotes.first;
        return [Quote(text: quote.text, author: quote.author, category: category)];
      }
    }
    return offline;
  }

  void dispose() {
    _client.close();
  }
}