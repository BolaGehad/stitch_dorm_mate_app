---
name: Blueprint Harmony
colors:
  surface: '#f6faff'
  surface-dim: '#cfdce7'
  surface-bright: '#f6faff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ebf5ff'
  surface-container: '#e3effb'
  surface-container-high: '#ddeaf5'
  surface-container-highest: '#d8e4f0'
  on-surface: '#111d25'
  on-surface-variant: '#3c4947'
  inverse-surface: '#26323b'
  inverse-on-surface: '#e6f2fe'
  outline: '#6c7a77'
  outline-variant: '#bbcac6'
  surface-tint: '#006a62'
  primary: '#006a62'
  on-primary: '#ffffff'
  primary-container: '#2ec4b6'
  on-primary-container: '#004c46'
  inverse-primary: '#4fdbcc'
  secondary: '#895100'
  on-secondary: '#ffffff'
  secondary-container: '#fd9d1a'
  on-secondary-container: '#663b00'
  tertiary: '#5a5f62'
  on-tertiary: '#ffffff'
  tertiary-container: '#acb1b4'
  on-tertiary-container: '#3e4447'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#70f8e8'
  primary-fixed-dim: '#4fdbcc'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#ffdcbc'
  secondary-fixed-dim: '#ffb86b'
  on-secondary-fixed: '#2c1700'
  on-secondary-fixed-variant: '#683d00'
  tertiary-fixed: '#dee3e6'
  tertiary-fixed-dim: '#c2c7ca'
  on-tertiary-fixed: '#171c1f'
  on-tertiary-fixed-variant: '#42484a'
  background: '#f6faff'
  on-background: '#111d25'
  surface-variant: '#d8e4f0'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 20px
  stack-gap-sm: 12px
  stack-gap-md: 16px
  stack-gap-lg: 24px
  section-margin: 32px
---

## Brand & Style
The design system is centered on the concept of "Structural Serenity." It bridges the gap between the technical precision of shared living logistics and the soft, emotional comfort of a home. The brand personality is helpful, organized, and unobtrusive, designed to de-escalate the potential friction of roommate management.

The aesthetic follows a **Modern iOS Minimalism** approach. It utilizes expansive white space and high-quality typography to ensure clarity. The unique character of the design system is derived from its "Blueprint" background—a subtle nod to the architecture of a shared life. This is achieved through a technical watermark style that remains decorative and low-contrast, ensuring it never competes with functional content.

## Colors
The color palette of this design system is anchored by a primary **Soft Teal**, chosen for its calming properties and association with cleanliness. 

- **Primary (#2EC4B6):** Used for primary actions, active navigation states, and key highlights.
- **Background Layer:** The base is a very soft off-white or light grey to allow the blueprint watermark (gears and sketches) to sit at 3-5% opacity.
- **Secondary/Accent:** A warm orange is used sparingly for urgent notifications or "needs attention" states to provide a clear but friendly contrast to the teal.
- **Neutrals:** Deep slate greys are used for text to maintain high readability without the harshness of pure black.

## Typography
This design system utilizes **Plus Jakarta Sans** across all levels. This typeface was selected for its modern, geometric construction and friendly, open counters, which reinforce the "soft engineering" aesthetic.

Hierarchy is established through weight and scale rather than color. Headlines use a tighter letter-spacing and heavier weights to feel grounded, while body text maintains generous line height to ensure a breezy, "minimal" reading experience even during dense task lists.

## Layout & Spacing
The layout follows a fluid, mobile-first grid with a 20px safe-area margin on the horizontal axis. A consistent 8px rhythm governs all spacing increments.

The design system prioritizes a "Stacked Card" vertical flow. Elements are grouped into logical containers with 16px internal padding. Vertical gaps between distinct content blocks are typically 24px or 32px to maintain the "clean and calm" atmospheric requirement, preventing the screen from feeling cluttered.

## Elevation & Depth
Depth in this design system is created through **Ambient Shadows** and tonal layering. 

- **Level 0 (Base):** The blueprint background with low-opacity technical sketches.
- **Level 1 (Cards):** Soft teal or white surfaces with a very diffused, low-opacity shadow (Color: #2EC4B6 at 8% opacity, Blur: 20px, Y-offset: 4px). This creates a "floating" effect that feels light and airy.
- **Level 2 (Modals/Overlays):** These use a standard iOS-style backdrop blur (glassmorphism) to maintain context of the background while focusing the user's attention.
- **Level 3 (Floating Action):** The "Dormy AI" icon sits at the highest elevation, using a slightly more pronounced shadow to indicate it is globally accessible.

## Shapes
The shape language is consistently "Soft Rounded." Every major container, card, and button utilizes a **16px (1rem)** corner radius. 

This specific radius is large enough to feel friendly and approachable but structured enough to align with the "engineering" motif. Small elements like chips or tags may utilize full pill-shaped rounding to differentiate them from interactive buttons.

## Components
- **Cards:** The primary container. Always 16px radius, white or ultra-light teal background, with an ambient shadow.
- **Buttons:** Primary buttons are solid Soft Teal with white text. Secondary buttons are ghost-style with a 1px teal border or a light teal tonal fill.
- **Inputs:** Fields are defined by soft-grey borders that turn teal on focus. Labels are positioned above the field in the "label-md" typographic style.
- **Dormy AI (Floating Button):** A circular button (56x56px) positioned 24px from the bottom and right edges. It features the 🤖 icon and a subtle teal glow or shadow to distinguish it from static content.
- **Lists:** Clean rows separated by thin, low-contrast dividers (5% opacity black). Each row has a minimum height of 56px to ensure "tappability" following iOS Human Interface Guidelines.
- **Progress Indicators:** Soft teal bars for chores or budget tracking, utilizing rounded end-caps to maintain the soft aesthetic.