---
version: 1
slug: "presentation"
primary_target: "presentation"
related_targets: []
---

# Surface: Bóveda app (presentation module)

Scope: every screen of the Android app (auth, create/unlock vault, vault list, entry detail, entry editor, generator, settings). Visitor mode: Operate.

Audience and job: one person on their own phone, mid-login in another app: unlock, find, copy, leave. Second job: give every new account a generated password.

Constraints: Material 3 components and navigation (navigation bar on compact, rail on wider windows), system Back, edge-to-edge insets, 48 dp targets, Spanish copy, light and dark themes, optional wallpaper colours as a setting.

Memorable moment: the anodized key cap that identifies each account, stable from list row to detail header.

Unresolved: autofill service and import/export are out of scope.

## Direction contract

THESIS: The vault is a locksmith's key board: every account hangs as a key with an anodized cap, and secrets are stamped in a mono built to tell 0 from O and l from 1. It refuses the category default of a navy/neon shield app with a grey list and one blue accent.

OWN-WORLD: Brushed-steel ground (cool grey, never cream), a graphite shell panel for top bar and navigation, brass for the one primary action and selection, eight anodized cap hues (cobalt, green, violet, copper, brass, teal, magenta, slate) used only for account identity, and state colours only for strength and errors. Atkinson Hyperlegible Next for all UI, Atkinson Hyperlegible Mono for every secret. Tight type scale, rank by weight.

STORY: Unlock with fingerprint, see the keys A–Z, type two letters, copy from the row, get a snackbar promising the clipboard clears, switch app. For a new account: Nueva, fill, Generar, watch the password and its strength recompute live, Usar, Guardar.

FIRST VIEWPORT: Graphite top bar titled Bóveda with lock action and a search field docked under it; list rows at list density with hairline insets: 40 dp key cap with stamped initial, title, username, 48 dp copy button; brass extended FAB "Nueva" bottom right; graphite navigation bar Bóveda / Generador / Ajustes.

FORM: Llavero de cerrajería, position 3 of 7 on the grounded list, seed key 3d1e55ce. Raises: colour quarantine (lexicon), list density with hairlines (Japanese density), thumb-reach primary action on detail (vertical feed), live recompute with numeric readout in the generator (type specimen), rank by weight (timetable).

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
