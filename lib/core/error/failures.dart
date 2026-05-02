abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Unable to connect. Please check your internet connection.']);
}

class ApiFailure extends Failure {
  const ApiFailure([super.message = 'Something went wrong. Please try again.']);
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure([super.message = 'API key not found. Please configure your ANTHROPIC_API_KEY.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Unable to parse quote. Please try again.']);
}