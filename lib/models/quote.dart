import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 0)
class Quote extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String? imageUrl;

  Quote({
    required this.text,
    required this.author,
    this.category = 'All',
    this.imageUrl,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] ?? json['content'] ?? json['q'] ?? '',
      author: json['author'] ?? json['a'] ?? 'Unknown',
      category: json['category'] ?? 'All',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'category': category,
        'imageUrl': imageUrl,
      };

  String get formattedQuote => '"$text"\n\n— $author';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}