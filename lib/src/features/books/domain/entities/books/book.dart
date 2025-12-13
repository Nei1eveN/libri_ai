import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
class Book with _$Book {
  const factory Book({
    required String id,
    required String title,
    required List<String> authors,
    required String? description,
    @JsonKey(name: 'thumbnail_url')
    required String? thumbnailUrl,
    @Default(0) int pageCount,
    @Default(0.0) double rating,
    @JsonKey(name: 'published_date')
    required String? publishedDate,
    String? publisher,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}