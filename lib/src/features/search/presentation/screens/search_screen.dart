import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/error_view.dart';
import 'package:libri_ai/src/core/presentation/shimmer_skeleton.dart';
import 'package:libri_ai/src/core/theme/app_palette.dart';
import 'package:libri_ai/src/core/utils/debouncer.dart';
import 'package:libri_ai/src/features/search/presentation/providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  // 1. State for the selected mode
  SearchMode _selectedMode = SearchMode.title;

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (query.isNotEmpty) {
        // 2. Pass the selected mode to the provider
        ref.read(searchNotifierProvider.notifier).search(query, _selectedMode);
      }
    });
  }

  // 3. Helper to handle chip selection
  void _onModeChanged(SearchMode newMode) {
    setState(() {
      _selectedMode = newMode;
    });
    // Trigger search immediately if there is text
    if (_controller.text.isNotEmpty) {
      _onSearchChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the search results
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. The Search Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Discover",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  // Search Input
                  TextField(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      // Dynamic Hint Text
                      hintText: _selectedMode == SearchMode.title
                          ? "Search by Title, Author, or ISBN..."
                          : "Describe a mood (e.g., 'Sad robot on Mars')...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        _selectedMode == SearchMode.title
                            ? Icons.search
                            : Icons.auto_awesome,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),

                  const Gap(12),

                  // 4. The Mode Toggle Chips
                  Row(
                    children: [
                      _FilterChip(
                        label: "Title Search",
                        icon: Icons.title,
                        isSelected: _selectedMode == SearchMode.title,
                        onTap: () => _onModeChanged(SearchMode.title),
                      ),
                      const Gap(8),
                      _FilterChip(
                        label: "Vibe Match™",
                        icon: Icons.auto_awesome,
                        isSelected: _selectedMode == SearchMode.vibe,
                        onTap: () => _onModeChanged(SearchMode.vibe),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. The Results Area
            Expanded(
              child: searchState.when(
                // A. Data Loaded
                data: (books) {
                  if (books.isEmpty && _controller.text.isNotEmpty) {
                    return _buildEmptyState("No matching vibes found.");
                  }
                  if (books.isEmpty || _controller.text.isEmpty) {
                    return _buildIntroState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _SearchResultTile(book: book);
                    },
                  );
                },
                // B. Loading
                loading: () => const BookListSkeleton(),
                // C. Error
                error: (err, stack) => ErrorView(
                  error: err,
                  // If you have a way to refresh (like ref.refresh), pass it here
                  onRetry: () => ref.refresh(searchNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search, size: 80, color: Colors.grey.shade300),
          const Gap(16),
          Text(
            "Find your next read",
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Text(
            "Try searching for:\n\"A lonely robot on Mars\"\n\"Dystopian future with hope\"",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
        child: Text(message, style: TextStyle(color: Colors.grey.shade600)));
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.book});

  // Typed dynamic for brevity, ideally 'Book'
  final dynamic book;

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
                    Container(width: 60, color: Colors.grey),
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
                    book.authors.join(", "),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Gap(8),
                  // "Vibe Score" badge (Fake visualization of similarity)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "High Match",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF166534),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
