// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/books/domain/repositories/book_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;
  final _dio = Dio();
  final _cacheBox = Hive.box('book_cache');
  final _savedBox = Hive.box('saved_books');

  @override
  Future<List<Book>> searchBooksByVibe(String userQuery) async {
    try {
      // 1. Call Edge Function (Vector Search)
      final functionResponse = await _supabase.functions.invoke(
        'generate-embedding',
        body: {'query': userQuery},
      );

      if (functionResponse.status != 200) {
        throw Exception(
          'Edge function failed: ${functionResponse.status} ${functionResponse.data}',
        );
      }

      final vector = List<double>.from(functionResponse.data['embedding']);

      // 2. Query Supabase
      final List<dynamic> dbResponse = await _supabase.rpc(
        'match_books',
        params: {
          'query_embedding': vector,
          'match_threshold': 0.25,
          'match_count': 10,
        },
      );

      final vibeResults = dbResponse.map((e) => Book.fromJson(e)).toList();

      // -------------------------------------------------------
      // 3. THE FIX: Zero-Result Fallback (Self-Healing)
      // -------------------------------------------------------
      if (vibeResults.isEmpty) {
        print(
          '⚠️ Vibe Search returned 0 results. Falling back to Google Books...',
        );

        // We pass the vibe query directly to Google Books.
        // Google's keyword search is often "smart enough" to find something relevant
        // for queries like "sad robot space".
        final googleResults = await searchBooksByTitle(userQuery);

        // Note: searchBooksByTitle ALREADY handles the "_ingestBooksToSupabase"
        // logic we wrote in the previous step. So we don't need to do anything else!

        return googleResults;
      }

      return vibeResults;
    } catch (e) {
      // If AI fails completely, fallback to Google Books as a safety net
      print('❌ AI Search crashed: $e. Falling back to Google API.');
      return searchBooksByTitle(userQuery);
    }
  }

  @override
  Future<List<Book>> getTrendingBooks() async {
    try {
      // 1. Try to get books from Supabase
      final response = await _supabase
          .from('books')
          .select() // Select all columns
          .limit(10)
          .order('created_at', ascending: false);

      final books = (response as List).map((e) => Book.fromJson(e)).toList();

      // ---------------------------------------------------------
      // 2. THE FIX: Bootstrap if DB is empty
      // ---------------------------------------------------------
      if (books.isEmpty) {
        print('📉 DB is empty. Bootstrapping Trending Section...');

        // Fallback: Fetch "Technology" or "Fiction" bestsellers from Google
        // We use a generic query that guarantees high-quality results
        final googleBooks = await searchBooksByTitle('subject:fiction');

        // Note: searchBooksByTitle already triggers _ingestBooksToSupabase!
        // So simply calling it will populate your DB for the next time.

        return googleBooks;
      }

      return books;
    } catch (e) {
      // If DB fails (e.g. offline), return empty list so UI handles it gracefully
      // or rethrow if you want to show the ErrorView
      throw Exception('Failed to load trending: $e');
    }
  }

  @override
  Future<List<Book>> searchBooksByTitle(String title) async {
    final cacheKey = 'search_$title';

    // 1. Check Local Cache (Offline First)
    if (_cacheBox.containsKey(cacheKey)) {
      print('📱 Fetching from Cache');
      final cachedData = _cacheBox.get(cacheKey) as List;
      // Convert stored JSON back to Book objects
      return cachedData
          .map((e) {
            final json = jsonDecode(jsonEncode(e));
            return Book.fromJson(Map<String, dynamic>.from(json));
          })
          .toList();
    }

    try {
      // 2. Fetch from Google Books API
      print('🌍 Fetching from Google API');
      final response = await _dio.get(
        'https://www.googleapis.com/books/v1/volumes',
        queryParameters: {'q': title, 'maxResults': 10},
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List?;
        if (items == null) return [];

        // Map Google API format to our Book model
        var books = items.map((item) {
          final volume = item['volumeInfo'];

          String? rawThumbnail = volume['imageLinks']?['thumbnail'];
          if (rawThumbnail != null && rawThumbnail.startsWith('http://')) {
            rawThumbnail = rawThumbnail.replaceFirst('http://', 'https://');
          }
          return Book(
            id: item['id'],
            title: volume['title'] ?? 'Unknown',
            authors: List<String>.from(volume['authors'] ?? []),
            description: volume['description'],
            thumbnailUrl: rawThumbnail,
            imageLinks: volume['imageLinks'],
            pageCount: volume['pageCount'] ?? 0,
            rating: (volume['averageRating'] ?? 0).toDouble(),
            publishedDate: volume['publishedDate'],
            publisher: volume['publisher'],
          );
        }).toList();

        _ingestBooksToSupabase(books).then((_) {
          print('🏁 Background ingestion complete');
        }).catchError((e) {
          print('⚠️ Background ingestion error: $e');
        });

        try {
          final googleIds = books.map((b) => b.id).toList();

          if (googleIds.isEmpty) return books;

          final filterString = '(${googleIds.map((id) => '"$id"').join(',')})';

          final dbMatches = await _supabase
              .from('books')
              .select('id, thumbnail_url')
              .filter('id', 'in', filterString)
              .timeout(const Duration(milliseconds: 500));

          final dbCoverMap = {
            for (var match in dbMatches)
              match['id'] as String: match['thumbnail_url'] as String,
          };

          books = books.map((book) {
            final betterCover = dbCoverMap[book.id];

            if (betterCover != null) {
              return book.copyWith(thumbnailUrl: betterCover);
            }

            return book;
          }).toList();
        } catch (e) {
          print('⚠️ Hydration skipped (slow network or timeout): $e');
          // We proceed with the Google images. No harm done.
        }

        // 3. Cache & Return
        // Cache the final result (hydrated or not)
        _cacheBox.put(cacheKey, books.map((b) => b.toJson()).toList());

        return books;
      }
      return [];
    } catch (e) {
      // If offline and no cache, return empty or throw
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// 🛠️ Helper to fix partial dates from Google Books
  /// "1977" -> "1977-01-01"
  /// "1977-05" -> "1977-05-01"
  String? _normalizeDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return null;

    // If it's just a Year (YYYY)
    if (rawDate.length == 4) {
      return "$rawDate-01-01";
    }

    // If it's Year-Month (YYYY-MM)
    if (rawDate.length == 7) {
      return "$rawDate-01";
    }

    // Otherwise assume it's valid or let Postgres handle it
    return rawDate;
  }

  /// 🕵️ Background Helper to save books + vectors
  Future<void> _ingestBooksToSupabase(List<Book> books) async {
    print('🕵️ Starting passive ingestion for ${books.length} books...');

    for (final book in books) {
      // Basic check: Don't ingest if description is too short (bad vectors)
      if ((book.description?.length ?? 0) < 50) continue;

      try {
        // We reuse the existing 'add-book' Edge Function!
        // It handles the vector generation and duplicate checks for us.
        await addNewBook(
          id: book.id,
          title: book.title,
          authors: book.authors,
          description: book.description!,
          genre: 'Unknown', // Google API often misses genre, so we default
          pageCount: book.pageCount,
          // Pass the data from Google Books
          thumbnailUrl: book.thumbnailUrl,
          imageLinks: book.imageLinks,
          // Note: Google Books API usually gives dates like "2023-10-01" or just "2023"
          publishedDate: _normalizeDate(book.publishedDate),
          publisher: book.publisher,
        );
        print('✅ Ingested: ${book.title}');
      } catch (e) {
        // Silently fail. It's okay if background ingestion fails.
        // Likely error: Book already exists (duplicate key).
        print('⚠️ Skipping ${book.title}: $e');
      }
    }
  }

  /// ➕ Add Book (Admin/Ingest Feature)
  /// Calls the Edge Function to generate the vector and save to DB.
  @override
  Future<void> addNewBook({
    String? id,
    required String title,
    required List<String> authors,
    required String description,
    required String genre,
    required int pageCount,
    String? publishedDate,
    String? thumbnailUrl,
    String? publisher,
    Map<String, dynamic>? imageLinks,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'add-book', // Matches the folder name in supabase/functions/
        body: {
          'id': id,
          'title': title,
          'authors': authors,
          'description': description,
          'genre': genre,
          'page_count': pageCount,
          'published_date': publishedDate,
          'thumbnail_url': thumbnailUrl,
          'imageLinks': imageLinks,
          'publisher': publisher,
        },
      );

      if (response.status != 200) {
        throw Exception(
          'Failed to add book: ${response.status} ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  @override
  Future<bool> isBookSaved(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('user_library')
        .select()
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<bool> isBookSavedLocally(String bookId) async {
    return _savedBox.containsKey(bookId);
  }

  @override
  Future<void> toggleSaveBook(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    final isSaved = await isBookSaved(bookId);

    if (isSaved) {
      // Remove
      await _supabase
          .from('user_library')
          .delete()
          .eq('user_id', userId)
          .eq('book_id', bookId);
    } else {
      // Add
      await _supabase.from('user_library').insert({
        'user_id': userId,
        'book_id': bookId,
        'status': 'want_to_read',
      });
    }
  }

  @override
  Future<void> toggleSaveBookLocally(Book book) async {
    if (_savedBox.containsKey(book.id)) {
      await _savedBox.delete(book.id);
    } else {
      // Store the whole book object so we can show a "Saved Books" list later without fetching
      await _savedBox.put(book.id, book.toJson());
    }
  }
}
