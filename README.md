<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey" alt="Platform" />
  <img src="https://img.shields.io/badge/Version-1.0.0-blue" alt="Version" />
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License" />
</p>

<h1 align="center">READLINE</h1>

<p align="center">
  <strong>A focused, distraction-free PDF reader.</strong><br/>
  Import any document and read with a calm, auto-paced rhythm.<br/>
  Build a daily habit, grow vocabulary, track every minute.
</p>

---

## How It Works

Import a PDF, pick a reading speed in words-per-minute, and let Readline scroll the text past a fixed focus zone:

| Zone | Role |
|------|------|
| **Past** | Fades out behind the focus line — context you've already read |
| **Focus** | The active reading line, anchored at the optical centre |
| **Upcoming** | Dimmed preview of what's next, easing your eyes forward |

Tap any word in the focus zone to look it up, save it to vocabulary, or hear it spoken. Sessions auto-record toward your daily target and streak — no manual logging.

## Reading Controls

| Setting | Range | What It Does |
|---------|-------|--------------|
| WPM Speed | 100–600 | Words per minute the focus line advances |
| Font Size | 8–48 | Reading text size |
| Line Spacing | 1.0–2.5 | Vertical density of the three-zone display |
| Focus Window | 1–5 lines | How many lines stay sharp around the focus |
| Theme | Light / Dark | "Modern Bibliophile" or "Midnight Library" |

**Daily Target** — Set a daily reading goal in minutes. The home screen shows progress; finishing the goal triggers a celebration and protects your streak.

**Daily Streak** — Consecutive days with at least one completed reading session. Milestones (3, 7, 14, 30, 100, 365) trigger an in-app celebration with confetti.

**Practice & Re-Read** — Replay any document at any time; re-reads still count toward minute totals and streak progress.

## Features

- **PDF Import & Extraction** — Pick any PDF, automatic text extraction with complexity scoring
- **Three-Zone Auto-Scroll** — Past / Focus / Upcoming with adjustable WPM, font, spacing, focus window
- **Vocabulary Collection** — Tap-to-save with auto-collected complex words, dictionary lookups, TTS playback
- **Spaced Repetition Review** — Flashcard sessions scheduled by interval (1d / 3d / 7d / 14d / 30d)
- **Streak Tracking** — Daily streaks with weekly activity ring and milestone badges
- **Analytics Dashboard** — Volume charts, velocity trends, focus scoring, session history
- **Daily Reading Target** — Configurable goal with live progress and completion celebration
- **Shareable Achievement Cards** — Render-to-image cards for streak / session / target achievements
- **Onboarding Flow** — 3-step welcome on first launch, skippable
- **Dual Theme** — Light + Dark with editorial typography (Newsreader, Inter, Literata)
- **Localization Ready** — Custom JSON-based i18n, currently shipping with English
- **Haptic & Sound Feedback** — Toggleable feedback on key interactions
- **Edge-to-Edge Display** — Android 15 ready, immersive reading on both platforms
- **Offline-First** — No cloud, no account; everything stored locally with Hive

## Screenshots

<!-- Add screenshots here -->

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.8+ / Dart 3.8+ |
| **State Management** | RxDart (BehaviorSubject + StreamBuilder) |
| **Dependency Injection** | GetIt |
| **Routing** | GoRouter (StatefulShellRoute.indexedStack) |
| **Storage** | Hive (local key-value, no cloud) |
| **Serialization** | Freezed + json_serializable |
| **Localization** | Custom JSON-based (en) |
| **Fonts** | Google Fonts — Newsreader (reading), Inter (UI), Literata (alt reading) |
| **PDF** | syncfusion_flutter_pdf + syncfusion_flutter_pdfviewer |
| **Charts** | fl_chart |
| **Sharing** | share_plus |
| **TTS** | flutter_tts |
| **File Picking** | file_picker + permission_handler |

## Architecture

Clean architecture + MVVM with **feature-first** organisation under `lib/features/` and shared cross-cutting code under `lib/core/`, `lib/data/`, and `lib/widgets/`.

```
lib/
├── app.dart                      # MaterialApp.router + theme + system bar overlay
├── main.dart                     # App entrypoint, Hive init, DI bootstrap
│
├── core/                         # Cross-cutting concerns
│   ├── constants/                # AppConstants, PersonalLinks
│   ├── di/                       # GetIt injection container
│   ├── extensions/               # ContextExtensions
│   ├── localization/             # AppLocalization, AppStrings, LanguageProvider
│   ├── router/                   # GoRouter setup + AppRoutes
│   ├── services/
│   │   ├── reading_engine_service.dart    # Auto-scroll engine (timer + state stream)
│   │   ├── pdf_processing_service.dart    # Extraction + complexity scoring
│   │   ├── streak_service.dart            # Daily streak + milestones
│   │   ├── vocabulary_service.dart        # Save, auto-collect, spaced repetition
│   │   ├── celebration_service.dart       # Milestone detection + triggers
│   │   ├── dictionary_service.dart        # Word lookup + Hive cache
│   │   ├── tts_service.dart               # Word playback
│   │   ├── share_card_service.dart        # Render-to-image achievement cards
│   │   ├── haptic_service.dart            # Toggleable haptics
│   │   └── form_submission_service.dart   # Support / bug-report forms
│   ├── theme/                    # AppColors, AppTypography, AppSpacing,
│   │                             #   AppGradients, AppRadius, AppBreakpoints,
│   │                             #   AppTracking, AppDurations
│   └── utils/                    # DateFormatter
│
├── data/                         # Persistence layer
│   ├── contracts/                # Abstract repository interfaces
│   ├── datasources/local/        # Hive box wrappers (one per entity)
│   ├── entities/                 # Freezed: ReadingState
│   ├── enums/                    # Domain enums
│   ├── models/                   # Hive-friendly model classes (toMap/fromMap)
│   └── repositories/             # Repository implementations
│                                 #   (Document, Preferences, Session, Vocabulary)
│
├── features/                     # Feature-first UI (one folder per route)
│   ├── about/                    # About + privacy + terms screens
│   ├── analytics/                # Charts, velocity trends, session history
│   ├── home/                     # Empty + active states, streak badge
│   ├── library/                  # Grid/list, filters, import flow
│   ├── onboarding/               # 3-step first-run flow
│   ├── reading/                  # Auto-scroll reader screen + viewmodel
│   ├── settings/                 # Preferences with live preview
│   ├── shell/                    # 4-tab bottom navigation shell
│   ├── splash/                   # Splash + startup routing
│   ├── support/                  # Help, bug report, rate app
│   └── vocabulary/               # Word cards, flashcard review
│
└── widgets/                      # Shared cross-feature widgets
                                  #   ReadlineButton, TapScale, GlassContainer,
                                  #   BrandMark, CelebrationOverlay, ShareCard,
                                  #   DailyTargetPicker, SheetHandle, TargetChip,
                                  #   ProgressRingPainter
```

### Data Flow

```
User Input → ViewModel (RxDart streams)
           → ReadingEngineService.tick()  (or service equivalent)
           → BehaviorSubject<ReadingState> emits
           → StreamBuilder rebuilds UI
           → Repository persists snapshot to Hive
```

ViewModels expose `BehaviorSubject<T>` fields named with a `$` suffix (e.g. `documents$`, `streak$`, `state$`). Screens subscribe via `StreamBuilder`. Singletons (`ReadingEngineService`, `StreakService`, repositories) are registered in `lib/core/di/injection.dart` and resolved via `getIt<T>()`.

### Localization

Custom JSON-based system with runtime loading:

```
assets/lang/
└── en.json    # English (LTR)
```

- **Access:** `AppStrings.homeTitle.tr` or `'home.title'.tr`
- **Parameters:** `AppStrings.generalDaysAgo.trParams({'n': '5'})`
- **RTL:** Auto-detected from JSON `_metadata.text_direction` when additional locales are added

### Persistence

All data is stored locally using Hive — no cloud backend:

| Box | Contents |
|-----|----------|
| `documents` | Imported PDFs metadata + extracted text |
| `preferences` | Theme, WPM, font, spacing, target, language, sound, haptic flags |
| `sessions` | Per-document reading session history with minutes + words |
| `vocabulary` | Saved words, auto-collected words, spaced-repetition schedule |
| `streak` | Current streak, max streak, last play date, milestones shown |
| `definitions_cache` | Cached dictionary lookups |
| `milestones` | Persisted milestone-shown flags |

## Build & Run

```bash
# Install dependencies
flutter pub get

# Run code generation (Freezed for ReadingState)
dart run build_runner build --delete-conflicting-outputs

# Run the app (debug)
flutter run

# Run the app on a specific device
flutter run -d 'iPhone 17 Pro'

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build release App Bundle (Play Store)
flutter build appbundle --release

# Build iOS release (no codesign — for archiving)
flutter build ios --release --no-codesign
```

If iOS reports a stale native-assets error after switching branches, a clean rebuild fixes it:

```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.framework
flutter pub get
(cd ios && pod install)
flutter run
```

## Testing

83 tests covering core services, splash rendering, and the app shell:

| Module | Tests | Coverage |
|--------|-------|----------|
| ReadingEngineService | 31 | WPM timing, chunk progression, pause/resume, completion |
| VocabularyService | 18 | Save, spaced repetition, review session ordering |
| StreakService | 16 | Daily streak, weekly activity, milestone labels |
| PdfProcessingService | 13 | Text extraction, complexity scoring, complex word detection |
| Splash render | 4 | Splash screen renders without overflow at common sizes |
| App shell smoke | 1 | `ReadlineApp` renders without crashing under full DI |

```bash
flutter test
```

## Project Structure

```
readline-app/
├── android/                       # Android shell (com.divinentra.henry.readline)
├── ios/                           # iOS shell + Podfile
├── macos/ linux/ windows/ web/    # Desktop + web runners
├── assets/
│   ├── lang/                      # Localization JSON files (en)
│   └── sample/                    # Bundled sample document(s)
├── lib/                           # Application source (see Architecture above)
├── test/
│   ├── services/                  # Service unit tests
│   ├── splash_render_test.dart    # Splash render correctness
│   └── widget_test.dart           # App shell smoke test
├── pubspec.yaml                   # Dependencies
└── README.md
```

## Design Decisions

- **No cloud backend** — Privacy-first, works fully offline, no account required
- **Three-zone auto-scroll** — Anchored focus line beats infinite-scroll for sustained attention
- **RxDart over BLoC** — Lightweight reactive state without boilerplate, ideal for stream-driven readers
- **Hand-written Hive models** — `hive_generator` is intentionally omitted to avoid `source_gen` conflicts with `freezed ^3.x`; models use simple `toMap` / `fromMap`
- **Custom JSON localization** — Runtime-switchable, mirrored across other apps in the ecosystem for consistency
- **Feature-first organisation** — Each feature folder owns its screens, viewmodels, and feature-scoped widgets; truly shared widgets live in `lib/widgets/`
- **Streak rewards consistency, not perfection** — Any completed session keeps the streak alive — perfect days aren't required
- **Spaced repetition over rote drill** — Vocabulary review uses fixed intervals to balance retention with low session cost

---

<p align="center">
  <strong>READLINE V1.0.0</strong><br/>
  Made for slow readers and curious minds.
</p>
