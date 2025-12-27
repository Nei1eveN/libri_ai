import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/theme/app_palette.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Breakpoint: 800px is usually better than 600px for a full Side Rail
        final isDesktop = width >= 800;

        if (isDesktop) {
          return _DesktopScaffold(navigationShell: navigationShell);
        }

        return _MobileScaffold(navigationShell: navigationShell);
      },
    );
  }
}

// 📱 MOBILE LAYOUT (Floating Glass Bar)
class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend body so content flows BEHIND the floating bar
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. The Content
          // We wrap this to ensure inner lists know there is an obstruction at the bottom
          MediaQuery.removePadding(
            context: context,
            removeBottom: true, // We handle padding manually or via the bar
            child: navigationShell,
          ),

          // 2. The Floating Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: _GlassNavBar(),
            ),
          ),
        ],
      ),
    );
  }
}

// 🖥️ DESKTOP LAYOUT (Side Rail)
class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. The Side Rail
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            // Style it to match your app
            backgroundColor: Colors.white,
            indicatorColor: AppPalette.primary.withOpacity(0.1),
            selectedIconTheme: const IconThemeData(color: AppPalette.primary),
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade400),
            // The Label Style
            selectedLabelTextStyle: const TextStyle(
              color: AppPalette.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),

            // "Extended" shows text labels next to icons.
            // You can make this dynamic (width > 1200 ? true : false)
            extended: MediaQuery.sizeOf(context).width > 1100,

            // Header: Your Logo
            leading: Column(
              children: [
                const SizedBox(height: 24),
                // Replace with your 'L' logo asset or Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.white),
                ),
                const SizedBox(height: 32),
              ],
            ),

            // The Tabs
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search_rounded),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark),
                label: Text('Library'),
              ),
            ],
          ),

          // 2. Vertical Divider
          VerticalDivider(thickness: 1, width: 1, color: Colors.grey.shade200),

          // 3. The Content Body
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50), // Fully rounded pill
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The "Glass" effect
        child: Container(
          width: 200, // Compact width
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7), // Semi-transparent white
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                isActive: path == '/',
                onTap: () => context.go('/'),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                isActive: path == '/search',
                onTap: () => context.go('/search'),
              ),
              _NavItem(
                icon: Icons.bookmark_outline_rounded,
                isActive: path == '/saved',
                onTap: () => context.go('/saved'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: isActive
            ? const BoxDecoration(
                color: AppPalette.primary, // Indigo Primary
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
  }
}
