import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;
  final String author;

  const Quote({
    required this.text,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: (json['quote'] as String?)?.trim() ?? '',
      author: (json['author'] as String?)?.trim() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': text,
      'author': author,
    };
  }

  Quote copyWith({
    String? text,
    String? author,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
    );
  }

  String get formattedQuote => '"$text"\n\n— $author';

  @override
  List<Object?> get props => [text, author];

  @override
  String toString() => 'Quote(text: $text, author: $author)';
}