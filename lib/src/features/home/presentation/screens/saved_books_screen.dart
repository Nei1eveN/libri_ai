import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/error_view.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/home/presentation/providers/home_providers.dart';

class SavedBooksScreen extends ConsumerWidget {
  const SavedBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the Hive Stream
    final savedBooksAsync = ref.watch(savedBooksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Library"),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: savedBooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorView(
          error: err,
          // If you have a way to refresh (like ref.refresh), pass it here
          onRetry: () => ref.refresh(savedBooksStreamProvider),
        ),
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: books.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final book = books[index];
              return _SavedBookTile(book: book);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 64, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            "Your library is empty",
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () => context.go('/search'),
            child: const Text("Go find some books"),
          )
        ],
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
      onTap: () => context.push('/book', extra: book),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: book.thumbnailUrl ?? 'https://placehold.co/100x150',
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(width: 60, color: Colors.grey.shade200),
              ),
            ),
            const Gap(16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    book.authors.firstOrNull ?? 'Unknown',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Gap(8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Want to Read",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9333EA),
                          fontWeight: FontWeight.bold),
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
