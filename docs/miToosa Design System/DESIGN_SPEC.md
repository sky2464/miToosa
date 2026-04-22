---
name: Kinetic Obsidian
colors:
  surface: '#10131a'
  surface-dim: '#10131a'
  surface-bright: '#363940'
  surface-container-lowest: '#0b0e14'
  surface-container-low: '#191c22'
  surface-container: '#1d2026'
  surface-container-high: '#272a31'
  surface-container-highest: '#32353c'
  on-surface: '#e1e2eb'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e1e2eb'
  inverse-on-surface: '#2e3037'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#d1bcff'
  on-secondary: '#3c0090'
  secondary-container: '#7000ff'
  on-secondary-container: '#ddcdff'
  tertiary: '#fff3f4'
  on-tertiary: '#66002c'
  tertiary-container: '#ffccd6'
  on-tertiary-container: '#bb0058'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d1bcff'
  on-secondary-fixed: '#23005b'
  on-secondary-fixed-variant: '#5700c9'
  tertiary-fixed: '#ffd9e0'
  tertiary-fixed-dim: '#ffb1c3'
  on-tertiary-fixed: '#3f0019'
  on-tertiary-fixed-variant: '#8f0041'
  background: '#10131a'
  on-background: '#e1e2eb'
  surface-variant: '#32353c'
typography:
  display-lg:
    fontFamily: Orbitron
    fontSize: 48px
    fontWeight: '600'
    lineHeight: '1.1'
    letterSpacing: 0.05em
  headline-lg:
    fontFamily: Orbitron
    fontSize: 32px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.04em
  headline-md:
    fontFamily: Orbitron
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
    letterSpacing: 0.03em
  body-lg:
    fontFamily: Exo 2
    fontSize: 18px
    fontWeight: '300'
    lineHeight: '1.6'
    letterSpacing: 0.02em
  body-md:
    fontFamily: Exo 2
    fontSize: 16px
    fontWeight: '300'
    lineHeight: '1.5'
    letterSpacing: 0.02em
  label-lg:
    fontFamily: Exo 2
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.06em
  label-sm:
    fontFamily: Exo 2
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.2'
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin: 32px
---

## Brand & Style

The design system embodies a high-performance, futuristic aesthetic tailored for advanced technical interfaces and speculative environments. It targets a demographic that values precision, innovation, and a "cyber-industrial" feel. The emotional response is one of controlled power and clarity within a vast digital space.

The visual style is a hybrid of **Glassmorphism** and **Minimalism**. It utilizes deep, multi-layered backgrounds with frosted glass overlays to create a sense of infinite depth. High-energy vibrant gradients serve as "energy trails" or focal points against a sleek, dark-mode canvas, ensuring that the interface feels alive and reactive.

## Colors

The palette is optimized for high-contrast legibility in dark environments. 

- **Primary (Electric Cyan):** Used for primary actions, active states, and data highlights.
- **Secondary (Proton Purple):** Used for secondary interactions and depth-defining gradients.
- **Tertiary (Plasma Pink):** Reserved for alerts, critical status updates, or high-intensity accents.
- **Neutral:** A range of deep obsidian tones. The base background is a near-black matte, while surfaces use semi-transparent variations to allow background blurs to bleed through.

Gradients should transition diagonally from Secondary to Primary to simulate motion and kinetic energy.

## Typography

This design system uses a dual-typeface strategy to balance brand character with technical utility. 

**Orbitron** is used for headlines and display elements. Its geometric, wide stance provides a futuristic, mechanical feel. **Exo 2** is the workhorse for all UI components, body text, and data readouts, providing a sci-fi aesthetic without sacrificing readability.

To combat halation (the "glow" effect of light text on dark backgrounds), typography weights are intentionally kept light (300-500) and letter-spacing is increased across all levels to ensure character definition remains sharp. All labels should utilize increased tracking to maintain legibility at small scales.

## Layout & Spacing

The layout follows a **Fluid Grid** model built on an 8px base unit. This ensures vertical rhythm and consistent alignment across varying screen densities. 

Standard layouts utilize a 12-column grid for desktop and a 4-column grid for mobile. Spacing between containers should be generous to maintain the "minimalist" aspect of the brand, preventing the UI from feeling cluttered. Use `lg` and `xl` spacing for section breathing room, and `sm` or `md` for internal component padding.

## Elevation & Depth

Depth is established through **Glassmorphism** rather than traditional drop shadows. 

1.  **Backdrop Blur:** Use a 12px to 20px blur radius on all elevated surfaces.
2.  **Translucency:** Surfaces should use a 40% to 60% opacity fill of the neutral color.
3.  **Inner Glow:** Instead of outer shadows, use a 1px solid or semi-transparent stroke (the "glass edge") on the top and left borders of cards to simulate a light source from the top-left.
4.  **Shadows:** When shadows are necessary for extreme elevation, use "Ambient Shadows"—diffused, low-opacity blurs tinted with the Primary color (#00F0FF) to create a subtle neon underglow.

## Shapes

The shape language is "Soft-Tech." While the typography is sharp and geometric, the UI containers use a **Soft** (0.25rem) corner radius. This creates a more sophisticated, machined appearance compared to fully sharp edges or overly rounded "bubbly" shapes. 

Buttons and input fields should strictly follow the `rounded` (0.25rem) or `rounded-lg` (0.5rem) tokens to maintain a consistent architectural feel throughout the interface.

## Components

- **Buttons:** Primary buttons use a vibrant gradient fill (Secondary to Primary) with Orbitron "Label-lg" text. Secondary buttons are "ghost" style with a 1px Primary color border and backdrop blur.
- **Cards:** Use the glassmorphism stack: 50% opacity neutral fill, 16px backdrop blur, and a 1px white/0.1 opacity border.
- **Inputs:** Dark, recessed backgrounds with a 1px bottom border that glows Primary Cyan upon focus. 
- **Chips/Tags:** Small, pill-shaped elements with a solid Secondary Purple fill at 20% opacity and high-tracking Exo 2 text.
- **Progress Bars:** Thin, high-contrast lines utilizing the vibrant gradient as the "fill" state, often accompanied by a subtle outer glow.
- **Data Visualizations:** Use "Orbitron" for axis labels and "Exo 2" for granular data points. All lines should be 2px width or less to maintain a precise, technical look.