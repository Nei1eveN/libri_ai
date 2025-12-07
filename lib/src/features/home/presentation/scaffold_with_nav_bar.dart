import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/core/theme/app_palette.dart';
// import 'package:libri_ai/src/core/theme/app_palette.dart'; // We'll define this briefly below

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important: Allows content to go behind the nav bar
      body: Stack(
        children: [
          // 1. The Screen Content
          child,

          // 2. The Floating Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 30, // Floats 30px from bottom
            child: Center(
              child: _GlassNavBar(),
            ),
          ),
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
