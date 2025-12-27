import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libri_ai/src/core/router/app_router.dart';
import 'package:libri_ai/src/core/theme/app_theme.dart';
import 'package:libri_ai/src/features/books/domain/entities/books/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Env Vars
  await dotenv.load(fileName: ".env");

  // 2. Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await Hive.initFlutter();
  await Hive.openBox('book_cache'); // Open a box for caching
  await Hive.openBox('saved_books'); // Open a box for saved books

  // 1. Init Hive
  await Hive.initFlutter();
  final savedBox = await Hive.openBox('saved_books');
  await Hive.openBox('book_cache'); // Ensure this is open too

  // 2. First Run Check: Inject a "Welcome Book" if box is empty
  if (savedBox.isEmpty) {
    const welcomeBook = Book(
      id: 'welcome_guide',
      title: 'Welcome to Libri AI',
      authors: ['The Architect'],
      description:
          'Ready to find your next read? Tap the Search tab and type a vibe like "A cyberpunk detective story" to see our AI in action. Or search for a title like "Dune" to build your library.',
      // Use a distinct placeholder or a real image URL
      thumbnailUrl:
          'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=1000&auto=format&fit=crop',
      pageCount: 1,
      rating: 5.0,
      publisher: 'Neil Patrick Potot',
      publishedDate: '12-07-2025',
    );

    await savedBox.put('welcome_guide', welcomeBook.toJson());
  }

  // 1. Force Edge-to-Edge (Transparent Status Bar & Nav Bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Set the Overlay Style (Dark Icons for Status Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Android
      systemNavigationBarColor: Colors.transparent, // Android
      systemNavigationBarDividerColor: Colors.transparent,

      // Icon Brightness (Dark icons for light backgrounds)
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS

      // Bottom Nav Bar Icon Brightness
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: LibriApp()));
}

class LibriApp extends ConsumerWidget {
  const LibriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the router provider so redirects work with state changes
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Libri AI',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
