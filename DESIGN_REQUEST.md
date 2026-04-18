# Read-It: Complete UI/UX Design Request

## For: UI/UX Designer
## From: Product & Engineering Team
## Date: April 18, 2026

---

## 1. Product Context

### What Is Read-It?
Read-It is a mobile app that converts PDF documents into a controlled, auto-scrolling reading experience for English language practice. Users import PDFs, the app extracts text, and presents it in a continuous bottom-to-top scroll at a user-defined pace (words per minute). The app tracks reading sessions, streaks, and analytics to help users measurably improve their English reading speed and comprehension.

### Why Does It Exist?
Existing PDF readers are built for document viewing — not for training. Read-It is purpose-built for deliberate reading practice: controlled pace, focus window, progress tracking, and vocabulary building. It sits at the intersection of a PDF reader and a language learning tool.

### Target Users

| Persona | Age | Context | Key Need | Pain Point |
|---------|-----|---------|----------|------------|
| **Lina** — ESL Student | 22 | University, non-native English speaker, reads academic papers | Increase reading speed from 120 to 200+ WPM | Gets lost in dense paragraphs, loses place, reads same line twice |
| **Marco** — Working Professional | 34 | Commutes 45 min, reads industry reports on phone | Use commute time productively | Can't control reading pace in regular PDF viewers |
| **Aisha** — Self-learner | 28 | Learning English independently, practices with ebooks | Track daily progress, build reading habit | No feedback on improvement, no streak motivation |
| **David** — Accessibility User | 45 | Has ADHD, benefits from guided focus | Reduce cognitive load, stay on track | Standard text walls are overwhelming, loses focus |

### Emotional Design Goals
- **Calm confidence** — The app should feel like a quiet study room, not a noisy classroom
- **Visible progress** — Users should always see how far they've come
- **Zero friction** — Import a PDF and start reading in under 10 seconds
- **Personalized mastery** — The experience adapts to the user's level and preferences

---

## 2. Design System Requirements

### Brand Identity

**App Name:** Read-It
**Tagline:** "Read at your pace. Grow at your speed."

**Brand Personality:**
- Minimal, not sterile — warm neutrals with a single accent color
- Intellectual, not academic — feels smart without feeling heavy
- Encouraging, not gamified — progress without pressure

**Logo Direction:**
- A stylized open book combined with a forward-moving element (scroll/flow/wave)
- Should work as a monochrome icon on both light and dark backgrounds
- App icon: rounded square with the logomark, no text

### Color Palette

**Current implementation uses default Material purple (#6750A4).** This needs to change to align with the reading/learning brand.

**Requested palette direction:**

| Role | Purpose | Mood |
|------|---------|------|
| **Primary** | Buttons, active states, brand identity | Deep teal or warm indigo — intellectual but inviting |
| **Secondary** | Supporting elements, chips, secondary buttons | Muted complementary tone |
| **Tertiary** | Accents, highlights, vocabulary features | Warm amber or coral for energy |
| **Surface** | Cards, sheets, reading area background | Warm off-white (light) / Deep charcoal (dark) — NOT pure white/black |
| **Background** | Page background behind cards | Subtle warmth — cream tint (light) / near-black (dark) |
| **Success** | Streaks, completed sessions, positive metrics | Natural green |
| **Warning** | Paused states, streak at risk | Amber |
| **Error** | Errors, destructive actions | Soft red — not aggressive |
| **Reading Surface** | The actual reading text area | Special consideration: must be optimized for long reading sessions, reduce eye strain. Consider a subtle warm tint (#FDFAF6 light / #1A1A1E dark) |

**Deliver:** Full color system with light and dark mode variants, contrast ratios (WCAG AA minimum), and semantic token names.

### Typography

**Current implementation:** Inter font family (Regular, Medium, SemiBold, Bold) with Material 3 type scale.

**Requirements:**
- **Reading font:** A highly legible serif or sans-serif optimized for long-form reading on mobile screens. Consider: Source Serif Pro, Literata, Merriweather, or Noto Serif. The reading font is the core product experience — it must be excellent at body sizes (14-20pt) with generous x-height
- **UI font:** A clean sans-serif for interface elements. Inter is fine, but consider matching weight ranges to the reading font
- **Monospace (optional):** For WPM numbers, timers, statistics — gives a "dashboard" feel to metrics

**Deliver:** Type scale with sizes, weights, and line heights for: Display, Headline, Title, Body (reading), Body (UI), Label, Caption. Both light and dark mode text colors.

### Iconography
- Outline style, 1.5-2px stroke weight, rounded caps
- Consistent 24px grid
- Custom icons needed for: reading speed (tachometer variant), focus window, line spacing, text scroll, streak fire, vocabulary book
- Standard Material icons are acceptable for: settings gear, analytics chart, file upload, play/pause/skip, theme toggle

### Spacing & Layout
- 8px grid system
- Card border radius: 16px (large cards), 12px (medium), 8px (small elements)
- Content padding: 16px horizontal, 24px for sections
- Bottom sheet handle: 40x4px, centered, 12px top margin

### Motion & Animation
- Page transitions: shared axis (horizontal for peer navigation, vertical for hierarchy)
- Bottom sheet: spring animation with slight overshoot
- Reading scroll: buttery smooth, 60fps mandatory — this is the core UX
- Stats counters: count-up animation when appearing
- Streak fire icon: subtle pulse/glow when streak is active
- Speed changes: smooth interpolation, not jump cuts
- Progress bar: animated fill, not instant jumps

---

## 3. Screen-by-Screen Design Specifications

### 3.1 Onboarding Flow (NEW — Does Not Exist Yet)

**Purpose:** First-time user experience. Sets tone, collects minimal preferences, gets user to first reading session fast.

**Flow:** 3 screens maximum, skippable.

#### Screen 1: Welcome
- App logo + tagline animation
- "Read at your pace. Grow at your speed."
- Hero illustration: abstract representation of flowing text (not a literal book)
- Single CTA: "Get Started"
- Skip link: "Skip to app"

#### Screen 2: Reading Level Assessment
- "How fast do you read?"
- 4 large tappable cards in a 2x2 grid:
  - **Beginner** (50-150 WPM) — icon: seedling/sprout — green accent — "I'm learning English"
  - **Intermediate** (150-250 WPM) — icon: open book — blue accent — "I read comfortably"
  - **Advanced** (250-350 WPM) — icon: rocket — orange accent — "I want to read faster"
  - **Expert** (350-500 WPM) — icon: lightning bolt — red accent — "I'm speed reading"
- Selecting a card auto-configures WPM, spacing, and font size defaults
- "I'll customize later" link at bottom

#### Screen 3: Import First PDF
- Large drop zone / illustration area
- "Import your first PDF to start reading"
- Primary button: "Choose from Files"
- Secondary option: "Try with sample text" (loads a built-in demo paragraph)
- This screen should feel like the beginning of a journey, not a form

**Deliver:** High-fidelity mockups for all 3 screens, both light and dark mode.

---

### 3.2 Home Screen — The Reading Hub

**Purpose:** The primary screen users see every session. Must balance "quick start reading" with "see my progress" without clutter.

**Current implementation:** AppBar with title + 2 icon buttons, stats bar, reading display area, reading controls, and a FAB.

#### Redesign Direction

**Layout — 3 Zones:**

```
┌─────────────────────────────┐
│  Status Bar (system)        │
├─────────────────────────────┤
│                             │
│  TOP BAR                    │
│  App title + nav icons      │
│  (settings, analytics)      │
│                             │
├─────────────────────────────┤
│                             │
│  STATS RIBBON               │
│  Compact horizontal strip   │
│  Documents | Speed | Words  │
│  + session state badge      │
│                             │
├─────────────────────────────┤
│                             │
│                             │
│  READING AREA               │
│  (This is the hero zone)    │
│                             │
│  - Empty state: import CTA  │
│  - Loading: progress anim   │
│  - Active: scrolling text   │
│  - Error: retry card        │
│                             │
│                             │
│                             │
├─────────────────────────────┤
│                             │
│  CONTROLS DOCK              │
│  Play/Pause | Skip | Speed  │
│  Spacing | Font | Focus     │
│                             │
├─────────────────────────────┤
│  Bottom Safe Area           │
└─────────────────────────────┘
```

#### Top Bar
- App title "Read-It" in brand font weight (semi-bold, not bold)
- Two icon buttons right-aligned: Settings (gear), Analytics (chart)
- Transparent background, no elevation — the bar blends with the page
- No hamburger menu — the app has 3 screens, use direct navigation

#### Stats Ribbon
- Compact horizontal container with rounded corners, tinted surface color
- Three stat cards side by side, each with: small icon (16px), label (caption), value (headline), optional suffix
- Stats: Documents (count), Speed (current WPM), Words Read (session total)
- Session state badge in top-right corner of ribbon: Reading (green dot + label), Paused (amber), Completed (blue), Ready (grey)
- The ribbon should feel like a dashboard instrument cluster — clean, at-a-glance

#### Reading Area — Empty State
- This is what users see when no PDF is loaded
- Large illustrated area (not just an icon) — an open book with flowing text lines, abstract and warm
- Headline: "No PDF loaded"
- Subtext: "Import a PDF to start reading"
- Primary button: "Import PDF" with upload icon
- The empty state should be inviting, not blank — it's a call to action

#### Reading Area — Loading State
- Centered circular progress with percentage
- "Processing PDF..." label below
- Document title (if available) shown above progress
- Subtle animated dots or pulse to indicate activity
- Cancel button below

#### Reading Area — Active Reading State
**This is the most critical screen in the entire app. Design it as if nothing else exists.**

- **Reading surface:** Full-width container with subtle border and warm background tint optimized for eye comfort
- **Text rendering:** Paragraphed text, left-aligned, with the user's chosen font, size, and line spacing
- **Focus window highlight:** The current reading line(s) are at full opacity. Lines above and below the focus window gradually fade to ~30% opacity. This creates a natural spotlight effect that guides the eye
- **Progress bar:** Thin horizontal bar at the top of the reading area. Shows percentage numerically on the right. Uses primary color fill with surface color track
- **Current word panel:** Below the reading area, a card showing:
  - "Current Word" label
  - The word in large bold text
  - Three small metrics in a row: Speed (WPM), Time (mm:ss), Words (count)
  - This panel uses primary container background

**Focus Window Visualization — CRITICAL:**
The focus window is what makes Read-It different from any other PDF reader. Design options to explore:
1. **Gradient fade:** Full opacity at focus, gradient to 30% above/below
2. **Highlighted band:** A subtle background color band behind the focused lines
3. **Peripheral blur:** Lines outside focus have slight blur (may have performance implications)
4. **Dimming overlay:** Semi-transparent overlay on non-focused text

**Deliver:** Mockups showing all 4 focus window approaches so we can pick the best one.

#### Reading Area — Error State
- Error icon (outline circle with exclamation)
- "Error processing PDF" headline
- Error description in body text
- "Try Again" primary button
- Sympathetic but not dramatic — errors happen

#### Controls Dock
**This is the control center. Must be accessible during reading without breaking immersion.**

- Docked to bottom of screen, above safe area
- Subtle top border or shadow to separate from reading area
- Background matches surface color

**Main Controls Row (center-aligned):**
- Skip backward button (outlined icon button, left)
- Play/Pause button (FAB-sized, primary color, center) — this is the largest touch target on screen
  - Play state: play icon + "Start" label
  - Reading state: pause icon + "Pause" label
  - Paused state: play icon + "Resume" label
- Skip forward button (outlined icon button, right)

**Speed Control Row:**
- "Reading Speed" label left-aligned, current WPM value right-aligned in primary color
- Preset chips in a row: 150, 200, 250, 300 — FilterChip style, selected state for current
- Continuous slider below chips: 50-500 range, 10 WPM steps
- The chips and slider should be visually connected — selecting a chip snaps the slider

**Quick Settings Row:**
- Four equally-spaced compact buttons:
  - **Spacing** — line spacing icon + current value ("1.5x")
  - **Font Size** — text size icon + current value ("16")
  - **Focus** — focus icon + current value ("3")
  - **Settings** — gear icon (opens preset dialog)
- Each button opens a dialog with a slider + apply/cancel
- Buttons have outlined style with icon + label + value in stacked layout

**Design Consideration:** During active reading, the controls dock could auto-hide after 3 seconds and reappear on tap. This gives more reading real estate. Design both states: controls visible and controls hidden (with a subtle "tap to show controls" hint).

---

### 3.3 PDF Import Bottom Sheet

**Purpose:** Import PDFs from multiple sources. Currently opens as a DraggableScrollableSheet.

**Layout:**

```
┌─────────────────────────────┐
│      ─── handle ───         │
├─────────────────────────────┤
│  📁 Import PDF        ✕    │
├─────────────────────────────┤
│  Import from                │
│                             │
│  ┌─────────────────────┐    │
│  │ 📂 Device Storage   │ →  │
│  │    Browse files      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ ☁️ Cloud Storage    │    │
│  │    Google Drive...   │ CS │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 🔗 URL             │    │
│  │    Import from web   │ CS │
│  └─────────────────────┘    │
│                             │
├─────────────────────────────┤
│  Recent Documents           │
│                             │
│  ┌──┬──────────────────┐    │
│  │📄│ Document Title    │ >  │
│  │  │ 12 pages • 3.4K  │    │
│  └──┴──────────────────┘    │
│                             │
│  ┌──┬──────────────────┐    │
│  │📄│ Another Doc       │ >  │
│  │  │ 5 pages • 1.2K   │    │
│  └──┴──────────────────┘    │
└─────────────────────────────┘
```

**Design Details:**
- Sheet handle: 40x4px rounded bar, centered, muted color
- Import options: card-style rows with icon container (colored background), title, subtitle, and either a chevron (active) or "Coming Soon" badge (disabled)
- Active options use primary container icon background; disabled use surface variant
- "Coming Soon" badge: small pill shape, surface variant background, small text
- Recent documents section: only shown if documents exist
- Each document row: PDF icon in muted container, title (single line, ellipsis), page count + word count subtitle, chevron indicator
- Document rows should have subtle tap feedback (ripple)
- Consider adding a document thumbnail (page preview) instead of generic PDF icon — this helps users identify documents visually

**Deliver:** Bottom sheet in expanded and collapsed states, with and without recent documents.

---

### 3.4 Settings Screen

**Purpose:** All user preferences organized by category.

**Current implementation:** Three section widgets stacked vertically in a scrollable view, plus a reset button.

#### Layout Structure

```
┌─────────────────────────────┐
│  ← Settings                 │
├─────────────────────────────┤
│                             │
│  ┌─ Reading Settings ─────┐ │
│  │                         │ │
│  │  Reading Speed          │ │
│  │  [====●=========] WPM   │ │
│  │  50              500    │ │
│  │                         │ │
│  │  Line Spacing           │ │
│  │  [======●=======] 1.5x  │ │
│  │                         │ │
│  │  Font Size              │ │
│  │  [====●=========] 16pt  │ │
│  │                         │ │
│  │  Focus Window           │ │
│  │  [===●==========] 3     │ │
│  │                         │ │
│  │  Quick Presets           │ │
│  │  [Beginner] [Inter] [Adv]│ │
│  └─────────────────────────┘ │
│                             │
│  ┌─ Appearance ────────────┐ │
│  │                         │ │
│  │  Theme Mode             │ │
│  │  [Light|Dark|System]    │ │
│  │                         │ │
│  │  Font Family            │ │
│  │  ○ Inter ○ Roboto ○ ... │ │
│  │                         │ │
│  │  ┌─ Preview ──────────┐ │ │
│  │  │ Sample text with   │ │ │
│  │  │ current settings   │ │ │
│  │  │ applied live       │ │ │
│  │  └────────────────────┘ │ │
│  └─────────────────────────┘ │
│                             │
│  ┌─ Advanced ──────────────┐ │
│  │  Vocabulary Collection  │ │
│  │  [toggle]               │ │
│  │  Analytics & Tracking   │ │
│  │  [toggle]               │ │
│  │  ─────────────────────  │ │
│  │  Export Settings     >  │ │
│  │  Import Settings     >  │ │
│  │  Clear Cache         >  │ │
│  └─────────────────────────┘ │
│                             │
│  ┌─ Reset Settings ────────┐ │
│  │  ⚠ Reset to Defaults   │ │
│  │  Destructive action     │ │
│  └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

**Section Design Pattern:**
- Each section is a card with rounded corners (12px), subtle border, surface background
- Section header: icon (primary color) + title (titleLarge, primary color)
- 20px spacing between controls within a section
- 24px spacing between sections

**Slider Design:**
- Label left-aligned, current value right-aligned in a colored pill badge
- Each value badge uses a different color from the palette:
  - Speed: primary container
  - Spacing: secondary container
  - Font size: tertiary container
  - Focus window: surface variant
- Slider below the label row
- Min/max labels below the slider in caption text
- Slider thumb: larger than default (for touch accessibility), filled with track color

**Preset Buttons:**
- Three equally-spaced cards in a row
- Each preset card: icon (speed gauge), preset name (label), settings summary (2-line body small)
- Color coding: Beginner=green, Intermediate=blue, Advanced=orange
- Outlined border with colored accent, fills on tap

**Theme Mode Selector:**
- SegmentedButton (Material 3) with three segments: Light (sun icon), Dark (moon icon), System (auto icon)
- Description text below: "Choose how the app appearance should look"

**Font Family Selector:**
- Horizontal Wrap of FilterChips
- Each chip shows the font name rendered in that font (if bundled)
- Selected chip uses primary container color

**Live Preview Panel:**
- Container with surface variant background and subtle border
- Shows "Sample Reading Text" title in current settings
- Body paragraph showing current font, size, and line spacing applied
- Bottom row: speed badge + spacing badge

**Toggle Settings:**
- Card style with icon container (colored), title, description, and Switch widget
- Icon container: small rounded square with tinted background

**Data Management Actions:**
- List tile style with icon container, title, description, and chevron
- Destructive actions (Clear Cache) use error color accent
- Each action opens either a dialog or triggers a SnackBar

**Reset Button:**
- Full-width container at bottom
- Error container background with error border
- Warning icon, title in error color, description text
- "Reset to Defaults" outlined button in error color
- Opens confirmation dialog before executing

**Deliver:** Full settings screen scrollable mockup, including all dialog/sheet designs for: line spacing dialog, font size dialog, focus window dialog, presets dialog, reset confirmation dialog, clear cache confirmation dialog.

---

### 3.5 Analytics Screen

**Purpose:** Show reading progress, stats, streaks, and insights. Motivational and informational.

**Current implementation:** Five stacked widgets (stats overview, streak, progress chart, insights, recent sessions). Three widget files are missing.

#### Layout Structure

```
┌─────────────────────────────┐
│  ← Analytics          🔄   │
├─────────────────────────────┤
│                             │
│  ┌─ Reading Statistics ────┐│
│  │                 Last 30d││
│  │  ┌──────┐ ┌──────┐     ││
│  │  │Total │ │Words │     ││
│  │  │Sess. │ │Read  │     ││
│  │  │ 24   │ │12.4K │     ││
│  │  └──────┘ └──────┘     ││
│  │  ┌──────┐ ┌──────┐     ││
│  │  │Avg   │ │Total │     ││
│  │  │Speed │ │Time  │     ││
│  │  │215WPM│ │4h 32m│     ││
│  │  └──────┘ └──────┘     ││
│  │  ┌──────┐ ┌──────┐     ││
│  │  │Curr. │ │Long. │     ││
│  │  │Streak│ │Streak│     ││
│  │  │ 7 🔥 │ │ 14 🏆│     ││
│  │  └──────┘ └──────┘     ││
│  └─────────────────────────┘│
│                             │
│  ┌─ Reading Streak ────────┐│
│  │  🔥 Reading Streak      ││
│  │                         ││
│  │  ┌─────────────────┐    ││
│  │  │   🔥  7  days   │    ││
│  │  │  Keep it going! │    ││
│  │  └─────────────────┘    ││
│  │                         ││
│  │  [Longest: 14] [Days: 28]│
│  │                         ││
│  │  Recent Activity        ││
│  │  M  T  W  T  F  S  S   ││
│  │  ●  ●  ●  ●  ●  ○  ●   ││
│  └─────────────────────────┘│
│                             │
│  ┌─ Progress Chart (NEW) ──┐│
│  │  📊 Reading Progress    ││
│  │                         ││
│  │  [Daily|Weekly|Monthly] ││
│  │                         ││
│  │  ┌─────────────────┐    ││
│  │  │    Bar/Line      │    ││
│  │  │    Chart         │    ││
│  │  │    Showing       │    ││
│  │  │    WPM/Words     │    ││
│  │  │    Over Time     │    ││
│  │  └─────────────────┘    ││
│  │                         ││
│  │  Trend: ↑ 12% vs last  ││
│  └─────────────────────────┘│
│                             │
│  ┌─ Insights (NEW) ────────┐│
│  │  💡 Reading Insights    ││
│  │                         ││
│  │  ┌─────────────────┐    ││
│  │  │ 🚀 Speed Up!    │    ││
│  │  │ Your avg speed  │    ││
│  │  │ increased 15%   │    ││
│  │  │ this week       │    ││
│  │  └─────────────────┘    ││
│  │                         ││
│  │  ┌─────────────────┐    ││
│  │  │ 🔥 Streak!      │    ││
│  │  │ 7 days in a row │    ││
│  │  │ Keep going!     │    ││
│  │  └─────────────────┘    ││
│  └─────────────────────────┘│
│                             │
│  ┌─ Recent Sessions (NEW) ─┐│
│  │  📋 Recent Sessions     ││
│  │                         ││
│  │  Today                  ││
│  │  ┌──┬──────────────┐    ││
│  │  │📄│ Doc Title     │    ││
│  │  │  │ 215 WPM • 12m │    ││
│  │  │  │ ████████░░ 80%│    ││
│  │  │  │ Quality: Good │    ││
│  │  └──┴──────────────┘    ││
│  │                         ││
│  │  Yesterday              ││
│  │  ┌──┬──────────────┐    ││
│  │  │📄│ Another Doc   │    ││
│  │  │  │ 190 WPM • 25m │    ││
│  │  │  │ █████████░ 95%│    ││
│  │  │  │ Quality: Great│    ││
│  │  └──┴──────────────┘    ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Stats Overview Widget
- Section card with header: analytics icon + "Reading Statistics" + "Last 30 days" badge
- 6 stat cards in a 2x3 grid (12px gaps)
- Each stat card: colored tinted background, icon top-left, value large + bold, label below
- Color assignments: sessions=primary, words=secondary, speed=tertiary, time=surface, current streak=orange, longest streak=amber/gold
- Empty state: large analytics icon, "No Reading Data Yet" headline, "Start reading to see your statistics here" subtext, "Start Reading" button

#### Reading Streak Widget
- Section card with fire icon header in orange
- Hero streak display: large container with gradient background (orange tint), fire icon + large streak number + "days" label, motivational text below
- Active streak: orange gradient. Inactive: grey gradient
- Two stat cards below: "Longest Streak" (trophy icon, amber) and "Total Reading Days" (calendar icon, primary)
- 7-day activity row: circles for each day of the week, filled orange with checkmark for read days, grey outline for unread days, day abbreviations below each circle
- Empty streak state: outlined fire icon, "Start Your Reading Streak" headline, "Read every day to build your streak" subtext, orange "Start Reading" button

#### Progress Chart Widget (NEW — needs full design)
- Section card with chart icon header
- Time range selector: SegmentedButton with Daily / Weekly / Monthly options
- Chart area: 200px height
  - **Daily view:** Bar chart showing words read per day (last 7 days), bars filled with primary color gradient
  - **Weekly view:** Line chart showing average WPM over last 4 weeks, with data points and smooth curve
  - **Monthly view:** Bar chart showing total reading time per month (last 6 months)
- Trend indicator below chart: up/down arrow with percentage change vs previous period
- X-axis labels: day names, week numbers, or month abbreviations
- Y-axis: auto-scaled with 4-5 grid lines
- Chart should feel lightweight — thin lines, soft colors, not heavy corporate charts

#### Insights Widget (NEW — needs full design)
- Section card with lightbulb icon header
- Stack of insight cards, each with:
  - Emoji icon or small illustration left-aligned
  - Insight title (bold)
  - Insight description (1-2 lines)
  - Optional action button
- Insight types:
  - **Speed improvement:** "Your average speed increased X% this week" (rocket emoji)
  - **Streak milestone:** "You've read X days in a row!" (fire emoji)
  - **Reading goal:** "You're on track to hit your weekly goal" (target emoji)
  - **Best session:** "Your best session this week: X WPM for Y minutes" (star emoji)
  - **Vocabulary:** "You collected X new words this week" (book emoji)
  - **Consistency:** "You read at the same time every day — great habit!" (clock emoji)
- Cards should feel like friendly notifications, not alerts
- Limit to 3-4 insights to avoid scroll fatigue

#### Recent Sessions Widget (NEW — needs full design)
- Section card with list icon header
- Sessions grouped by date: "Today", "Yesterday", "This Week", etc.
- Each session row:
  - PDF icon or document thumbnail
  - Document title (single line, ellipsis)
  - Metrics row: speed (WPM) + duration (mm:ss)
  - Mini progress bar showing completion percentage
  - Quality badge: Excellent (green), Good (blue), Fair (orange), Poor (red)
- Show last 10 sessions maximum, with "View All" link if more exist
- Empty state: "No sessions yet. Start reading to see your history."

**Deliver:** Full analytics screen mockup with all 5 sections populated, plus empty states for each section. Both light and dark mode.

---

### 3.6 Vocabulary Screen (NEW — Does Not Exist Yet)

**Purpose:** Browse, review, and practice collected vocabulary words. The database table exists but there is no UI.

#### Entry Point
- New navigation item — either a bottom navigation bar tab (if we add bottom nav) or accessible from the home screen / analytics screen
- Badge showing uncollected word count

#### Word Collection During Reading
- During active reading, user can **long-press any word** to collect it
- A small toast/chip appears: "Word added: [word]" with an undo option
- The word is saved with its surrounding sentence as context

#### Vocabulary List Screen

```
┌─────────────────────────────┐
│  ← Vocabulary        🔍 ⋮  │
├─────────────────────────────┤
│  42 words collected         │
│  [All] [New] [Learning] [✓] │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │  ephemeral           │    │
│  │  "...the ephemeral   │    │
│  │   nature of digital  │    │
│  │   content..."        │    │
│  │  Added 2 days ago    │    │
│  │  From: Research.pdf  │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │  ubiquitous          │    │
│  │  "...has become      │    │
│  │   ubiquitous in      │    │
│  │   modern society..." │    │
│  │  Added today         │    │
│  │  From: Article.pdf   │    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

- Search bar at top
- Filter chips: All, New, Learning, Mastered
- Word cards with: word (large, bold), context sentence (italicized, with the word highlighted in the sentence), collection date, source document name
- Swipe actions: swipe right to mark as learned, swipe left to delete
- Tap a word to expand: show definition (if dictionary API integrated), example sentences, option to practice

#### Flashcard Review Mode
- Full-screen card flip interaction
- Front: the word in large centered text
- Back: context sentence + definition
- Bottom controls: "Don't Know" (left, red tint), "Know It" (right, green tint)
- Progress bar at top showing position in review deck
- Session summary at end: X words reviewed, X marked as known

**Deliver:** Vocabulary list screen, word detail expanded state, flashcard review mode (front and back), and the long-press word collection interaction during reading.

---

### 3.7 Document Library Screen (NEW — Does Not Exist Yet)

**Purpose:** Manage all imported PDFs. Currently, documents only appear in the import bottom sheet's "Recent Documents" section.

```
┌─────────────────────────────┐
│  ← My Library        🔍 ⊞  │
├─────────────────────────────┤
│  [All] [Reading] [Completed]│
│  [Recent] [A-Z] [Size]     │
├─────────────────────────────┤
│                             │
│  ┌────┐ ┌────┐ ┌────┐      │
│  │    │ │    │ │    │      │
│  │ 📄 │ │ 📄 │ │ 📄 │      │
│  │    │ │    │ │    │      │
│  │Title│ │Title│ │Title│      │
│  │stats│ │stats│ │stats│      │
│  │prog.│ │prog.│ │prog.│      │
│  └────┘ └────┘ └────┘      │
│                             │
│  ┌────┐ ┌────┐ ┌────┐      │
│  │    │ │    │ │    │      │
│  │ 📄 │ │ 📄 │ │ 📄 │      │
│  └────┘ └────┘ └────┘      │
│                             │
│         + Import PDF        │
│                             │
└─────────────────────────────┘
```

- Grid view (default) and list view toggle
- Filter row: status (All, Reading, Completed, Not Started), sort (Recent, A-Z, Size, Progress)
- Grid cards: document thumbnail placeholder, title (2 lines max), page count + word count, reading progress mini-bar, complexity badge (Simple/Moderate/Complex)
- List rows: PDF icon, title, stats row, progress bar, last read date
- Long-press for context menu: Resume Reading, View Details, Delete
- Empty state: "Your library is empty. Import your first PDF."
- FAB or bottom CTA: "Import PDF"

**Deliver:** Grid view and list view mockups, document context menu, empty state.

---

### 3.8 Reading Goals Screen (NEW — Does Not Exist Yet)

**Purpose:** Set and track personal reading goals.

```
┌─────────────────────────────┐
│  ← Reading Goals       + ⋮  │
├─────────────────────────────┤
│                             │
│  ┌─ Active Goals ──────────┐│
│  │                         ││
│  │  📚 Daily Reading       ││
│  │  Read for 30 minutes    ││
│  │  ████████░░ 23/30 min   ││
│  │  77% complete           ││
│  │                         ││
│  │  ⚡ Speed Goal          ││
│  │  Reach 250 WPM avg      ││
│  │  ██████░░░░ 215/250     ││
│  │  86% complete           ││
│  │                         ││
│  │  🔥 Streak Goal         ││
│  │  Read 30 days in a row  ││
│  │  ████░░░░░░ 12/30 days  ││
│  │  40% complete           ││
│  │                         ││
│  └─────────────────────────┘│
│                             │
│  ┌─ Completed Goals ───────┐│
│  │  ✅ Read 5 documents    ││
│  │  ✅ Reach 200 WPM       ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

- Goal types: Daily Time, Weekly Words, Speed Target, Streak Length, Documents Read
- Each goal card: emoji icon, goal name, description, progress bar with current/target values, percentage
- Add Goal sheet: select type, set target value, set deadline (optional)
- Completed goals section below with checkmark and completion date
- Celebratory animation when a goal is achieved

**Deliver:** Goals list, add goal bottom sheet, goal achievement celebration overlay.

---

## 4. Navigation Architecture

### Current: Named routes, no bottom nav
The app currently uses `Navigator.pushNamed` with 3 routes: `/home`, `/settings`, `/analytics`.

### Proposed: Bottom Navigation Bar

With the addition of Library, Vocabulary, and Goals screens, the app needs structured navigation.

```
┌─────────────────────────────────────┐
│  [Home] [Library] [Vocab] [Analytics]│
│   📖      📚       📝      📊       │
└─────────────────────────────────────┘
```

- 4 bottom nav destinations
- Settings accessed via gear icon in each screen's app bar (or as a 5th tab if needed)
- Goals accessed from within Analytics
- Active tab: filled icon + label in primary color
- Inactive tab: outlined icon, muted color, no label (or small label)
- Badge on Vocabulary tab: count of new uncollected words
- No bottom nav bar visible during active reading (full immersion mode)

**Deliver:** Bottom nav bar design in both active and inactive states, with badge, light and dark mode.

---

## 5. Interaction Patterns

### Gestures During Reading
| Gesture | Action |
|---------|--------|
| **Single tap** on reading area | Show/hide controls dock |
| **Double tap** | Pause/resume reading |
| **Long press** on a word | Collect word to vocabulary |
| **Swipe left** | Skip forward 10% |
| **Swipe right** | Skip backward 10% |
| **Pinch** | Adjust font size live |
| **Two-finger vertical swipe** | Adjust reading speed live |

### Haptic Feedback
- Light haptic on play/pause toggle
- Medium haptic on reaching end of document
- Selection haptic on word collection

### Dialogs & Sheets Pattern
- Confirmation dialogs (reset, delete, clear cache): AlertDialog with destructive action in error color
- Settings adjustment dialogs (spacing, font size, focus): AlertDialog with slider + preview
- Import: DraggableScrollableSheet (bottom sheet)
- Word collection toast: SnackBar with undo action, positioned above controls dock

---

## 6. Empty States & Edge Cases

Every screen needs an empty state design. These are often the first thing a new user sees.

| Screen | Empty State Message | Illustration Direction |
|--------|-------------------|----------------------|
| Home (no PDF) | "No PDF loaded" / "Import a PDF to start reading" | Open book with flowing lines |
| Library (no documents) | "Your library is empty" / "Import your first PDF" | Empty bookshelf |
| Vocabulary (no words) | "No words collected yet" / "Long-press words while reading to collect them" | Notebook with pen |
| Analytics (no data) | "No reading data yet" / "Start reading to see your statistics" | Chart outline with sparkle |
| Streak (no streak) | "Start your reading streak" / "Read every day to build your streak" | Dimmed flame |
| Goals (no goals) | "No goals set" / "Set a reading goal to track your progress" | Target/bullseye |
| Sessions (no sessions) | "No sessions yet" / "Start reading to see your history" | Clock outline |

**Empty states should be warm and encouraging, never clinical. Each should have a clear CTA button.**

**Deliver:** Empty state illustrations or icon compositions for each screen.

---

## 7. Dark Mode Specifications

Dark mode is not an inversion — it's a separate design that needs equal attention.

### Key Principles
- **Surface hierarchy with elevation:** Background < Surface < Surface+1 < Surface+2 (progressively lighter grays)
- **Reading surface:** Slightly warm dark (#1A1A1E or #1E1E22) — NOT pure black
- **Text color:** Off-white (#E6E1E5) for body, brighter for headlines — NOT pure white
- **Reduced contrast for comfort:** Long reading sessions require lower contrast than typical dark UIs
- **Accent colors:** Slightly desaturated from light mode versions to avoid eye strain
- **Cards and sheets:** Surface+1 color with outline borders (not shadow, which doesn't read well on dark)

### Reading-Specific Dark Mode
- The reading area should feel like a Kindle in dark mode — warm, easy on eyes
- Consider offering a "Sepia Dark" option: very dark brown background with warm off-white text
- Focus window highlight: use lighter text on focused lines rather than background highlight (which can be too bright in dark mode)

**Deliver:** Complete dark mode spec for every screen, not just a CSS inversion.

---

## 8. Accessibility Requirements

| Requirement | Specification |
|-------------|---------------|
| **Minimum touch target** | 48x48dp for all interactive elements |
| **Color contrast** | WCAG AA (4.5:1 for body text, 3:1 for large text) |
| **Font scaling** | UI must remain functional at 200% system font size |
| **Screen reader** | All icons need contentDescription, all images need alt text |
| **Reduced motion** | Provide static alternatives when system reduces motion is on |
| **Color independence** | Never use color alone to convey information — pair with icons or text |
| **Focus indicators** | Visible keyboard/switch focus rings on all interactive elements |
| **Reading level labels** | Color-coded levels (green/blue/orange/red) must also have text labels |

---

## 9. Deliverables Checklist

### Required Deliverables

| # | Deliverable | Format | Priority |
|---|------------|--------|----------|
| 1 | **Design System** — Colors, typography, icons, spacing, motion tokens | Figma library | P0 |
| 2 | **App Icon & Logo** — Logomark, app icon (both platforms), splash screen | SVG + PNG exports | P0 |
| 3 | **Onboarding Flow** — 3 screens, light + dark | Figma frames | P0 |
| 4 | **Home Screen** — All 4 states (empty, loading, reading, error) + controls visible/hidden | Figma frames | P0 |
| 5 | **Focus Window Exploration** — 4 approaches for the reading highlight effect | Figma frames | P0 |
| 6 | **PDF Import Bottom Sheet** — Expanded + collapsed, with/without recent docs | Figma frames | P0 |
| 7 | **Settings Screen** — Full scrollable screen + all dialogs | Figma frames | P1 |
| 8 | **Analytics Screen** — All 5 sections populated + empty states | Figma frames | P1 |
| 9 | **Vocabulary Screen** — List, detail, flashcard mode, word collection toast | Figma frames | P1 |
| 10 | **Document Library** — Grid + list views, context menu, empty state | Figma frames | P2 |
| 11 | **Reading Goals** — Goals list, add goal sheet, achievement animation | Figma frames | P2 |
| 12 | **Bottom Navigation Bar** — Active/inactive states, badges | Figma component | P1 |
| 13 | **Empty State Illustrations** — 7 illustrations/compositions | SVG | P1 |
| 14 | **Dark Mode** — Complete dark mode for all screens | Figma frames | P0 |
| 15 | **Interactive Prototype** — Key flows: onboarding → import → reading → analytics | Figma prototype | P1 |

### File Organization
```
Read-It Design/
├── 00-Design-System/
│   ├── Colors
│   ├── Typography
│   ├── Icons
│   ├── Components
│   └── Motion
├── 01-Onboarding/
├── 02-Home/
├── 03-Import/
├── 04-Reading-Active/
├── 05-Settings/
├── 06-Analytics/
├── 07-Vocabulary/
├── 08-Library/
├── 09-Goals/
├── 10-Dark-Mode/
├── 11-Empty-States/
├── 12-App-Icon/
└── Prototype/
```

---

## 10. Design Inspiration & References

### Apps to Study (UX, not to copy)
- **Kindle** — Reading surface quality, font/spacing controls, dark mode
- **Libby** — Library management, reading progress, clean UI
- **Duolingo** — Streak system, achievement celebrations, encouraging tone
- **Forest** — Focus timer, minimal UI during active session, satisfying completion
- **Apple Books** — Reading settings panel, typography, page turn feel
- **Headspace** — Onboarding flow, calm brand personality, warm illustrations
- **Strava** — Activity tracking, personal records, social motivation

### Visual Mood
- Clean, not sterile
- Warm, not clinical
- Smart, not academic
- Encouraging, not demanding
- Modern Material 3, not dated Material 2

---

## 11. Technical Constraints

| Constraint | Detail |
|------------|--------|
| **Framework** | Flutter (iOS + Android from single codebase) |
| **Design system** | Material Design 3 — use MD3 components and patterns |
| **Font bundling** | All fonts must be bundled in the app (no Google Fonts API runtime loading) |
| **Chart rendering** | Charts will be rendered with fl_chart or similar Flutter package — keep chart designs achievable with line/bar chart primitives |
| **Illustrations** | Must be vector (SVG) for scalability. Can be simple compositions — don't need full illustrations |
| **Animation** | Flutter supports Lottie animations if needed for celebration/onboarding |
| **Screen sizes** | Design for 375px width (iPhone SE) as minimum, 428px (iPhone 14 Pro Max) as comfortable. Test at 320px for edge cases |
| **Orientation** | Portrait only for v1 |
| **Platform** | Follow Material 3 patterns. No Cupertino/iOS-specific components — Material works well on both platforms |

---

## 12. Success Criteria

The design is successful if:

1. **A new user can import a PDF and start reading in under 30 seconds** — the flow from launch to first reading is frictionless
2. **The reading experience is the best-in-class** — focus window, scrolling smoothness, and reading surface quality rival Kindle
3. **Users feel motivated to return daily** — streaks, progress charts, and insights create a positive feedback loop
4. **Settings don't feel overwhelming** — presets handle 80% of users, fine-grained controls are accessible but not prominent
5. **The app feels premium** — typography, spacing, color, and motion all feel intentional and cohesive
6. **Dark mode is a first-class citizen** — not an afterthought, but designed for long night reading sessions
