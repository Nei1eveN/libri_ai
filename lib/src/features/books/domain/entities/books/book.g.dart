// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookImpl _$$BookImplFromJson(Map<String, dynamic> json) => _$BookImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      authors:
          (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      publishedDate: json['published_date'] as String?,
      publisher: json['publisher'] as String?,
    );

Map<String, dynamic> _$$BookImplToJson(_$BookImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'authors': instance.authors,
      'description': instance.description,
      'thumbnail_url': instance.thumbnailUrl,
      'pageCount': instance.pageCount,
      'rating': instance.rating,
      'published_date': instance.publishedDate,
      'publisher': instance.publisher,
    };
