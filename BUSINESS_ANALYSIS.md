# Read-It: Business & Feature Analysis

## Product Overview

Read-It is a Flutter mobile app that transforms PDF documents into an immersive, auto-scrolling reading experience designed for English reading practice. Users import PDFs, and the app extracts text and presents it in a continuous bottom-to-top scroll at a controlled words-per-minute (WPM) rate, with adjustable spacing, font size, and a focus-highlight window. The app tracks reading sessions, calculates analytics, and provides progress insights.

---

## Target Audience

| Segment | Need | How Read-It Serves It |
|---------|------|----------------------|
| **English Language Learners** | Improve reading speed and fluency in English | Controlled-pace scrolling forces consistent reading speed; WPM tracking shows measurable improvement |
| **Students** | Process large volumes of academic PDFs efficiently | Import any PDF, adjust speed from 50-500 WPM, track time spent and words read |
| **Professionals** | Optimize reading during commutes or breaks | One-tap start, pause/resume, session memory, offline-first local storage |
| **Accessibility Users** | Reduced cognitive load, controlled reading pace | Focus window highlights current line, customizable font/spacing/contrast, dark mode |

---

## Implemented Features

### Core Reading Engine
- **PDF text extraction** via Syncfusion PDF library — handles text-based PDFs with page splitting and chunk optimization
- **Auto-scrolling display** — continuous bottom-to-top text scroll at user-defined WPM (50-500 range)
- **Play/pause/resume** controls for reading sessions
- **Skip forward/backward** — jump 10% of progress in either direction
- **Speed presets** — quick-switch between 150, 200, 250, 300 WPM plus fine-grained slider
- **Focus window** — configurable highlight zone (1-10 lines) that draws attention to the current reading position
- **Line spacing control** — adjustable from 1.0x to 3.0x
- **Font size control** — 12pt to 24pt range

### PDF Management
- **Device file import** — file picker filtered to `.pdf` files
- **Document library** — stores imported PDFs with metadata (title, page count, word count, creation date, last read)
- **Text complexity analysis** — automatic difficulty assessment (beginner through expert) based on word length and sentence structure
- **Reading time estimation** — calculates estimated reading time based on current WPM setting

### User Preferences
- **Theme switching** — light, dark, and system-follow modes with full Material Design 3 theming
- **Font family selection** — UI for choosing between Inter, Roboto, Open Sans, Lato, Montserrat
- **Reading presets** — one-tap Beginner (150 WPM, 2.0 spacing, 18pt), Intermediate (200 WPM, 1.5 spacing, 16pt), and Advanced (250 WPM, 1.2 spacing, 14pt) profiles
- **Persistent settings** — all preferences saved to local SQLite database
- **Vocabulary collection toggle** — setting to enable/disable word collection during reading
- **Analytics toggle** — setting to enable/disable session tracking

### Analytics & Tracking
- **Session recording** — tracks start/end time, words read, average speed per session
- **Reading stats** — total sessions, total words read, average speed, total reading time
- **Reading streaks** — consecutive-day tracking with 7-day activity grid visualization
- **Session quality scoring** — multi-factor score weighting speed (40%), duration (30%), and words read (30%)
- **Reading efficiency** — ratio of actual speed to target speed (below/on/above target classification)
- **Insights engine** — generates contextual tips based on speed performance and streak data

### Architecture Quality
- **Clean Architecture** — domain, data, and presentation layers with clear dependency direction
- **Dependency injection** — GetIt service locator with full wiring
- **Provider state management** — four independent ChangeNotifier providers
- **Local-first** — all data stored in SQLite, works completely offline

---

## Missing & Incomplete Features

### Critical — Blocks Compilation

| Item | Description | Impact |
|------|-------------|--------|
| **AnalyticsService** | Referenced in DI but file does not exist | App will not compile |
| **DatabaseService** | Referenced in DI but file does not exist | App will not compile |
| **PdfRemoteDataSource** | Imported by PdfRepositoryImpl but file does not exist | App will not compile |
| **3 Analytics widgets** | `progress_chart_widget.dart`, `recent_sessions_widget.dart`, `insights_widget.dart` imported by analytics screen but missing | Analytics screen crashes |
| **DB schema mismatch** | `user_preferences` table missing columns for `font_family`, `enable_vocabulary_collection`, `enable_analytics` that the model writes | Runtime crash on preferences save |
| **`Colors.gold` reference** | Used in `stats_overview_widget.dart` and `reading_streak_widget.dart` — not a valid Flutter constant | Compile error |
| **Repository interface gaps** | `UserPreferencesRepositoryImpl` and `PdfRepositoryImpl` don't implement all methods defined in their interfaces | Compile error |

### High Priority — Core Functionality Bugs

| Item | Description | Business Impact |
|------|-------------|----------------|
| **Scroll engine breaks after stop** | `ReadingDisplayService` closes its `StreamController` on stop — cannot restart reading without app restart | Users cannot read more than one session per app launch |
| **Resume doesn't deliver events** | After pause/resume, the provider no longer receives position updates from the service | Reading appears frozen after resume |
| **ScrollController memory leak** | `ReadingDisplayWidget` creates a new `ScrollController` on every rebuild without disposing the old one | App slows down and crashes during long reading sessions |
| **Session serialization bug** | `settingsSnapshot` stored as `Map.toString()` but read back expecting a `Map` — throws `TypeError` | Cannot retrieve any saved session from the database |
| **Analytics time calculations** | SQL `CASE` thresholds treat millisecond durations as seconds (off by 1000x) | All duration-based analytics are wrong |
| **strftime on integer timestamps** | `getSessionsByDayOfWeek` uses `strftime` on millisecond integers instead of date strings | Day-of-week analytics return garbage data |

### Medium Priority — Stubbed Features

| Feature | Current State | Effort to Complete |
|---------|---------------|-------------------|
| **Cloud import** (Google Drive, Dropbox) | SnackBar "coming soon" | Large — requires OAuth integration, cloud SDK setup |
| **URL import** | SnackBar "coming soon" | Medium — HTTP download + PDF validation |
| **Recent document selection** | `// TODO: Select document` — tapping does nothing | Small — wire tap handler to load document into reader |
| **Reading goals persistence** | `print()` stub — goals exist only in memory | Small — create goals table and datasource |
| **Clear cache** | Dialog confirms but never deletes anything | Small — call repository clear methods |
| **Settings import** | SnackBar "coming soon" | Medium — file picker + JSON deserialization |
| **Settings export** | Shows raw `Map.toString()` in a SnackBar | Small — proper JSON file export |
| **Progress chart** | Widget file missing entirely | Medium — charting library + data binding |

### Not Yet Started — Planned Features

| Feature | Vision Doc Reference | Business Value |
|---------|---------------------|---------------|
| **Vocabulary builder** | DB table exists but no UI or collection logic | High — core differentiator for language learners; flashcard integration |
| **Comprehension mode** | Optional periodic pauses for reflection | Medium — pedagogical value for deeper learning |
| **Break reminders** | Intelligent pause suggestions based on reading duration | Medium — reduces eye strain, improves retention |
| **Reading profiles** | Save named profiles for different document types | Medium — power users reading mixed content |
| **Cloud sync** | Multi-device synchronization of progress | High — users expect cross-device continuity |
| **Onboarding flow** | Tutorial + reading assessment + initial setup | High — critical for first-time user retention |
| **Social features** | Progress sharing, leaderboards | Low — nice-to-have for engagement |
| **Content partnerships** | Curated PDF libraries | Low — revenue opportunity, not core product |
| **Localization** | Multi-language UI support | Medium — app targets non-native English speakers who may prefer native-language UI |
| **Accessibility** | Screen reader, high contrast, color blindness support | High — aligns with target audience needs |
| **Push notifications** | Reading reminders and streak notifications | Medium — drives daily engagement |
| **Search within document** | Find text in imported PDFs | Medium — essential for academic users |

---

## Architectural Concerns

### Redundant Analytics Layer
`AnalyticsRepositoryImpl` is a copy of `ReadingSessionRepositoryImpl` — both query the same `reading_sessions` table with identical logic. This should be consolidated into a single repository.

### Missing Error Handling Pattern
Repositories throw raw exceptions. The codebase has no sealed `Result<T>` type or typed `Failure` classes. Errors propagate as strings via `catch (e) { _error = e.toString(); }`, losing type information and making error recovery impossible.

### No Offline-to-Online Strategy
The app is fully local-first (SQLite), but the vision document describes cloud sync, backup/restore, and multi-device support. There is no sync engine, conflict resolution strategy, or server-side API defined. This is a significant architectural gap if cloud features are planned.

### No Test Coverage
Zero tests exist. The `test/` directory is empty. Given the bugs identified above (stream lifecycle, serialization, SQL calculations), automated testing is critical before any release.

---

## Competitive Position

### Strengths
- **Purpose-built for reading practice** — not a general PDF viewer, but a speed-training tool with analytics
- **Offline-first** — no account required, no network dependency for core features
- **Rich analytics** — session quality scoring, streak tracking, and efficiency metrics go beyond simple timers
- **Customization depth** — WPM, spacing, font, focus window, presets create a personalized experience

### Weaknesses
- **Cannot compile** — multiple missing files prevent the app from building
- **Core reading loop is broken** — stop/resume cycle fails, making the primary feature non-functional
- **No vocabulary integration** — the database table exists but the feature is entirely unwired
- **No onboarding** — first-time users land on an empty home screen with no guidance
- **Single import source** — device file picker only; no cloud or URL import

### Opportunities
- **Language learning market** — growing demand for self-paced English learning tools, especially in Asia and Latin America
- **Academic niche** — students processing research papers and textbooks could drive organic adoption
- **Freemium model** — basic reading free, premium analytics/cloud/profiles as paid tier

### Threats
- **PDF viewer apps** with speed-reading modes (Adobe Acrobat, Xodo) could add similar features
- **Dedicated speed-reading apps** (Spreeder, ReadMe!) already exist, though none focus on PDF + language learning
- **AI reading assistants** (ChatGPT, Claude) can summarize PDFs, reducing the need to read them at controlled pace

---

## Recommended Priorities

### Phase 1 — Make It Work (1-2 weeks)
1. Fix all compilation blockers (missing files, schema mismatches, interface gaps)
2. Fix the scroll engine stream lifecycle so reading can stop and restart
3. Fix the ScrollController memory leak in the reading display widget
4. Fix session serialization so sessions can be saved and retrieved
5. Wire "select recent document" to actually open the document

### Phase 2 — Make It Useful (2-3 weeks)
1. Build the vocabulary builder (tap-to-collect words, vocabulary list screen, review mode)
2. Add an onboarding flow (welcome screen, reading speed assessment, initial preferences)
3. Complete the analytics screen (progress chart, recent sessions, insights widgets)
4. Add search within imported documents
5. Add reading goals with persistence

### Phase 3 — Make It Grow (4-6 weeks)
1. Cloud import (Google Drive integration)
2. Localization (Arabic, Spanish, Chinese, Portuguese UI translations)
3. Push notifications for streak reminders
4. Accessibility audit and screen reader support
5. Write unit and widget tests for core services and providers

### Phase 4 — Make It Profitable (6-8 weeks)
1. Freemium gate (limit free tier to 3 documents or 100 WPM max)
2. Cloud sync for premium users
3. Reading profiles (save/load named configurations)
4. App store listing optimization and beta release
