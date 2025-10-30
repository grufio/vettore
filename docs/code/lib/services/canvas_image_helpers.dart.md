# canvas_image_helpers.dart

- Path: lib/services/canvas_image_helpers.dart
- Purpose: Helpers to derive on-screen preview sizes for canvas and image based on stored values/units or image metadata.
- Public API
  - Functions:
    - `getCanvasPreviewPx(widthValue, widthUnit, heightValue, heightUnit, previewDpi=96)` → `Size`
    - `getImagePreviewPx(width?, height?)` → `Size`
- Key dependencies: `convertUnit` from input_value_type module; `dart:ui` `Size`.
- Data flow & state
  - Inputs: Numeric values + units for canvas; optional image width/height.
  - Outputs: `Size` objects for preview dimensions.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Pure helpers, no side effects.
- Invariants & caveats: Uses provided `previewDpi` for unit conversion; does not clamp/validate values beyond conversion.
- Extension points: Add aspect/padding helpers; rounding strategies.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
