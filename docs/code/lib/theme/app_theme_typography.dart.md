# app_theme_typography.dart

- Path: lib/theme/app_theme_typography.dart
- Purpose: Exported text style presets (body sizes and weights) used across the app.
- Public API
  - Classes:
    - `AppTextStylesExported`: getters `bodyXS`, `bodyS`, `bodyM`, `bodyMMedium`, `bodyL`, `bodyXL`.
  - Constants:
    - `appTextStyles`: instance for convenient access.
- Key dependencies: `TextStyle`, theme colors (kGrey90).
- Data flow & state
  - Inputs: Not applicable.
  - Outputs: `TextStyle` instances.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: Fixed Inter/weights implied by Flutter defaults; can be extended for headings.
- Extension points: Add headings/captions; dynamic theme linkage.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
