# app_theme_colors.dart

- Path: lib/theme/app_theme_colors.dart
- Purpose: Central color palette constants for the app (greys, header/borders, tabs, chips, buttons, inputs).
- Public API
  - Constants: `kWhite`, `kGrey10..kGrey100`, `kBordersColor`, `kHeaderBackgroundColor`, `kButtonColor`, tab and chip colors, input focus/background, etc.
- Key dependencies: Flutter `Color`.
- Data flow & state
  - Inputs: Not applicable.
  - Outputs: Color constants used throughout UI.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: Colors chosen to match app visual spec.
- Extension points: Add semantic colors; dark theme variants.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
