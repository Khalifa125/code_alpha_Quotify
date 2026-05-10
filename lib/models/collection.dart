import 'package:hive/hive.dart';
import 'quote.dart';

part 'collection.g.dart';

@HiveType(typeId: 1)
class Collection extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> quoteIds;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String? coverQuoteId;

  Collection({
    required this.id,
    required this.name,
    required this.quoteIds,
    required this.createdAt,
    this.coverQuoteId,
  });

  Collection copyWith({
    String? name,
    List<String>? quoteIds,
    String? coverQuoteId,
  }) {
    return Collection(
      id: id,
      name: name ?? this.name,
      quoteIds: quoteIds ?? this.quoteIds,
      createdAt: createdAt,
      coverQuoteId: coverQuoteId ?? this.coverQuoteId,
    );
  }
}