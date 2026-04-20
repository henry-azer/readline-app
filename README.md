# Read-It

PDF English reading practice app built with Flutter. Import PDFs, read with auto-scrolling at your own pace, collect vocabulary, track streaks, and review analytics.

## Features

- **PDF Import & Text Extraction** — Import any PDF, automatically extract text with complexity analysis
- **Auto-Scrolling Reader** — Three-zone display (past/focus/upcoming) with adjustable WPM speed, font size, and line spacing
- **Vocabulary Collection** — Tap words to save, auto-detect complex words, spaced repetition review with flashcards
- **Streak Tracking** — Daily reading streaks with weekly activity, milestone badges (7/14/30/100 days)
- **Analytics Dashboard** — Reading volume charts, velocity trends, session history, focus scoring
- **Dual Theme** — Light ("Modern Bibliophile") and Dark ("Midnight Library") with editorial typography
- **Localization Ready** — Custom JSON-based i18n system with full English strings, extensible to any language

## Architecture

**MVVM + RxDart** with clean layer separation:

```
presentation/  (screens, viewmodels, widgets)
    ↓ BehaviorSubject streams
data/contracts/  (abstract repository interfaces)
    ↑ implemented by
data/repositories/  (Hive-backed)
    ↓ delegates to
data/datasources/local/  (HiveSource per entity)
```

**Stack:** Flutter, RxDart, GetIt, GoRouter, Hive, Freezed, Syncfusion PDF, Google Fonts

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Testing

```bash
flutter test          # 70 tests (4 service test suites + widget smoke test)
flutter analyze       # Static analysis
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # AppConstants, PersonalLinks
│   ├── di/              # GetIt dependency injection
│   ├── extensions/      # BuildContext extensions
│   ├── localization/    # AppLocalization, AppStrings, LanguageProvider
│   ├── router/          # GoRouter with 4-tab shell
│   ├── services/        # Reading engine, PDF processing, streak, vocabulary
│   ├── theme/           # Colors, typography, spacing, radius, gradients, tracking
│   └── utils/           # DateFormatter
├── data/
│   ├── contracts/       # Abstract repository interfaces
│   ├── datasources/     # Hive storage implementations
│   ├── entities/        # Freezed immutable types
│   ├── enums/           # Domain enums
│   ├── models/          # Hive data models (toMap/fromMap)
│   └── repositories/    # Repository implementations
└── presentation/
    ├── analytics/       # Charts, stats, activity
    ├── home/            # Empty + active states
    ├── library/         # Grid/list, filters, import
    ├── onboarding/      # 3-step welcome flow
    ├── reading/         # Auto-scroll reader
    ├── settings/        # Preferences, live preview
    ├── shell/           # Bottom nav bar
    ├── vocabulary/      # Word cards, flashcard review
    └── widgets/         # Shared: TapScale, ReadItButton, GlassContainer
```

## License

All rights reserved.
