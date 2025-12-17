import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:libri_ai/src/features/home/presentation/widgets/bento_grid.dart';
import 'package:libri_ai/src/features/home/presentation/widgets/home_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.push('/add-book'),
      //   backgroundColor: AppPalette.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // 2. Calculate "Tracks" (Cross Axis Count)
          int crossAxisCount = 4; // Default (Mobile)
          if (width >= 1000) {
            crossAxisCount = 8; // Desktop
          } else if (width >= 600) {
            crossAxisCount = 6; // Tablet
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  // 1. Large Collapsing Header
                  const HomeAppBar(),

                  // 2. The Content
                  HomeBentoGrid(crossAxisCount: crossAxisCount),

                  const SliverGap(20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
