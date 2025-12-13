import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libri_ai/src/features/books/data/book_repository_provider.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/books/domain/repositories/book_repository.dart';
import 'package:libri_ai/src/features/search/presentation/providers/search_provider.dart';
import 'package:mocktail/mocktail.dart';

// 1. Create a Mock Repository
class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockBookRepository();
    // 2. Override the real repository with our mock
    container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  test('Initial state should be empty list', () {
    final state = container.read(searchNotifierProvider);
    expect(state.value, isEmpty);
  });

  test('Search triggers loading then returns books', () async {
    // A. Arrange
    const dummyBook = Book(
      id: '1',
      title: 'Test Book',
      authors: ['Tester'],
      description: 'A test',
      thumbnailUrl: null,
      publisher: 'Unknown',
      publishedDate: '12-07-2025',
    );

    // Stub the repo to return our dummy book
    when(() => mockRepo.searchBooksByVibe('happy')).thenAnswer(
      (_) async => [dummyBook],
    );

    // B. Act
    // Listen to the provider so it initializes
    final subscription = container.listen(searchNotifierProvider, (_, __) {});
    final notifier = container.read(searchNotifierProvider.notifier);

    // Trigger search
    await notifier.search('happy', SearchMode.vibe);

    // C. Assert
    final state = container.read(searchNotifierProvider);

    expect(state.isLoading, false);
    expect(state.value, hasLength(1));
    expect(state.value!.first.title, 'Test Book');

    subscription.close();
  });
}
