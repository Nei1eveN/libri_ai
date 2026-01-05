import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:libri_ai/src/features/books/data/book_repository_provider.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@riverpod
Future<List<Book>> trendingBooks(TrendingBooksRef ref) async {
  // 1. Get the repository
  final repository = ref.watch(bookRepositoryProvider);

  // 2. Fetch the data (Supabase 'select' call we wrote earlier)
  return repository.getTrendingBooks();
}

// 1. A Stream that listens to Hive changes in real-time
@riverpod
Stream<List<Book>> savedBooksStream(SavedBooksStreamRef ref) async* {
  final box = Hive.box('saved_books');

  // Emit initial value immediately
  yield _getBooksFromBox(box);

  // Listen for changes (add/remove) and emit new lists
  await for (final _ in box.watch()) {
    yield _getBooksFromBox(box);
  }
}

// Helper to parse the box values
List<Book> _getBooksFromBox(Box box) {
  return box.values
      .map((e) {
        // Handle potential type casting issues safely
        if (e is Map) {
          final json = jsonDecode(jsonEncode(e));
          return Book.fromJson(Map<String, dynamic>.from(json));
        }
        return null;
      })
      .whereType<Book>() // Filter out nulls
      .toList()
      .reversed // Show newest first
      .toList();
}
