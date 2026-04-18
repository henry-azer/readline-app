# Design System Strategy: The Modern Bibliophile

## 1. Overview & Creative North Star
The "Modern Bibliophile" is the Creative North Star for this design system. We are not building a utility; we are building a sanctuary for the mind. This system moves away from the rigid, "app-like" feel of standard Material 3 and instead leans into high-end editorial design. 

To break the template look, we employ **intentional asymmetry**. For example, headlines are never just centered; they are anchored with generous white space to create a "breathing" layout. We prioritize the reading experience through sophisticated, layered surfaces and authoritative typography that feels like a premium physical journal.

---

## 2. Colors & Tonal Architecture
The palette is rooted in a deep, intellectual Teal and grounded by a warm, paper-like surface. 

### The "No-Line" Rule
Explicitly prohibited: 1px solid borders for sectioning or containment. Boundaries must be defined solely through background color shifts. 
- A card should not have a stroke; it should be a `surface-container-lowest` block sitting on a `surface-container-low` background. 
- This forces the eye to recognize hierarchy through mass and tone rather than artificial outlines.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine vellum. 
- **Base:** `surface` (#fcf9f5) for the main background.
- **Structural Sections:** `surface-container-low` (#f6f3ef) to define large content areas.
- **Interactive Elements:** `surface-container-lowest` (#ffffff) to make cards "pop" with a clean, crisp lift.
- **Nesting:** Never place two elements of the same surface tier inside one another. Always shift the tier (High to Lowest) to create logical containment.

### The "Glass & Gradient" Rule
To add "soul" to the digital surface, use Glassmorphism for floating navigation bars or modal overlays. 
- **Recipe:** Use `surface` at 80% opacity with a `24px` backdrop-blur.
- **Signature Textures:** For primary CTA buttons or "Streak" milestones, use a subtle linear gradient from `primary` (#00464a) to `primary-container` (#006064) at a 135-degree angle. This prevents the "flat-and-cheap" look.

---

### 3. Typography: Editorial Authority
Typography is the voice of this design system. We use a high-contrast scale to create an "Editorial" rhythm.

| Role | Token | Font | Size | Weight | Character |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Reading** | Body-LG | Newsreader | 1.0rem | 400 | Optimized for long-form immersion. |
| **Headline**| Headline-LG | Newsreader | 2.0rem | 600 | Dramatic, authoritative, tight tracking. |
| **UI Nav**   | Label-MD | Inter | 0.75rem | 500 | Clean, utilitarian, all-caps for labels. |

**The Hierarchy Logic:**
- **Serif (Newsreader):** Used for all narrative and high-level headings. It signals "knowledge" and "depth."
- **Sans-Serif (Inter):** Used strictly for functional UI (buttons, labels, metadata). It signals "tooling" and "efficiency."

---

## 4. Elevation & Depth
We eschew traditional "Drop Shadows" in favor of **Tonal Layering**.

### The Layering Principle
Depth is achieved by stacking `surface-container` tiers. 
- **Level 0:** `surface` (The foundation).
- **Level 1:** `surface-container-low` (Secondary content zones).
- **Level 2:** `surface-container-highest` (Primary interactive cards).

### Ambient Shadows
When a floating effect is mandatory (e.g., a "Continue Reading" FAB), use an **Ambient Shadow**:
- **Color:** Tint the shadow with `on-surface` (#1c1c1a) at 6% opacity.
- **Blur:** Large and soft (16px to 32px blur).
- **Spread:** -4px to keep it tight and sophisticated.

### The "Ghost Border" Fallback
If a border is required for accessibility in a high-density list, use a **Ghost Border**: 
- Token: `outline-variant` at 15% opacity. It should be felt, not seen.

---

## 5. Components

### Reading Surface (The Core Component)
- **Background:** `surface` (#fcf9f5).
- **Typography:** `body-lg` Newsreader.
- **Spacing:** 1.6x line-height to prevent eye fatigue.
- **Interaction:** Long-press on words triggers a `tertiary-container` highlight with a `0.5rem` (sm) corner radius.

### Buttons
- **Primary:** Gradient fill (`primary` to `primary-container`), White text. `xl` (1.5rem) corner radius. No shadow.
- **Secondary:** `surface-container-high` fill with `primary` text.
- **Tertiary:** Text-only, `label-md` Inter, all-caps with `1px` letter spacing.

### Cards & Lists
- **Rule:** Forbid the use of divider lines. 
- Use vertical white space (32px) to separate items or a subtle background shift to `surface-container-lowest`. 
- **Corners:** Strictly `xl` (1.5rem / 16px) for all content cards to maintain the "inviting" personality.

### The "Streak" Counter (Custom Component)
- **Visuals:** Use `tertiary-fixed-dim` (#ffba38) for the icon and a `tertiary-container` (#744f00) background. 
- **Effect:** Add a soft outer glow using a 10% opacity `tertiary` shadow to make the achievement feel "warm."

---

## 6. Do’s and Don’ts

### Do
- **Do** use asymmetric margins (e.g., 24px left, 40px right) in editorial headers to create a custom, "magazine" feel.
- **Do** use `secondary` (Coral) sparingly—only for highlights or "new" badges to guide the eye.
- **Do** prioritize vertical rhythm. Use the 8px grid religiously to ensure whitespace is consistent.

### Don't
- **Don’t** use 100% black (#000000). Use `on-surface` (#1c1c1a) for text to maintain the "warm" intellectual tone.
- **Don’t** use standard Material 3 "Outlined" buttons. They feel too industrial; use "Tonal" or "Filled" instead.
- **Don’t** use "Drop Shadows" on cards. Use tonal background changes to denote elevation.