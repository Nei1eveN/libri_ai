import 'package:flutter/material.dart';
import 'package:libri_ai/src/features/home/presentation/widgets/bento_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.push('/add-book'),
      //   backgroundColor: AppPalette.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body: CustomScrollView(
        slivers: [
          // 1. Large Collapsing Header
          SliverAppBar.medium(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF8F9FA),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              centerTitle: false,
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_getGreeting()}\n',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5, // Better line height
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Reader', // You could swap this with a Hive username later
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            'Playfair Display', // Using your Serif font for "Name" looks classy
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    // Micro-interaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile settings coming soon!"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2), // White border effect
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22, // Slightly larger
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=12'),
                    ),
                  ),
                ),
              )
            ],
          ),

          // 2. The Content
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 110),
            sliver: HomeBentoGrid(),
          ),
        ],
      ),
    );
  }
}
