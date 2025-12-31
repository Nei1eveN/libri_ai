import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/widgets/app_network_image.dart';
import 'package:libri_ai/src/core/presentation/widgets/error_view.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/home/presentation/providers/home_providers.dart';

class SavedBooksScreen extends ConsumerWidget {
  const SavedBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the Hive Stream
    final savedBooksAsync = ref.watch(savedBooksStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 📐 Responsive Logic
          // Desktop (>1100px): 3 Columns
          // Tablet (>700px): 2 Columns
          // Mobile: 1 Column
          final gridCount = switch (constraints.maxWidth) {
            > 1100 => 3,
            > 700 => 2,
            _ => 1,
          };

          final bookWord = switch (savedBooksAsync.valueOrNull?.length ?? 0) {
            < 1 || > 1 => 'Books',
            _ => 'Book'
          };

          return CustomScrollView(
            slivers: [
              // Header + Controls
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A. Big Title with Count
                          Row(
                            children: [
                              const Text(
                                "My Library",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF), // Purple tint
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${savedBooksAsync.valueOrNull?.length ?? 0} $bookWord",
                                  style: const TextStyle(
                                    color: Color(0xFF9333EA),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Gap(24),

                          // Toolbar (Filters, Search)
                          Row(
                            children: [
                              // Filter Chips
                              const _LibraryFilterChip(
                                label: "All",
                                isSelected: true,
                              ),
                              const Gap(8),
                              const _LibraryFilterChip(
                                label: "To Read",
                                isSelected: false,
                              ),
                              const Gap(8),
                              const _LibraryFilterChip(
                                label: "Finished",
                                isSelected: false,
                              ),

                              const Spacer(), // Pushes the search icon to the right

                              // Search within Library (Visual only for now)
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.sort_rounded,
                                  color: Colors.grey,
                                ),
                                tooltip: "Sort Order",
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                tooltip: "Search Library",
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFFEEEEEE)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              savedBooksAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: LinearProgressIndicator()),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: ErrorView(
                    error: err,
                    onRetry: () => ref.refresh(savedBooksStreamProvider),
                  ),
                ),
                data: (books) {
                  if (books.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(context),
                    );
                  }

                  // 🏗️ The Responsive Grid
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      110,
                    ), // Reduced top padding
                    sliver: SliverGrid(
                      // Use SliverGrid inside CustomScrollView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        childAspectRatio: 2.8, // Keep your aspect ratio
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _SavedBookTile(book: books[index]),
                        childCount: books.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // Wrapped in Center, so it handles large screens naturally.
    // Added a ConstrainedBox to prevent text from spreading too wide on 4k.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: Colors.grey.shade300,
              ),
            ),
            const Gap(24),
            Text(
              "Your library is empty",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              "Books you save will appear here so you can easily find them later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: const Text("Find a Book"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedBookTile extends StatelessWidget {
  const _SavedBookTile({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/book',
        extra: {
          'book': book,
          // Unique Hero Tag for this screen
          'heroTag': 'saved_${book.id}',
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Subtle shadow + Border for Desktop polish
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Cover
            Hero(
              tag: 'saved_${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  imageUrl:
                      book.thumbnailUrl?.replaceFirst('http://', 'https://') ??
                          'https://placehold.co/100x150',
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover, // Ensure it fills the box
                ),
              ),
            ),
            const Gap(16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Vertically center text
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    book.authors.firstOrNull ?? 'Unknown',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Want to Read",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9333EA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _LibraryFilterChip extends StatelessWidget {
  const _LibraryFilterChip({
    required this.label,
    required this.isSelected,
  });
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
