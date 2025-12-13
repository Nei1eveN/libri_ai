import 'package:libri_ai/src/features/books/data/book_repository_provider.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_action_controller.g.dart';

@riverpod
class BookActionController extends _$BookActionController {
  @override
  FutureOr<bool> build(Book book) async {
    // 1. Check initial status from DB
    // return ref.read(bookRepositoryProvider).isBookSaved(book.id);
    return ref.read(bookRepositoryProvider).isBookSavedLocally(book.id);
  }

  Future<void> toggle() async {
    final currentState = state.value ?? false;

    // 2. Optimistic Update (Update UI instantly before API finishes)
    state = AsyncData(!currentState);

    try {
      // await ref.read(bookRepositoryProvider).toggleSaveBook(book.id);
      await ref.read(bookRepositoryProvider).toggleSaveBookLocally(book);
    } catch (e) {
      // Revert if API fails
      state = AsyncData(currentState);
    }
  }
}
