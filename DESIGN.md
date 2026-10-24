---
name: Bóveda
description: A locksmith's key board for one person's passwords. Brushed steel, a graphite shell, brass for the one action, anodized caps for identity.
colors:
  primary: "#876214"
  onPrimary: "#FFFFFF"
  primaryContainer: "#E9C46A"
  onPrimaryContainer: "#251A00"
  secondary: "#4E5D69"
  secondaryContainer: "#D2DEE8"
  tertiary: "#2F5BD3"
  error: "#B3261E"
  errorContainer: "#F9DEDC"
  background: "#F1F3F5"
  surface: "#F1F3F5"
  onSurface: "#191C1F"
  surfaceVariant: "#DCE1E6"
  onSurfaceVariant: "#434A51"
  outline: "#737A82"
  outlineVariant: "#C2C8CE"
  surfaceContainerLowest: "#FFFFFF"
  surfaceContainerLow: "#EBEEF1"
  surfaceContainer: "#E5E9EC"
  surfaceContainerHigh: "#DFE3E7"
  surfaceContainerHighest: "#D8DDE2"
  plate: "#FFFFFF"
  shell: "#20262C"
  onShell: "#F1F3F5"
  onShellVariant: "#AAB3BB"
  shellField: "#2E353C"
  shellIndicator: "#E9C46A"
  onShellIndicator: "#251A00"
  secretDigit: "#3B5C80"
  secretSymbol: "#5C646C"
  strengthVeryWeak: "#B3261E"
  strengthWeak: "#C2541B"
  strengthFair: "#9A6B00"
  strengthStrong: "#2E7D4F"
  strengthVeryStrong: "#14694F"
  keyCapCobalt: "#2F5BD3"
  keyCapGreen: "#1F7F54"
  keyCapViolet: "#7046C2"
  keyCapCopper: "#B4532A"
  keyCapBrass: "#C99A2E"
  keyCapTeal: "#0F7C86"
  keyCapMagenta: "#AE3678"
  keyCapSlate: "#4B5967"
  keyCapStamp: "#FFFFFF"
  keyCapStampOnBrass: "#221800"
  primary-dark: "#E9C46A"
  onPrimary-dark: "#3D2E00"
  primaryContainer-dark: "#CFA444"
  onPrimaryContainer-dark: "#221800"
  background-dark: "#101316"
  onSurface-dark: "#E1E5E9"
  onSurfaceVariant-dark: "#BEC6CD"
  outlineVariant-dark: "#3F474E"
  surfaceContainerHighest-dark: "#303539"
  plate-dark: "#1B1F23"
  shell-dark: "#1B2025"
  onShell-dark: "#E1E5E9"
  onShellVariant-dark: "#9AA3AB"
  shellField-dark: "#283037"
  secretDigit-dark: "#9EBBDB"
  secretSymbol-dark: "#9AA3AB"
  strengthVeryWeak-dark: "#F2B8B5"
  strengthWeak-dark: "#FFB68E"
  strengthFair-dark: "#F0C04C"
  strengthStrong-dark: "#7FD8A0"
  strengthVeryStrong-dark: "#5FD6B0"
typography:
  display:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "34sp"
    fontWeight: 600
    lineHeight: "42sp"
    letterSpacing: "0sp"
  headline:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "23sp"
    fontWeight: 600
    lineHeight: "30sp"
    letterSpacing: "0sp"
  title-large:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "20sp"
    fontWeight: 600
    lineHeight: "28sp"
    letterSpacing: "0sp"
  title:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "16sp"
    fontWeight: 600
    lineHeight: "24sp"
    letterSpacing: "0.1sp"
  title-small:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "14sp"
    fontWeight: 600
    lineHeight: "20sp"
    letterSpacing: "0.1sp"
  body:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: "24sp"
    letterSpacing: "0.15sp"
  body-medium:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: "20sp"
    letterSpacing: "0.15sp"
  body-small:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "12sp"
    fontWeight: 400
    lineHeight: "16sp"
    letterSpacing: "0.2sp"
  label:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "14sp"
    fontWeight: 600
    lineHeight: "20sp"
    letterSpacing: "0.1sp"
  label-medium:
    fontFamily: "Atkinson Hyperlegible Next, sans-serif"
    fontSize: "12sp"
    fontWeight: 600
    lineHeight: "16sp"
    letterSpacing: "0.3sp"
  secret-large:
    fontFamily: "Atkinson Hyperlegible Mono, monospace"
    fontSize: "24sp"
    fontWeight: 500
    lineHeight: "34sp"
  secret-medium:
    fontFamily: "Atkinson Hyperlegible Mono, monospace"
    fontSize: "17sp"
    fontWeight: 500
    lineHeight: "24sp"
  secret-small:
    fontFamily: "Atkinson Hyperlegible Mono, monospace"
    fontSize: "13sp"
    fontWeight: 500
    lineHeight: "18sp"
rounded:
  extraSmall: "6dp"
  small: "10dp"
  medium: "14dp"
  large: "20dp"
  extraLarge: "28dp"
  full: "9999dp"
spacing:
  xxs: "4dp"
  xs: "8dp"
  sm: "12dp"
  md: "16dp"
  lg: "20dp"
  xl: "24dp"
  xxl: "32dp"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.title}"
    rounded: "{rounded.full}"
    height: "56dp"
  button-action:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    height: "52dp"
  button-outlined:
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    height: "52dp"
  fab-extended:
    backgroundColor: "{colors.primaryContainer}"
    textColor: "{colors.onPrimaryContainer}"
    typography: "{typography.label}"
    rounded: "{rounded.large}"
    height: "56dp"
  top-bar-shell:
    backgroundColor: "{colors.shell}"
    textColor: "{colors.onShell}"
    typography: "{typography.title-large}"
  top-bar-surface:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.onSurface}"
  search-field-shell:
    backgroundColor: "{colors.shellField}"
    textColor: "{colors.onShell}"
    typography: "{typography.body}"
    rounded: "{rounded.extraLarge}"
    height: "56dp"
    padding: "0 16dp 12dp 16dp"
  navigation-shell:
    backgroundColor: "{colors.shell}"
    textColor: "{colors.onShellVariant}"
    typography: "{typography.label-medium}"
  navigation-shell-selected:
    backgroundColor: "{colors.shellIndicator}"
    textColor: "{colors.onShellIndicator}"
  entry-row:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.onSurface}"
    typography: "{typography.body}"
    height: "72dp"
    padding: "0 16dp"
  key-cap:
    backgroundColor: "{colors.keyCapCobalt}"
    textColor: "{colors.keyCapStamp}"
    size: "40dp"
  key-cap-detail:
    size: "60dp"
  app-emblem:
    backgroundColor: "{colors.shell}"
    textColor: "{colors.shellIndicator}"
    size: "76dp"
  plate:
    backgroundColor: "{colors.plate}"
    rounded: "{rounded.large}"
    padding: "12dp 4dp 8dp 16dp"
  plate-field-label:
    textColor: "{colors.onSurfaceVariant}"
    typography: "{typography.label-medium}"
  secret-text:
    textColor: "{colors.onSurface}"
    typography: "{typography.secret-medium}"
  strength-segment:
    backgroundColor: "{colors.strengthVeryStrong}"
    rounded: "3dp"
    height: "6dp"
  strength-segment-empty:
    backgroundColor: "{colors.surfaceContainerHighest}"
    rounded: "3dp"
    height: "6dp"
  section-label:
    textColor: "{colors.onSurfaceVariant}"
    typography: "{typography.label}"
    padding: "24dp 16dp 8dp 16dp"
  text-field:
    textColor: "{colors.onSurface}"
    typography: "{typography.body}"
    rounded: "{rounded.extraSmall}"
---

# Design System: Bóveda

## Overview

**Creative North Star: "The Locksmith's Key Board"**

Bóveda is a board of hanging keys. Every account is a key with an anodized aluminium cap and a stamped initial; the board is brushed steel, the frame around the top-level places is a graphite shell panel, and brass marks the one thing to press. Secrets are stamped in a mono drawn to keep 0 from O and l from 1, and they read back character by character in their own inks. The category default it rejects is the navy-and-neon shield app with a grey list and one blue accent.

Density is list density: 72dp rows separated by hairlines inset past the key cap, one column capped to a readable width on large windows, and a thumb-reach primary action at the bottom of the detail screen. Rank comes from weight in a tight type scale, not from size jumps or colour. Depth is tonal (raised white plates on a cool grey ground) rather than shadowed.

Motion is mechanical and short: things move the way their physical counterparts would (a key lifts off its hook, a padlock shackle lifts and clicks shut, pins roll in a tumbler, a rejected key swings on its ring). Nothing waits on an animation, and the system "Remove animations" setting turns every one into a cut.

**Key Characteristics:**
- Cool brushed-steel ground (#F1F3F5 light, #101316 dark), never cream.
- Graphite shell panel only on top-level places: top bar, docked search, navigation bar or rail.
- Brass for the one primary action and the selected navigation item.
- Eight anodized key-cap hues used only for account identity, derived from the label.
- Atkinson Hyperlegible Next for all UI, Atkinson Hyperlegible Mono for every secret and measurement.
- Tonal depth; plates are lighter than the ground in both themes.
- Mechanical motion, all within about 400 ms, never blocking input.

## Colors

A cool steel-and-graphite neutral world with one warm metal (brass) for action and a quarantined set of anodized hues for identity.

### Primary
- **Action Brass** (primary, #876214 light / #E9C46A dark): the one primary action per screen, such as the full-width "Copiar contraseña" on the detail, "Copiar" in the generator, text buttons and focus. Brass stays brass at night; it never goes muddy.
- **Polished Brass** (primaryContainer, #E9C46A light / #CFA444 dark): the extended FAB "Nueva" and the shell selection indicator (shellIndicator), with onShellIndicator (#251A00) on top.

### Secondary
- **Blued Slate** (secondary, #4E5D69; container #D2DEE8): Material secondary roles only. It is the dynamic-colour source for the shell indicator. Bóveda's own screens do not use it as an accent.

### Tertiary
- **Cobalt** (tertiary, #2F5BD3): carried in the scheme with the same value as the cobalt cap. Not used as a UI accent.

### Neutral
- **Brushed Steel** (background/surface, #F1F3F5 light / #101316 dark): the ground of every screen, list rows included.
- **Steel Plate** (plate, #FFFFFF light / #1B1F23 dark): raised plates that hold a secret, such as the detail's field plate and the generator's password plate. Always lighter than the ground.
- **Graphite Shell** (shell, #20262C light / #1B2025 dark): the top-level frame (top bar, search panel, navigation bar and rail, status band). Text on it is onShell (#F1F3F5) and onShellVariant (#AAB3BB). The docked search field sits in shellField (#2E353C).
- **Ink** (onSurface, #191C1F) and **Muted Ink** (onSurfaceVariant, #434A51): text and secondary text, plate field labels, section labels, timestamps.
- **Hairline** (outlineVariant, #C2C8CE): row and plate dividers. List dividers are inset 72dp so they start past the key cap.
- **Surface containers** (#FFFFFF → #D8DDE2): Material's tonal ladder. surfaceContainerHighest is the empty strength segment and the placeholder-row tone.

### Identity: anodized key caps
cobalt (#2F5BD3), green (#1F7F54), violet (#7046C2), copper (#B4532A), brass (#C99A2E, stamped in #221800), teal (#0F7C86), magenta (#AE3678), slate (#4B5967). The other seven caps carry white stamps. Caps keep these hues in light, dark and dynamic colour.

### Secret inks
- **Blued Steel** (secretDigit, #3B5C80 light / #9EBBDB dark): digits in a revealed secret.
- **Light Graphite** (secretSymbol, #5C646C light / #9AA3AB dark): symbols in a revealed secret. Letters keep the base ink.

### State
- **Strength scale** (strengthVeryWeak → strengthVeryStrong): red, burnt orange, ochre, green, deep green, with lightened dark-theme values. Used only for the strength meter and its verdict.
- **Error** (#B3261E): form errors and the destructive "Eliminar".

### Named Rules
**The Colour Quarantine Rule.** Each family of colour has one job. Key-cap hues mean "which account", brass means "press this", strength colours mean "how strong", error means "wrong". No cap hue appears on a control, and no action uses a cap hue. Secrets read back in their own inks (secretDigit, secretSymbol), never a cap hue and never the action brass.

**The Label-Derived Cap Rule.** A cap's hue comes from a hash of the trimmed, lowercased label modulo eight, so an account wears the same cap in the list row, in flight and in the detail header. Collisions among eight hues are expected and accepted. Do not add hues or pick by position to avoid them.

**The Shell Marks Places Rule.** Graphite is reserved for top-level destinations (Bóveda, Generador, Ajustes). Pushed screens (detail, editor) use a plain steel top bar, so the shell itself tells you where you are.

**The Wallpaper Opt-In Rule.** Material You colour is opt-in from Ajustes (Android 12+). When it is on, the shell maps to surfaceContainer and onSurface, shellField to surfaceContainerHighest, the indicator to secondaryContainer, and plates to surfaceContainerLowest (light) or surfaceContainer (dark). Key caps, secret inks and the strength scale keep their own values.

## Typography

**UI Font:** Atkinson Hyperlegible Next (bundled variable font, weights 400/500/600/700)
**Secret/Mono Font:** Atkinson Hyperlegible Mono (bundled variable font)

**Character:** A face drawn so similar letters stay apart, which is exactly what reading and retyping a password needs. The UI face and its mono come from one family, so secrets feel stamped into the same metal rather than pasted in from a terminal.

### Hierarchy
- **Display** (600, 34–48sp): scale is defined but no current screen uses it.
- **Headline** (600, 23sp/30sp): the entry title in the detail header, beside the 60dp cap.
- **Title Large** (600, 20sp/28sp): top-bar titles ("Bóveda", "Ajustes") and the generator sheet title.
- **Title** (600, 16sp/24sp): the detail's copy-button label and empty-state titles. Title Small (600, 14sp) heads generator option groups.
- **Body** (400, 16sp/24sp): row titles, field values and notes. Body Medium (14sp) for secondary lines and form messages, Body Small (12sp) for strength detail and timestamps.
- **Label** (600, 14sp, 0.1sp): buttons, section labels and the strength verdict. Label Medium (600, 12sp, 0.3sp) for field labels inside plates ("Usuario", "Contraseña", "Sitio web"). Sentence case throughout.
- **Secret** (Mono 500; 24sp/34sp large, 17sp/24sp medium, 13sp/18sp small): large in the generator plate, medium for revealed secrets in the detail and password fields and for the length readout, small for measurements such as "131 bits".

### Named Rules
**The Rank by Weight Rule.** The scale is tight (about 1.15 per step). Hierarchy comes from SemiBold against Regular, not from size jumps or colour. Search matches are highlighted in Bold inside the row's own text, never with a colour.

**The Mono Is for Secrets Rule.** Every secret and every number someone compares character by character (passwords shown in clear, entropy bits, generator length) is set in Atkinson Hyperlegible Mono. Prose and labels are never mono. A hidden secret is always ten dots ("••••••••••"), so it never reveals its length.

## Layout

Single column, phone first, and the same structure scales up to tablets.

- **Widths:** the vault list caps at 720dp (ListWidth). Detail and other reading columns cap at 600dp (ReadableWidth). Sign-in, setup and lock forms cap at 440dp (FormWidth) inside a vertically centred, scrollable column with 24dp horizontal and 32dp vertical padding. Empty-state body text caps at 360dp.
- **Rhythm:** a 4dp base with steps of 4, 8, 12, 16, 20, 24 and 32dp. 16dp is the default horizontal inset. Section labels sit 24dp below the previous group and 8dp above their own.
- **List density:** 72dp rows: 40dp cap, 16dp gap, title and username, 48dp copy button. Hairline dividers are inset 72dp. There is 96dp of bottom room under the last row so the FAB never covers a copy button.
- **Thumb reach:** the detail's primary action ("Copiar contraseña") is pinned to the bottom: full width up to 600dp, 56dp tall, 16dp/12dp padding, above the navigation inset.
- **Navigation:** NavigationSuiteScaffold. On compact windows it is a graphite bottom bar that slides away for pushed screens. On expanded windows it is a graphite rail, with a status band under the status bar in the shell colour on top-level places and the surface colour on pushed screens.
- **Expanded windows:** top-level bars are drawn in ShellPanel. The graphite runs edge to edge while the title and search align with the content column (720dp for the list).
- **Known limitation (not a rule):** the detail is single-pane on tablets. The user accepted this for now. A list-detail two-pane layout is a possible future change.
- **Touch targets:** 48dp minimum. Primary action buttons are 52–56dp tall.

## Elevation & Depth

Depth is tonal. The ground is brushed steel, and secrets sit on plates that are lighter than the ground in both themes (white on #F1F3F5, #1B1F23 on #101316). The graphite shell frames the top level by value contrast rather than by shadow. The only cast shadow is Material's default on the extended FAB and on snackbars and dialogs. No custom shadow vocabulary exists.

### Named Rules
**The Raised Plate Rule.** A secret sits on a plate (plate colour, 20dp corners, hairline dividers between fields) that is lighter than the ground. Do not lift it with a shadow, and do not sink it into a darker well.

## Shapes

Softly machined corners from Material's slots: 6dp (extraSmall: text fields), 10dp (small), 14dp (medium: the recovery-warning panel on surfaceContainerHigh), 20dp (large: plates, extended FAB), 28dp (extraLarge: the docked search pill). Buttons are full pills. Strength segments are 6dp bars with 3dp corners and 4dp gaps.

The signature silhouette is the **key cap**. It has a rounded head (corner radius 30% of width) taking 84% of the height, a short blade stub below it, and a ring hole punched through near the top. The key hangs from that ring hole: the shared-element flight and the rejection swing both pivot there. The app emblem is the same cap in graphite with a brass padlock (the Material Symbols lock, redrawn so its shackle can move).

## Components

### Buttons
- **Shape:** full pill.
- **Primary:** Action Brass with white label. On the detail it is 56dp tall, holds a copy icon plus a Title-weight label, and is pinned to the bottom. In the generator, "Copiar" and "Usar" are 52dp and take the remaining row width.
- **Outlined:** "Generar otra" (regenerate), 52dp, beside the primary.
- **Text buttons:** dialog and secondary actions. The destructive "Eliminar" is in error colour.
- **Copy feedback:** on copy the icon swaps to a check (scale from 0.4 plus fade) and the label rolls up to the copied label (for example "Contraseña copiada"). A Confirm haptic fires and the state holds for 1.6 s. The snackbar says where the secret went; the button says which one.

### Extended FAB
- "Nueva" with a plus icon in polished brass (primaryContainer), 20dp corners, bottom right of the vault list. It is the only floating element.

### Cards / Containers (Plates)
- **Corner Style:** 20dp.
- **Background:** plate.
- **Shadow Strategy:** none (see Elevation).
- **Internal structure:** fields are stacked with hairline dividers, each at least 72dp tall with padding 12dp top, 16dp start, 4dp end and 8dp bottom. A Label Medium field label sits above a Body value, with a trailing 48dp icon action (copy, reveal, open).

### Inputs / Fields
- **Style:** Material outlined text fields with 6dp corners on steel.
- **Password field:** has a show/hide eye. Shown in clear it switches to Secret Medium and colours digits and symbols with the secret inks. The account-password variant at sign-in keeps the UI face. On a touch keyboard, "Next" skips the eye.
- **Shell search:** a 28dp pill in shellField with no indicator line. Placeholder and leading icon are onShellVariant ("Buscar en 7 contraseñas"); the cursor and selection handles are brass.
- **Form messages:** errors and notices open their own line (expand plus fade) instead of shoving buttons in one frame, and are announced politely.

### Navigation
- **Bar / rail:** graphite shell, with labels Bóveda / Generador / Ajustes. Unselected items are onShellVariant. Selected: brass indicator pill, dark-brass icon, onShell label.
- **Top bars:** graphite on top-level places, plain steel on pushed screens.
- **Transitions:** fade-through between sections (210ms in after a 90ms delay, scaling from 0.96). Shared X axis into and out of an entry (260ms, one-eighth width offset).

### Key Cap (signature)
An account's identity: the anodized cap with stamped initial (Bold, 40% of cap width), 40dp in rows and 60dp in the detail header. Its hue is derived from the label. It is decorative for accessibility because the label is always beside it. It is one object across screens: it lifts off its row and lands in the detail header.

### Lock Emblem (signature)
The 76dp app emblem on the sign-in and lock screens, acting out the vault's state. The shackle lifts on unlock, snaps shut with a slight over-seat on lock, and the key swings on its ring when the master password is rejected.

### Secret Text / Tumbler
Secrets change like pin tumblers. Each changed character rolls up through its own clipped cell from left to right, while unchanged characters stay put. Revealing rolls the ten mask dots out and the secret in.

### Strength Indicator
Five 6dp segments fill in the level's colour, then a row with the verdict in that colour (Label) and the entropy measurement in Secret Small ("Muy fuerte · 131 bits"), then one plain-language line (Body Small). Below the top rating that line is the most actionable pattern tip. At the top rating (Muy fuerte) it is the crack time alone ("Adivinarla llevaría más de un millón de años"), so a top verdict never comes with a reason to doubt it.

### Section Label / Empty State / Placeholders
Group labels in Label weight, muted ink and sentence case ("Cuenta", "Seguridad", "Apariencia"). Empty and error states have a 40dp muted icon, a Title line, a Body Medium explanation and an optional action. While decrypting, placeholder rows pulse in the list's own shape.

## Do's and Don'ts

### Do:
- **Do** keep each colour family to its job: caps for identity, brass for the one action and selection, strength colours for strength, error for errors.
- **Do** derive a key cap's hue from its label and accept collisions among the eight hues.
- **Do** set every secret and every compared number in Atkinson Hyperlegible Mono, with digits in secretDigit and symbols in secretSymbol.
- **Do** rank by weight (SemiBold vs Regular) and highlight search matches in Bold.
- **Do** put a secret on a plate lighter than the ground, with hairline dividers between fields.
- **Do** pin the primary action within thumb reach at the bottom of the detail (56dp, full width up to 600dp).
- **Do** keep graphite for top-level places and align expanded-window bar content to the column with ShellPanel.
- **Do** keep motion mechanical, within about 400 ms, and never blocking input, and let "Remove animations" cut it.
- **Do** show the crack time, not a pattern tip, at the top strength rating.

### Don't:
- **Don't** colour a secret's characters with a key-cap hue or the action brass.
- **Don't** use a key-cap hue on a control, or brass for anything but the primary action and selection.
- **Don't** warm the ground toward cream. The steel is cool grey in both themes.
- **Don't** add a second accent or a blue-shield palette.
- **Don't** lift plates or rows with shadows. Depth is tonal.
- **Don't** reveal a hidden secret's length. The mask is always ten dots.
- **Don't** make the user wait on an animation. Rolls and flights run while the screen is already usable.
