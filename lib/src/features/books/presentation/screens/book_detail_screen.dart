import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/widgets/app_network_image.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/books/presentation/providers/book_action_controller.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({
    required this.book,
    required this.heroTag,
    super.key,
  });

  final Book book;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Watch state for "Save" button logic
    final isSavedAsync = ref.watch(bookActionControllerProvider(book));
    final isSaved = isSavedAsync.value == true;

    final tag = heroTag ?? book.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // 📱 Mobile Only: Use the FAB (Floating Action Button)
      // On Desktop, we put the button inside the layout itself.
      floatingActionButton: MediaQuery.of(context).size.width > 800
          ? null
          : FloatingActionButton.extended(
              onPressed: () => ref
                  .read(bookActionControllerProvider(book).notifier)
                  .toggle(),
              backgroundColor: isSaved ? Colors.green : const Color(0xFF6366F1),
              icon: Icon(
                isSaved ? Icons.check : Icons.bookmark_add,
                color: Colors.white,
              ),
              label: Text(
                isSaved ? "Saved" : "Want to Read",
                style: const TextStyle(color: Colors.white),
              ),
            ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;

              // 🖥️ 1. DESKTOP LAYOUT (Split View)
              if (isDesktop) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT PANE: Cover & Action Button
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            // Back Button (Desktop style)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text("Back"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ),
                            const Gap(16),
                            // Big Cover with Shadow
                            Hero(
                              tag: tag,
                              child: Container(
                                width: double.infinity,
                                height: 500,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AppNetworkImage(
                                    imageUrl: book.thumbnailUrl?.replaceFirst(
                                          'http://',
                                          'https://',
                                        ) ??
                                        '',
                                    title: book.title,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(24),
                            // Desktop "Big Button" (Replaces FAB)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: () => ref
                                    .read(
                                      bookActionControllerProvider(book)
                                          .notifier,
                                    )
                                    .toggle(),
                                icon: Icon(
                                  isSaved ? Icons.check : Icons.bookmark_add,
                                ),
                                label: Text(
                                  isSaved
                                      ? "Saved to Library"
                                      : "Add to Library",
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isSaved
                                      ? Colors.green
                                      : const Color(0xFF6366F1),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(60), // Space between panes

                      // RIGHT PANE: Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(40),
                              Text(
                                book.title,
                                style: textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                "By ${book.authors.join(", ")}",
                                style: textTheme.titleLarge
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const Gap(32),
                              Row(
                                children: [
                                  _buildStatChip(
                                    icon: Icons.auto_stories,
                                    label: "${book.pageCount} pages",
                                  ),
                                  const Gap(12),
                                  _buildStatChip(
                                    icon: Icons.star_rounded,
                                    label:
                                        "${(!book.rating.isNegative ? book.rating : 'N/A')}",
                                    color: Colors.amber,
                                  ),
                                ],
                              ),
                              const Gap(40),
                              Text(
                                "About this book",
                                style: textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Gap(16),
                              Text(
                                book.description ?? "No description available.",
                                style: textTheme.bodyLarge?.copyWith(
                                  height: 1.8,
                                  fontSize: 18,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const Gap(100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 📱 2. MOBILE LAYOUT (Your Original Code)
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 400,
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: tag,
                            child: AppNetworkImage(
                              imageUrl: book.thumbnailUrl
                                      ?.replaceFirst('http://', 'https://') ??
                                  '',
                              title: book.title,
                            ),
                          ),
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(8),
                          Text(
                            book.authors.join(", "),
                            style: textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const Gap(24),
                          Row(
                            children: [
                              _buildStatChip(
                                icon: Icons.auto_stories,
                                label: "${book.pageCount} pages",
                              ),
                              const Gap(12),
                              _buildStatChip(
                                icon: Icons.star_rounded,
                                label:
                                    "${(!book.rating.isNegative ? book.rating : 'N/A')}",
                                color: Colors.amber,
                              ),
                            ],
                          ),
                          const Gap(32),
                          Text(
                            "About this book",
                            style: textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(12),
                          Text(
                            book.description ?? "No description available.",
                            style: textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const Gap(100),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
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
