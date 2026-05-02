import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/error/exceptions.dart';
import '../models/quote_model.dart';

class QuoteService {
  final http.Client _client;
  
  static const String _systemPrompt = '''You are a renowned quote curator and motivational speaker. 
Your mission is to inspire people by sharing wisdom from history's greatest minds.

Generate a single, unique inspirational quote from a famous person (philosopher, scientist, leader, artist, or thinker).
The quote should be:
- Meaningful and thought-provoking
- Timeless and universal
- Relatable to everyday life

Return ONLY valid JSON in this exact format with no additional text:
{"quote": "Your inspirational quote here (keep it to 2-4 sentences)", "author": "Famous Author Name"}

Do NOT include any explanation, markdown, or additional content.''';

  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  Future<Quote> fetchQuote() async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty || apiKey == 'sk-ant-placeholder-key') {
      throw const ApiKeyException('API key not found. Please configure your ANTHROPIC_API_KEY in the .env file.');
    }

    int attempts = 0;
    Duration delay = const Duration(seconds: 1);
    const Duration maxDelay = Duration(seconds: 10);

    while (attempts < ApiConstants.maxRetries) {
      try {
        return await _fetchWithTimeout(apiKey);
      } on TimeoutException {
        attempts++;
        if (attempts >= ApiConstants.maxRetries) {
          throw const TimeoutException('Request timed out. Please check your connection and try again.');
        }
        await Future<void>.delayed(delay);
        final newDelayMs = delay.inMilliseconds * 2;
        delay = Duration(milliseconds: newDelayMs > maxDelay.inMilliseconds ? maxDelay.inMilliseconds : newDelayMs);
      } on http.ClientException catch (e) {
        throw NetworkException('Network error: ${e.message}');
      } catch (e) {
        if (e is QuoteException) rethrow;
        throw ApiException('Unexpected error: ${e.toString()}');
      }
    }
    
    throw const TimeoutException('Maximum retry attempts exceeded.');
  }

  Future<Quote> _fetchWithTimeout(String apiKey) async {
    final response = await _client
        .post(
          Uri.parse(ApiConstants.baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': ApiConstants.anthropicVersion,
          },
          body: jsonEncode({
            'model': ApiConstants.model,
            'max_tokens': ApiConstants.maxTokens,
            'system': _systemPrompt,
            'messages': [
              {
                'role': 'user',
                'content': 'Generate an inspirational quote with its author. Return JSON only.',
              }
            ],
          }),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode == 200) {
      return _parseResponse(response.body);
    } else if (response.statusCode == 401) {
      throw const ApiKeyException('Invalid API key. Please check your ANTHROPIC_API_KEY.');
    } else if (response.statusCode == 429) {
      throw const ApiException('Rate limit exceeded. Please wait a moment and try again.', statusCode: 429);
    } else if (response.statusCode >= 500) {
      throw const ApiException('Server error. Please try again later.', statusCode: 500);
    } else {
      throw ApiException('Failed to fetch quote. Status: ${response.statusCode}', statusCode: response.statusCode);
    }
  }

  Quote _parseResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final content = data['content'] as List;
      
      if (content.isEmpty) {
        throw const ParseException('No content received from API');
      }
      
      final text = content[0]['text'] as String;
      final jsonMatch = RegExp(r'\{[^{}]*"quote"[^{}]*:[^{}]*"author"[^{}]*\}', dotAll: true).firstMatch(text);
      
      if (jsonMatch == null) {
        final altMatch = RegExp(r'\{[^}]+\}').firstMatch(text);
        if (altMatch != null) {
          final parsed = jsonDecode(altMatch.group(0)!);
          if (parsed['quote'] != null && parsed['author'] != null) {
            return Quote.fromJson(parsed);
          }
        }
        throw const ParseException('Could not find valid quote JSON in response');
      }
      
      final quoteJson = jsonDecode(jsonMatch.group(0)!);
      return Quote.fromJson(quoteJson);
    } catch (e) {
      if (e is ParseException) rethrow;
      throw ParseException('Failed to parse quote: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}