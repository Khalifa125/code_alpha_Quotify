class QuoteException implements Exception {
  final String message;
  const QuoteException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends QuoteException {
  const NetworkException([super.message = 'Network error occurred']);
}

class ApiException extends QuoteException {
  final int? statusCode;
  const ApiException(super.message, {this.statusCode});
}

class TimeoutException extends QuoteException {
  const TimeoutException([super.message = 'Request timed out']);
}

class ParseException extends QuoteException {
  const ParseException([super.message = 'Failed to parse response']);
}

class ApiKeyException extends QuoteException {
  const ApiKeyException([super.message = 'API key is missing or invalid']);
}