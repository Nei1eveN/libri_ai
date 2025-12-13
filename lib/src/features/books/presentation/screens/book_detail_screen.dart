import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/books/presentation/providers/book_action_controller.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.book, super.key});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Senior Tip: Use lighter colors for secondary text
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Watch the specific provider for THIS book
    final isSavedAsync = ref.watch(bookActionControllerProvider(book));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. The Collapsing App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              // Glass background for the back button so it's visible on dark covers
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // The Cover Image
                  CachedNetworkImage(
                    imageUrl: book.thumbnailUrl ??
                        'https://placehold.co/400x600?text=No+Cover',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                  // Gradient overlay so text pops if we put it on top (optional style)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Author
                  Text(
                    book.title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    book.authors.join(", "),
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const Gap(24),

                  // "Quick Stats" Row (Page Count, Rating, etc.)
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.auto_stories,
                        label: "${book.pageCount} pages",
                      ),
                      const Gap(12),
                      _buildStatChip(
                        icon: Icons.star_rounded,
                        label: "${book.rating} Rating", // Placeholder for now
                        color: Colors.amber,
                      ),
                    ],
                  ),

                  const Gap(32),

                  // Description Header
                  Text(
                    "About this book",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),

                  // Description Text
                  Text(
                    book.description ?? "No description available.",
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const Gap(100), // Bottom padding for scrolling space
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for "Read Now" or "Save"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(bookActionControllerProvider(book).notifier).toggle();
        }, // Future: Add to library logic
        // Change color based on state
        backgroundColor:
            isSavedAsync.value == true ? Colors.green : const Color(0xFF6366F1),
        // Change Icon
        icon: Icon(
            isSavedAsync.value == true ? Icons.check : Icons.bookmark_add,
            color: Colors.white),
        // Change Label
        label: Text(
          isSavedAsync.value == true ? "Saved to Library" : "Want to Read",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      {required IconData icon, required String label, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey.shade700),
          const Gap(6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
