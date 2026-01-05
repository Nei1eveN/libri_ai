import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';

// Interface: Allows for easier unit testing (mocking) later.
abstract class BookRepository {
  /// 🧠 Semantic Search (The Vibe Match)
  Future<List<Book>> searchBooksByVibe(String userQuery);

  /// 📚 Standard Fetch (For Trending/Home)
  Future<List<Book>> getTrendingBooks();

  /// Searches books based on title
  Future<List<Book>> searchBooksByTitle(String title);

  /// ➕ Add Book (Admin/Ingest Feature)
  Future<void> addNewBook({
    String? id,
    required String title,
    required List<String> authors,
    required String description,
    required String genre,
    required int pageCount,
    String? publishedDate,
    String? thumbnailUrl,
    required String publisher,
    Map<String, dynamic>? imageLinks,
  });

  /// ❤️ Check if book is saved
  Future<bool> isBookSaved(String bookId);
  Future<bool> isBookSavedLocally(String bookId);

  /// 🔖 Toggle Save Status
  Future<void> toggleSaveBook(String bookId);
  Future<void> toggleSaveBookLocally(Book book);
}
