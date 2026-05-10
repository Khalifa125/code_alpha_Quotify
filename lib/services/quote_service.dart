import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class QuoteService {
  final http.Client _client;
  final Random _random = Random();
  
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/random';
  static const String _quotableUrl = 'https://api.quotable.io/random';
  static const Duration _timeout = Duration(seconds: 4);
  static const int _maxRetries = 2;
  static const String _cacheKey = 'cached_quote';
  static const int _cacheLimit = 10;

  final List<Quote> _quoteCache = [];
  bool _isPrefetching = false;

  static const List<Map<String, String>> _offlineQuotes = [
    {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs', 'category': 'Motivated'},
    {'text': 'In the middle of difficulty lies opportunity.', 'author': 'Albert Einstein', 'category': 'Calm'},
    {'text': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt', 'category': 'Motivated'},
    {'text': 'The future belongs to those who believe in the beauty of their dreams.', 'author': 'Eleanor Roosevelt', 'category': 'Growth'},
    {'text': 'It is during our darkest moments that we must focus to see the light.', 'author': 'Aristotle', 'category': 'Calm'},
    {'text': 'The best time to plant a tree was 20 years ago. The second best time is now.', 'author': 'Chinese Proverb', 'category': 'Growth'},
    {'text': 'Success is not final, failure is not fatal: it is the courage to continue that counts.', 'author': 'Winston Churchill', 'category': 'Success'},
    {'text': 'Be yourself; everyone else is already taken.', 'author': 'Oscar Wilde', 'category': 'Growth'},
    {'text': 'In three words I can sum up everything I\'ve learned about life: it goes on.', 'author': 'Robert Frost', 'category': 'Calm'},
    {'text': 'The greatest glory in living lies not in never falling, but in rising every time we fall.', 'author': 'Nelson Mandela', 'category': 'Success'},
    {'text': 'Life is what happens when you\'re busy making other plans.', 'author': 'John Lennon', 'category': 'Calm'},
    {'text': 'The way to get started is to quit talking and begin doing.', 'author': 'Walt Disney', 'category': 'Motivated'},
    {'text': 'You don\'t have to be great to start, but you have to start to be great.', 'author': 'Zig Ziglar', 'category': 'Motivated'},
    {'text': 'Either you run the day or the day runs you.', 'author': 'Jim Rohn', 'category': 'Motivated'},
    {'text': 'The only limit to our realization of tomorrow will be our doubts of today.', 'author': 'Franklin D. Roosevelt', 'category': 'Success'},
    {'text': 'Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.', 'author': 'Christian D. Larson', 'category': 'Motivated'},
    {'text': 'The best revenge is massive success.', 'author': 'Frank Sinatra', 'category': 'Success'},
    {'text': 'Whether you think you can or think you can\'t, you\'re right.', 'author': 'Henry Ford', 'category': 'Motivated'},
    {'text': 'The only person you are destined to become is the person you decide to be.', 'author': 'Ralph Waldo Emerson', 'category': 'Growth'},
    {'text': 'Nothing is impossible, the word itself says "I\'m possible"!', 'author': 'Audrey Hepburn', 'category': 'Motivated'},
    {'text': 'Your time is limited, don\'t waste it living someone else\'s life.', 'author': 'Steve Jobs', 'category': 'Growth'},
    {'text': 'I have not failed. I\'ve just found 10,000 ways that won\'t work.', 'author': 'Thomas A. Edison', 'category': 'Success'},
    {'text': 'A person who never made a mistake never tried anything new.', 'author': 'Albert Einstein', 'category': 'Growth'},
    {'text': 'What lies behind us and what lies before us are tiny matters compared to what lies within us.', 'author': 'Ralph Waldo Emerson', 'category': 'Calm'},
    {'text': 'Happiness is not something ready made. It comes from your own actions.', 'author': 'Dalai Lama', 'category': 'Calm'},
    {'text': 'Be the change you wish to see in the world.', 'author': 'Mahatma Gandhi', 'category': 'Success'},
    {'text': 'The mind is everything. What you think you become.', 'author': 'Buddha', 'category': 'Growth'},
    {'text': 'Start where you are. Use what you have. Do what you can.', 'author': 'Arthur Ashe', 'category': 'Motivated'},
    {'text': 'Every strike brings me closer to the next home run.', 'author': 'Babe Ruth', 'category': 'Success'},
    {'text': 'Dream big and dare to fail.', 'author': 'Norman Vaughan', 'category': 'Motivated'},
    {'text': 'The only journey is the one within.', 'author': 'Rainer Maria Rilke', 'category': 'Calm'},
    {'text': 'In the depth of winter, I finally learned that within me there lay an invincible summer.', 'author': 'Albert Camus', 'category': 'Calm'},
    {'text': 'The greatest wealth is to live content with little.', 'author': 'Plato', 'category': 'Calm'},
    {'text': 'Knowledge speaks, but wisdom listens.', 'author': 'Jimi Hendrix', 'category': 'Growth'},
    {'text': 'The only true wisdom is in knowing you know nothing.', 'author': 'Socrates', 'category': 'Growth'},
    {'text': 'Education is the most powerful weapon which you can use to change the world.', 'author': 'Nelson Mandela', 'category': 'Success'},
    {'text': 'You miss 100% of the shots you don\'t take.', 'author': 'Wayne Gretzky', 'category': 'Motivated'},
    {'text': 'Act as if what you do makes a difference. It does.', 'author': 'William James', 'category': 'Motivated'},
    {'text': 'Try not to become a man of success. Rather become a man of value.', 'author': 'Albert Einstein', 'category': 'Growth'},
    {'text': 'Two roads diverged in a wood, and I—I took the one less traveled by.', 'author': 'Robert Frost', 'category': 'Growth'},
    {'text': 'The beautiful thing about learning is that no one can take it away from you.', 'author': 'B.B. King', 'category': 'Growth'},
    {'text': 'Live as if you were to die tomorrow. Learn as if you were to live forever.', 'author': 'Mahatma Gandhi', 'category': 'Growth'},
    {'text': 'Where there is love there is life.', 'author': 'Mahatma Gandhi', 'category': 'Love'},
    {'text': 'Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.', 'author': 'Unknown', 'category': 'Love'},
    {'text': 'The best thing to hold onto in life is each other.', 'author': 'Audrey Hepburn', 'category': 'Love'},
    {'text': 'Love is composed of a single soul inhabiting two bodies.', 'author': 'Aristotle', 'category': 'Love'},
    {'text': 'To love and be loved is to feel the sun from both sides.', 'author': 'Vince Gimondo', 'category': 'Love'},
    {'text': 'Sadness is also a kind of defense.', 'author': 'Kafka', 'category': 'Sad'},
    {'text': 'All the world is a stage, and all the men and women merely players.', 'author': 'Shakespeare', 'category': 'Funny'},
    {'text': 'Behind every great man is a woman rolling her eyes.', 'author': 'Jim Carrey', 'category': 'Funny'},
    {'text': 'I used to think I was indecisive, but now I\'m not so sure.', 'author': 'Unknown', 'category': 'Funny'},
    {'text': 'The road to success is always under construction.', 'author': 'Lily Tomlin', 'category': 'Success'},
    {'text': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson', 'category': 'Success'},
    {'text': 'Success is not the key to happiness. Happiness is the key to success.', 'author': 'Albert Schweitzer', 'category': 'Success'},
    {'text': 'Hard times don\'t create heroes. It is during the hard times when the \'hero\' within us is revealed.', 'author': 'Bob Riley', 'category': 'Motivated'},
    {'text': 'Growth is painful. Change is painful. But nothing is as painful as staying stuck.', 'author': 'Unknown', 'category': 'Growth'},
    {'text': 'The only way to achieve the impossible is to believe it is possible.', 'author': 'Charles Kingsley', 'category': 'Motivated'},
    {'text': 'In the garden of life, patience is the seed, faith is the water, and growth is the harvest.', 'author': 'Unknown', 'category': 'Growth'},
    {'text': 'Calm mind brings inner strength and self-confidence.', 'author': 'Dalai Lama', 'category': 'Calm'},
    {'text': 'Almost everything will work again if you unplug it for a few minutes, including you.', 'author': 'Anne Lamott', 'category': 'Calm'},
    {'text': 'Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.', 'author': 'Thich Nhat Hanh', 'category': 'Calm'},
    {'text': 'The greatest gift you can give yourself is a little bit of your own attention.', 'author': 'Anthony J. D\'Angelo', 'category': 'Growth'},
    {'text': 'Personal growth is not a function of age or experience but of commitment to learning.', 'author': 'Stephen Covey', 'category': 'Growth'},
    {'text': 'Every day is a chance to grow. Every challenge is an opportunity to learn.', 'author': 'Unknown', 'category': 'Growth'},
    {'text': 'Success is not how high you have climbed, but how you make a positive difference to the world.', 'author': 'Roy T. Bennett', 'category': 'Success'},
    {'text': 'The only person you should try to be better than is the person you were yesterday.', 'author': 'Unknown', 'category': 'Growth'},
    {'text': 'Motivation is what gets you started. Habit is what keeps you going.', 'author': 'Jim Ryun', 'category': 'Motivated'},
    {'text': 'You don\'t have to be born a leader. You can learn to be one.', 'author': 'Brian Tracy', 'category': 'Success'},
    {'text': 'The successful warrior is the average man, with laser-like focus.', 'author': 'Bruce Lee', 'category': 'Success'},
    {'text': 'Focus on being productive instead of busy.', 'author': 'Tim Ferriss', 'category': 'Success'},
    {'text': 'The only thing that stands between you and your dream is the will to try and the belief that it is actually possible.', 'author': 'Joel Brown', 'category': 'Motivated'},
    {'text': 'Your limitation—it\'s only your imagination.', 'author': 'Unknown', 'category': 'Motivated'},
    {'text': 'Push yourself, because no one else is going to do it for you.', 'author': 'Unknown', 'category': 'Motivated'},
  ];

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
    final cached = await _loadFromPrefs();
    if (cached != null) {
      return [cached, ...offlineQuotes.where((q) => q.text != cached.text)];
    }
    return offlineQuotes;
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

  List<Quote> _getOfflineQuotes() {
    return _offlineQuotes.map((q) => Quote(
      text: q['text']!,
      author: q['author']!,
      category: q['category']!,
    )).toList();
  }

  Future<List<Quote>> fetchByCategory(String category) async {
    if (category == 'All') return _getOfflineQuotes();
    return _getOfflineQuotes().where((q) => q.category == category).toList();
  }

  void dispose() {
    _client.close();
  }
}