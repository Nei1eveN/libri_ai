import 'package:libri_ai/src/features/books/data/repositories/book_repository_impl.dart';
import 'package:libri_ai/src/features/books/domain/repositories/book_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'book_repository_provider.g.dart';

@Riverpod(keepAlive: true)
BookRepository bookRepository(BookRepositoryRef ref) {
  return BookRepositoryImpl(Supabase.instance.client);
}
