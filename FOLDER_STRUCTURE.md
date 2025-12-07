lib/
├── main.dart
├── src/
│   ├── core/
│   │   ├── constants/       # API Keys (env vars), AppStrings
│   │   ├── router/          # GoRouter configuration
│   │   └── theme/           # AppTheme, ColorPalettes
│   ├── features/
│   │   ├── books/           # Feature: Book Data Management
│   │   │   ├── data/        # Repositories, Data Sources (Supabase/API)
│   │   │   ├── domain/      # Models (Freezed classes), Entities
│   │   │   └── presentation/# Widgets related to books (BookCard, etc.)
│   │   ├── home/            # Feature: The Dashboard
│   │   │   └── presentation/# BentoGrid, HomeScreen
│   │   └── search/          # Feature: AI Search
│   │       └── presentation/# SearchScreen, SearchController