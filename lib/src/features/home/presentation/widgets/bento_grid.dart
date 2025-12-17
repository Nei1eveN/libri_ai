import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/widgets/app_network_image.dart';
import 'package:libri_ai/src/core/presentation/widgets/error_view.dart';
import 'package:libri_ai/src/core/theme/app_palette.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/home/presentation/providers/home_providers.dart';

class HomeBentoGrid extends ConsumerWidget {
  const HomeBentoGrid({
    super.key,
    required this.crossAxisCount,
  });

  final int crossAxisCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingBooksProvider);

    // local saved books
    final savedBooksAsync = ref.watch(savedBooksStreamProvider);

    // Default empty values
    final books = savedBooksAsync.valueOrNull ?? [];
    final savedCount = books.where((b) => b.id != 'welcome_guide').length;
    // Look for a "Real" book (anything that isn't the guide)
    final realBook = books
        .where((b) => b.id != 'welcome_guide')
        .firstOrNull; // Returns null if none found, doesn't crash

    // Fallback to ANY book (likely the Welcome Guide)
    final anyBook = books.firstOrNull;

    // Decide: Real Book > Welcome Guide > Null (Empty)
    final lastSavedBook = realBook ?? anyBook;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      sliver: SliverToBoxAdapter(
        child: StaggeredGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            // A. Hero Tile (Static for now - we can make this dynamic later)
            StaggeredGridTile.count(
              crossAxisCellCount: crossAxisCount,
              mainAxisCellCount: 2,
              child: _BentoCard(
                color: Colors.white,
                // Pass the real book data
                child: _buildUpNext(context, lastSavedBook),
              ),
            ),
        
            // B. AI Search Tile
            StaggeredGridTile.count(
              crossAxisCellCount: crossAxisCount ~/ 2,
              mainAxisCellCount: 2,
              child: GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppPalette.aiGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                      Text(
                        "Vibe\nMatch™",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
            // C. Stats Tile
            StaggeredGridTile.count(
              crossAxisCellCount: crossAxisCount ~/ 2,
              mainAxisCellCount: 2,
              child: _BentoCard(
                color: Colors.white,
                child: _buildStats(savedCount),
              ),
            ),
        
            // D. Trending Carousel (Now Real Data!)
            StaggeredGridTile.count(
              crossAxisCellCount: crossAxisCount,
              mainAxisCellCount: 2.4,
              child: _BentoCard(
                color: Colors.white,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Trending Now",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      // Loading/Error/Data states
                      child: trendingAsync.when(
                        data: (books) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate and pass the book object
                                context.push('/book', extra: book);
                              },
                              child: Container(
                                width: 100,
                                margin:
                                    const EdgeInsets.only(right: 12, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AppNetworkImage(
                                          imageUrl: book.thumbnailUrl
                                                  ?.replaceFirst(
                                                      'http://', 'https://') ??
                                              'https://placehold.co/100x150?text=No+Cover',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        // Wrapped it in a SingleChildScrollView just in case the error message is long
                        // so it doesn't overflow the tile height.
                        error: (err, stack) => SingleChildScrollView(
                          child: ErrorView(
                            error: err,
                            onRetry: () => ref.refresh(trendingBooksProvider),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... [Keep helper methods _buildStats, _buildUpNext, and _BentoCard exactly as they were] ...

  // Shows real count
  Widget _buildStats(int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$count",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const Text("Saved Books", // Renamed from "Books Read" to be accurate
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // Updated Widget: Shows real book
  Widget _buildUpNext(BuildContext context, Book? book) {
    // 1. Empty State (User hasn't saved anything)
    if (book == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books_rounded,
                size: 40, color: Colors.grey.shade300),
            const Gap(8),
            const Text("Your library is empty",
                style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () => context.go('/search'),
              child: const Text("Find a book"),
            )
          ],
        ),
      );
    }

    // 2. Data State (Show the actual book)
    return GestureDetector(
      onTap: () => context.push('/book', extra: book),
      child: Row(
        children: [
          // Cover
          Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                imageUrl: book.thumbnailUrl ?? 'https://placehold.co/200x300',
                fit: BoxFit.cover,
                // Make the cover take full height of the container
                height: double.infinity,
              ),
            ),
          ),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF), // Purple tint
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "UP NEXT", // Changed from "Currently Reading"
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9333EA),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(book.authors.firstOrNull ?? "Unknown Author",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),

                // Since we don't have real "progress", we show a "Start Reading" indicator
                // instead of a fake 42% progress bar.
                Row(
                  children: [
                    const Icon(Icons.play_circle_outline,
                        size: 16, color: Color(0xFF6366F1)),
                    const Gap(4),
                    Text(
                      "Start Reading",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    required this.color,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
