# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Read-It is a Flutter mobile app for PDF English reading practice. Users import PDFs, and the app presents extracted text in a continuous auto-scrolling display with adjustable speed (WPM), spacing, and focus controls. It tracks reading sessions and analytics.

## Build Commands

```bash
flutter pub get                          # Install dependencies
flutter analyze                          # Lint / static analysis
dart format lib/                         # Format code
flutter test                             # Run all tests
flutter test test/path/to_test.dart      # Run single test
flutter build apk --release              # Android APK
flutter build ios --release --no-codesign # iOS
```

No code generation (build_runner) is needed — this project does not use Freezed or json_serializable annotations.

## Architecture

**Clean Architecture** with Provider + GetIt, following the Asset-It developer standards pattern.

### Layer Flow

```
presentation/ (screens, widgets)
    ↓ consumes
features/*/providers/ (ChangeNotifier state management)
    ↓ uses
domain/ (abstract repositories, entities)
    ↑ implements
data/ (repository impls, models, datasources)
    ↓ persists to
SQLite (sqflite) + SharedPreferences
```

### DI & State Wiring

- `injection_container.dart` — registers everything in GetIt (`sl<T>()`), exports `providers` list
- `main.dart` — calls `di.init()`, wraps app in `MultiProvider`
- Providers are registered as `Factory` (new instance per consumer), services/repos as `LazySingleton`

### Four Feature Domains

| Feature | Provider | What it does |
|---------|----------|-------------|
| `pdf_processing` | `PdfProcessingProvider` | Import, extract text, validate PDFs |
| `reading_display` | `ReadingDisplayProvider` | Auto-scroll state, speed/spacing control, play/pause |
| `user_preferences` | `UserPreferencesProvider` | Theme, font size, reading speed, line spacing |
| `analytics` | `AnalyticsProvider` | Session tracking, reading stats, streaks |

### Database

SQLite via `sqflite`, initialized in `injection_container.dart`. Four tables: `pdf_documents`, `reading_sessions`, `user_preferences`, `vocabulary_words`.

### Routing

Named routes in `app.dart`: `/home`, `/settings`, `/analytics`.

### Key Dependencies

- `syncfusion_flutter_pdf` / `syncfusion_flutter_pdfviewer` — PDF text extraction and rendering (the `pdf` package is imported but unused)
- `file_picker` — document import
- `provider` + `get_it` — state management and DI
- `sqflite` — local database

### Core Services

- `PdfProcessingService` — uses `syncfusion_flutter_pdf` (not the `pdf` package despite it being imported) for text extraction, complexity analysis, chunk splitting
- `ReadingDisplayService` — auto-scroll engine using `Timer.periodic` inside an `async*` generator, publishes `ReadingPosition` via a broadcast `StreamController`
- `AnalyticsService` and `DatabaseService` — referenced in `injection_container.dart` but **files do not exist** (compilation blocker)

### Known Compilation Blockers

The app **cannot currently compile**. These must be fixed before any other work:

1. **Missing files:** `core/services/analytics_service.dart`, `core/services/database_service.dart`, `data/datasources/pdf_remote_datasource.dart`
2. **Missing analytics widgets:** `presentation/widgets/analytics/progress_chart_widget.dart`, `recent_sessions_widget.dart`, `insights_widget.dart` — imported by `analytics_screen.dart`
3. **Invalid color:** `Colors.gold` used in `stats_overview_widget.dart` and `reading_streak_widget.dart` — not a valid Flutter constant
4. **Interface gaps:** `UserPreferencesRepositoryImpl` and `PdfRepositoryImpl` don't implement all methods from their abstract interfaces
5. **DB schema mismatch:** `user_preferences` table is missing columns for `font_family`, `enable_vocabulary_collection`, `enable_analytics` that `UserPreferencesModel.toMap()` writes
6. **Missing assets:** `assets/fonts/` and `assets/images/` directories declared in `pubspec.yaml` don't exist

### Known Runtime Bugs

- `ReadingDisplayService` closes its `StreamController` on `stopScrolling()` — permanently breaks; cannot restart reading without app restart
- `ReadingDisplayWidget._createScrollController()` creates a new `ScrollController` on every `build()` call — memory leak
- `ReadingSessionModel.toMap()` stores `settingsSnapshot` via `Map.toString()` but `fromMap()` expects a `Map` — crashes on session retrieval
- Analytics SQL queries use `strftime` on integer millisecond timestamps and `CASE` thresholds that treat milliseconds as seconds

## Project Status

Phase 1 (Foundation) is structurally complete but has compilation blockers and runtime bugs. See `PROGRESS.md` for the roadmap and `BUSINESS_ANALYSIS.md` for a full feature gap analysis.
