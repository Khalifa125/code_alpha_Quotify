import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/error/exceptions.dart';
import '../core/error/failures.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  final service = QuoteService();
  ref.onDispose(() => service.dispose());
  return service;
});

final quoteControllerProvider = StateNotifierProvider<QuoteController, QuoteState>((ref) {
  final service = ref.watch(quoteServiceProvider);
  return QuoteController(service);
});

class QuoteState {
  final Quote? quote;
  final bool isLoading;
  final Failure? error;
  final int gradientIndex;

  const QuoteState({
    this.quote,
    this.isLoading = false,
    this.error,
    this.gradientIndex = 0,
  });

  QuoteState copyWith({
    Quote? quote,
    bool? isLoading,
    Failure? error,
    int? gradientIndex,
    bool clearError = false,
    bool clearQuote = false,
  }) {
    return QuoteState(
      quote: clearQuote ? null : (quote ?? this.quote),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      gradientIndex: gradientIndex ?? this.gradientIndex,
    );
  }

  bool get hasError => error != null;
  bool get hasQuote => quote != null;
  bool get isInitial => !isLoading && !hasError && !hasQuote;
}

class QuoteController extends StateNotifier<QuoteState> {
  final QuoteService _service;
  final Random _random = Random();

  QuoteController(this._service) : super(const QuoteState()) {
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final quote = await _service.fetchQuote();
      final newGradientIndex = _random.nextInt(AppConstants.gradientCount);
      
      state = state.copyWith(
        quote: quote,
        isLoading: false,
        gradientIndex: newGradientIndex,
        clearError: true,
      );
      
      HapticFeedback.mediumImpact();
    } on QuoteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapExceptionToFailure(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiFailure(e.toString()),
      );
    }
  }

  Failure _mapExceptionToFailure(QuoteException e) {
    if (e is ApiKeyException) return const ApiKeyFailure();
    if (e is NetworkException) return const NetworkFailure();
    if (e is TimeoutException) return const TimeoutFailure();
    if (e is ParseException) return const ParseFailure();
    return ApiFailure(e.message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}