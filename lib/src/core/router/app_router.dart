import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:libri_ai/src/features/books/presentation/screens/add_book_screen.dart';
import 'package:libri_ai/src/features/books/presentation/screens/book_detail_screen.dart';
import 'package:libri_ai/src/features/home/presentation/screens/saved_books_screen.dart';
import 'package:libri_ai/src/features/home/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:libri_ai/src/features/home/presentation/screens/home_screen.dart';
import 'package:libri_ai/src/features/search/presentation/screens/search_screen.dart';

part 'app_router.g.dart';

// Create a Global Key for the Navigator to allow context-less navigation if needed
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ShellRoute wraps screens that share the Bottom Nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // We will build a fancy scaffold here in Week 2
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _buildFadePage(
              context,
              state,
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _buildFadePage(
              context,
              state,
              const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/saved',
            pageBuilder: (context, state) => _buildFadePage(
              context,
              state,
              const SavedBooksScreen(),
            ),
          ),
        ],
      ),
      // NEW: Add this as a SIBLING to ShellRoute (at the end of the list)
      GoRoute(
        path: '/book',
        builder: (context, state) {
          // We pass the Book object via the 'extra' parameter
          // This avoids an extra API call.
          final extras = state.extra as Map<String, dynamic>;
          final book = extras['book'] as Book;
          final heroTag = extras['heroTag'] as String?;
          return BookDetailScreen(
            book: book,
            heroTag: heroTag,
          );
        },
      ),
      GoRoute(
        path: '/add-book',
        builder: (context, state) => const AddBookScreen(),
      ),
    ],
  );
}

// Helper for "Tab Style" Fade Transitions
CustomTransitionPage _buildFadePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey, // Crucial for Riverpod/State preservation
    child: child,
    transitionDuration: const Duration(milliseconds: 200), // Quick & Snappy
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
