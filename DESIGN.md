---
name: Bóveda
description: A password manager that reads like a well-made business tool. Monochrome, flat, hairline edges, one solid action per screen, and motion that explains what just happened.
colors:
  primary: "#171717"
  onPrimary: "#FFFFFF"
  background: "#FAFAFA"
  surface: "#FAFAFA"
  onSurface: "#171717"
  onSurfaceVariant: "#666666"
  outlineVariant: "#EBEBEB"
  plate: "#FFFFFF"
  plateEdge: "#00000014"
  shell: "#FFFFFF"
  shellField: "#F2F2F2"
  error: "#D6001C"
  secretDigit: "#0B5CAD"
  secretSymbol: "#707070"
  primary-dark: "#EDEDED"
  onPrimary-dark: "#0A0A0A"
  background-dark: "#0A0A0A"
  onSurface-dark: "#EDEDED"
  onSurfaceVariant-dark: "#A1A1A1"
  outlineVariant-dark: "#2E2E2E"
  plate-dark: "#171717"
  plateEdge-dark: "#FFFFFF24"
  shell-dark: "#0A0A0A"
  shellField-dark: "#1A1A1A"
  error-dark: "#FF6166"
  secretDigit-dark: "#7DB6F0"
  secretSymbol-dark: "#8F8F8F"
  keyCapCobalt: "#3B5BA5"
  keyCapGreen: "#2F7D5B"
  keyCapViolet: "#6B55A8"
  keyCapCopper: "#A8583A"
  keyCapBrass: "#B8963F"
  keyCapTeal: "#2A7A80"
  keyCapMagenta: "#A0456F"
  keyCapSlate: "#5A6672"
rounded:
  extraSmall: "4dp"
  small: "6dp"
  medium: "8dp"
  large: "12dp"
  extraLarge: "16dp"
spacing:
  xxs: "4dp"
  xs: "8dp"
  sm: "12dp"
  md: "16dp"
  lg: "20dp"
  xl: "24dp"
  xxl: "32dp"
---

# Design System: Bóveda

## Overview

Bóveda is minimal and corporate: a neutral ground, solid ink for the one action, hairlines instead of shadows, and tight corners. It is a tool people trust with their passwords, so nothing on screen is decorative. The personality lives in the motion, not in the surfaces.

Light and dark are two equal themes of the same system, chosen in Ajustes (Sistema, Claro, Oscuro) and remembered. Every screen follows the choice, the sign-in and lock screens included.

## Colors

- **Neutrals carry the interface.** Ground `#FAFAFA` / `#0A0A0A`, plates `#FFFFFF` / `#171717`, ink `#171717` / `#EDEDED`, secondary text `#666666` / `#A1A1A1`.
- **The primary action is ink:** a solid `#171717` button in light, `#EDEDED` in dark. There is no brand accent.
- **Edges are hairlines:** `plateEdge`, black at 8 % in light and white at 14 % in dark.

### Colour Quarantine

Colour appears only where it means something. Key-cap hues mean "which account", the strength scale means "how strong", red means "wrong or destructive". Nothing else is coloured. Secrets read back in their own inks: digits in blue, symbols in grey, letters in the base ink.

### Key caps

Eight muted, flat hues. A cap's hue comes from a hash of the trimmed, lowercased label modulo eight, so the **order of `anodizedCaps` is data**: reordering it would change every account's colour. Caps keep their hues in both themes and with system colours.

### System colours

Opt-in from Ajustes on Android 12+. The scheme replaces the neutrals; caps, secret inks and the strength scale keep their values.

### Gradients

Never on a control. Only two soft background gradients exist: the light from above on the sign-in and lock screens, and the account's hue washing faintly down from the top of the detail.

## Typography

Atkinson Hyperlegible Next for the UI, Atkinson Hyperlegible Mono for every secret and every number compared character by character (entropy bits, generator length). Rank comes from weight, not from size jumps or colour. Search matches are bold inside the row's own text. A hidden secret is always ten dots, so it never reveals its length.

## Layout

- Single column, phone first. Lists cap at 720dp, reading columns at 600dp, forms at 440dp.
- 4dp rhythm; 16dp is the default horizontal inset. 48dp minimum touch targets.
- Rows are 72dp plates with an 8dp gap.
- The detail's primary action is pinned to the bottom, within thumb reach.
- Phones use the floating dock, wider windows a navigation rail.

## Elevation

Flat. Plates are separated from the ground by tone and a hairline, not by shadow. Only the two things that float cast one, and it is soft: the dock and the FAB. No blur anywhere: a backdrop filter would re-render everything beneath it on every frame of a scroll.

## Components

### Button (`BovedaButton`)

| Type | Light | Dark | Use |
|---|---|---|---|
| primary | `#171717`, pressed `#383838`, white text | `#EDEDED`, pressed `#CCCCCC`, `#0A0A0A` text | The one action of a screen |
| secondary | white, hairline edge | `#171717`, hairline edge | Alternatives (Generar, huella) |
| tertiary | no fill | no fill | Low emphasis (Cerrar sesión, dialog actions) |
| error | `#EA001D` | `#E2162A` | Destructive confirmation |
| warning | `#FF9300` | `#FF9300` | Reserved |

Sizes: small 32dp, medium 40dp, large 48dp. Corners 6dp, or 8dp on large. `loading` shows the 12-bar `BovedaSpinner` and takes the disabled look (`#F2F2F2` / `#1A1A1A`, text `#8F8F8F`, hairline). Colour changes in 150 ms, with no ripple, and the button gives slightly under the finger. Plain Material buttons get the same style from the theme.

### Other components

- **Fields:** filled with the plate colour, hairline edge, 8dp corners; the edge turns to ink on focus.
- **Search:** a 48dp field in the header; shows the match count while searching.
- **Header (`ShellHeader`):** flat, closed by a hairline. On the vault it tightens as the list scrolls.
- **Dock (`NavDock`):** a flat floating bar with a solid indicator that slides between places. It hides for pushed screens by transform alone.
- **Segmented control (`BovedaSegmented`):** the theme choice, with a sliding indicator.
- **Plate:** 12dp corners, hairline, no shadow; related fields share one plate with hairline dividers.
- **Generator:** four character-set tiles, edged in ink while active.

### Signature motion

- **Dial and padlock:** a single thin ring with one short arc around a line-drawn padlock. The ring settles on arrival, turns while working, spins open as the vault opens, and kicks back when the password is rejected. The shackle lifts on unlock, clicks shut on lock, and the padlock swings on a rejected password.
- **Key cap:** one object across screens; it flies from its row to the detail header.
- **Tumbler:** secrets change character by character, each rolling through its own clipped cell.
- **Strength meter:** rises from the left, drains from the right.
- **Copy:** the icon becomes a check, a ring leaves it, and the state holds for 1.6 s.
- **Entrance:** the first screenful rises into place on one shared controller. Filtering is instant, because finding the key is the point.

## Motion and Performance Rules

Motion stays short (feedback 110–250 ms, flights about 400 ms) and never blocks input; the system "Remove animations" setting turns all of it into a cut. These rules keep it cheap, and `packages/presentation/test/performance_test.dart` guards the main ones:

- Animate transforms and opacity, not layout. Nothing relayouts a page during a transition.
- Paint-only animations pass the controller as the painter's `repaint`, inside a `RepaintBoundary`, so a tick neither rebuilds nor repaints around it.
- No `saveLayer` per glyph, no `BackdropFilter`, no fragment-shader ink.
- Build geometry and text layouts once: the key cap shares one path and caches its stamps.
- A scroll tick or a keystroke reaches only the widgets that show it (`ValueNotifier`, `BlocSelector`, `buildWhen`). Unchanged rows keep their widget instance.
- The list stays lazy.
- `BovedaMotion.seat` overshoots past 1: use it on position and scale only, never on opacity or under another curve.

## Do's and Don'ts

### Do

- Keep one primary button per screen, and use `BovedaButton` for it.
- Use hairlines and tone for separation.
- Set every secret and compared number in the mono.
- Test every change in both themes.

### Don't

- Don't put a gradient, glow or shadow on a control.
- Don't add a brand accent, or use colour without a meaning.
- Don't reorder `anodizedCaps`.
- Don't reveal a hidden secret's length.
- Don't make the user wait on an animation.
