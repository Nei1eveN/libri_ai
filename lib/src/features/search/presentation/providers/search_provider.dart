import 'package:libri_ai/src/features/books/data/book_repository_provider.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

// 1. Define the Search Modes
enum SearchMode { title, vibe }

// 2. The Controller (Notifier)
// This manages the state of the UI (Loading -> Data/Error)
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  FutureOr<List<Book>> build() {
    return []; // Initial state: Empty list
  }

  // 2. Accept the mode as an argument
  Future<void> search(String query, SearchMode mode) async {
    if (query.trim().isEmpty) return;

    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookRepositoryProvider);
      List<Book> results;
      
      // 3. Switch logic based on mode
      if (mode == SearchMode.title) {
        // Calls Google Books API + Hive Cache
        results = await repository.searchBooksByTitle(query);
      } else {
        // Calls Gemini + Supabase Vector Search
        results = await repository.searchBooksByVibe(query);
      }

      // 🧹 DEDUPLICATION LOGIC
      // Use a Set based on Title to remove duplicates from the view
      final uniqueBooks = <String, Book>{};
      for (var book in results) {
        // Normalize title (lowercase, trim) to catch "Dune" vs "dune "
        uniqueBooks.putIfAbsent(book.title.toLowerCase().trim(), () => book);
      }
      
      return uniqueBooks.values.toList();
    });
  }
}
