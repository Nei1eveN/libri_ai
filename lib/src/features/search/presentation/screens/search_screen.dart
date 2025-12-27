import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/presentation/widgets/app_network_image.dart';
import 'package:libri_ai/src/core/presentation/widgets/error_view.dart';
import 'package:libri_ai/src/core/presentation/widgets/shimmer_skeleton.dart';
import 'package:libri_ai/src/core/theme/app_palette.dart';
import 'package:libri_ai/src/core/utils/debouncer.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/search/presentation/providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
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
        ref.read(searchNotifierProvider.notifier).search(query, _selectedMode);
      }
    });
  }

  void _onModeChanged(SearchMode newMode) {
    setState(() => _selectedMode = newMode);
    if (_controller.text.isNotEmpty) {
      _onSearchChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Slight tint for card contrast
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Desktop: 3 cols, Tablet: 2 cols, Mobile: 1 col
            final gridCount = switch (constraints.maxWidth) {
              > 1100 => 3,
              > 700 => 2,
              _ => 1,
            };

            return Column(
              children: [
                // 1. The Search Header (Centered & Constrained)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  alignment: Alignment.center, // Center the inner content
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 800), // Max Width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Discover",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(16),
                        TextField(
                          controller: _controller,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const Gap(12),
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
                ),

                // 2. The Results Area (Responsive Grid)
                Expanded(
                  child: searchState.when(
                    data: (books) {
                      if (books.isEmpty && _controller.text.isNotEmpty) {
                        return _buildEmptyState("No matching vibes found.");
                      }
                      if (books.isEmpty || _controller.text.isEmpty) {
                        return _buildIntroState();
                      }

                      // 🏗️ GRID VIEW for Desktop / List for Mobile
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCount,
                              // Aspect Ratio tweak:
                              // Mobile (Row style) needs shorter height
                              // Desktop (Grid style) needs taller height?
                              // Actually, reusing the Row style works great in a grid too!
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              return _SearchResultTile(book: books[index]);
                            },
                          ),
                        ),
                      );
                    },
                    loading: () => const BookListSkeleton(),
                    error: (err, stack) => ErrorView(
                      error: err,
                      onRetry: () => ref.refresh(searchNotifierProvider),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ... [Keep _buildIntroState and _buildEmptyState as they were] ...
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
              fontWeight: FontWeight.w600,
            ),
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
      child: Text(message, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}

// ... [Keep _FilterChip as it was] ...
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
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
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

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'search_${book.id}';

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.push(
          '/book',
          extra: {
            'book': book,
            'heroTag': heroTag,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Subtle shadow for depth on white background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
          ), // Nice border for Desktop
        ),
        child: Row(
          children: [
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  imageUrl:
                      book.thumbnailUrl?.replaceFirst('http://', 'https://') ??
                          'https://placehold.co/100x150',
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover, // Ensure it fills
                ),
              ),
            ),
            const Gap(16),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                    book.authors.join(", "),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  // "Vibe Score" Badge
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
