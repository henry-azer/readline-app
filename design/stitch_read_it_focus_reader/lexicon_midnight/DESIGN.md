# Design System: The Midnight Library (Dark Theme)

## 1. Overview & Creative North Star
### "The Nocturnal Archivist"
This design system is not a mere "inverted" UI. It is an editorial experience inspired by the quiet, atmospheric depth of a private library at midnight. The creative North Star—**The Nocturnal Archivist**—moves away from the sterile, high-contrast aesthetics of standard dark modes. Instead, it embraces the textures of ink on heavy paper, the softness of low-light environments, and the intellectual weight of a curated archive.

The layout rejects "template" rigidity in favor of **Intentional Asymmetry**. By utilizing overlapping elements, varying column widths, and generous whitespace (or "darkspace"), we create a digital environment that feels bespoke and authoritative.

---

## 2. Colors & Surface Philosophy
The palette is grounded in desaturated, light-absorbing tones that prioritize long-term legibility and ocular comfort.

### The Color Tokens
- **Reading Surface:** `background` (#0e0e12) and `surface_container` (#19191f). A deep, matte foundation that feels infinite.
- **Primary (The Ink):** `primary` (#afcbd8). A desaturated teal/indigo that acts as our primary brand voice—calm, professional, and receding rather than shouting.
- **Tertiary (The Candlelight):** `tertiary` (#ffc6a0). A soft amber used sparingly for highlights, alerts, or interactive moments that require warmth without aggressive contrast.
- **Text (The Script):** `on_surface` (#e6e4ef) for body text to prevent "halation" (the glowing effect of white text on black). Pure white is reserved strictly for `display` and `headline` scales.

### The "No-Line" Rule
Standard UI relies on 1px borders to separate content. **In this system, 1px solid borders are prohibited for sectioning.** 
Boundaries must be defined through:
1.  **Background Color Shifts:** Placing a `surface_container_high` card on a `surface` background.
2.  **Tonal Transitions:** Using subtle shifts in the surface-container tiers to imply a beginning and an end.
3.  **Negative Space:** Using the Spacing Scale to create "gutters" of darkness that act as invisible dividers.

### Glass & Gradient Rule
To add "soul" to the interface, use **Glassmorphism** for floating elements (e.g., navigation bars, floating action buttons). 
- **Effect:** Apply `surface_container` with a 70% opacity and a `backdrop-filter: blur(12px)`.
- **Signature Gradients:** For primary CTAs, use a subtle linear gradient from `primary` to `primary_container`. This adds a tactile, three-dimensional quality that flat hex codes lack.

---

## 3. Typography: Editorial Authority
We utilize a pairing of **Newsreader** (Serif) for narrative weight and **Manrope** (Sans-Serif) for functional utility.

- **Display & Headline (Newsreader):** These are our "Hero" elements. Use `display-lg` (3.5rem) with tight tracking to create a high-fashion, editorial impact.
- **Body (Newsreader):** For long-form reading, `body-lg` (1rem) is the standard. 
  - *Dark Mode Optimization:* Increase `letter-spacing` by **0.03em** and `line-height` to **1.6** to ensure characters don't "bleed" into each other on dark backgrounds.
- **Labels (Manrope):** `label-md` (0.75rem) provides a technical contrast to the serif body, used for metadata, micro-copy, and button labels.

---

## 4. Elevation & Depth
Depth in this system is achieved through **Tonal Layering**, mimicking physical sheets of dark paper stacked upon one another.

### The Layering Principle
Hierarchy is defined by "Value" (Lightness), not shadows:
- **Level 0 (Floor):** `background` (#0e0e12)
- **Level 1 (Sections):** `surface_container_low` (#131318)
- **Level 2 (Cards):** `surface_container` (#19191f)
- **Level 3 (Pop-overs/Modals):** `surface_container_highest` (#25252d)

### Ambient Shadows
If a floating effect is required (e.g., a modal), do not use a standard black shadow. Use an **Ambient Shadow**:
- **Color:** A tinted version of `background` (e.g., #000000 at 40% opacity).
- **Properties:** Large blur (30px–60px), 0px spread. The shadow should feel like a soft glow of darkness, not a hard drop-shadow.

### The Ghost Border Fallback
If an element lacks sufficient contrast against a neighboring surface, use a **Ghost Border**:
- **Token:** `outline_variant` at **15% opacity**. This provides a whisper of a boundary that only becomes visible upon close inspection.

---

## 5. Components

### Buttons
- **Primary:** `primary` background with `on_primary` text. Use `md` (0.375rem) roundedness. 
- **Secondary:** Transparent background with a `Ghost Border` and `primary` text.
- **Interaction:** On hover, the background should shift to `primary_dim` with a subtle `primary` outer glow (4px blur).

### Input Fields
- **Styling:** Use the `surface_container_highest` for the input track. 
- **Indicator:** Replace the traditional 4-sided box with a **"Focus Bar"**: a 2px tall line of `primary` that appears only at the bottom of the field upon focus.
- **Typography:** Labels use `label-md` in `on_surface_variant`.

### Cards & Lists
- **Rule:** Absolute prohibition of divider lines between list items.
- **Implementation:** Separate list items with 16px of vertical space. For cards, use the `surface_container_low` to `surface_container` transition to define the card edge.
- **Asymmetry:** Occasionally "break the grid" by having images or pull-quotes extend 24px past the card's horizontal container.

### The "Marginalia" (System-Specific Component)
- **Purpose:** For side-notes, citations, or secondary information.
- **Style:** `body-sm` (Newsreader), italicized, in `on_tertiary_fixed_variant` color. Positioned in the "margins" of the layout to reinforce the library/archival theme.

---

## 6. Do’s and Don’ts

### Do
- **Do** use `tertiary` (Amber) for success states or highlights—it feels more sophisticated than standard "forest green."
- **Do** lean into asymmetry. If you have a three-column layout, try making one column significantly wider than the others.
- **Do** prioritize "Darkspace." Give elements room to breathe; the darkness is part of the brand.

### Don’t
- **Don’t** use pure #000000 for backgrounds unless it is the `surface_container_lowest` for a deep inset effect.
- **Don’t** use high-contrast white text for long paragraphs. It causes eye fatigue. Stick to `on_surface` (#e6e4ef).
- **Don’t** use default Material "elevated" shadows. Always use Tonal Layering first.
- **Don’t** use hard-edged corners. Stick to the `md` (0.375rem) or `lg` (0.5rem) roundedness scale to maintain a soft, premium feel.