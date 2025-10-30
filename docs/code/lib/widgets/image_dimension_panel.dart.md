# image_dimension_panel.dart

- Path: lib/widgets/image_dimension_panel.dart
- Purpose: UI panel for editing image dimensions with unit-aware inputs, interpolation, DPI, and a Resize action, enabling the button only on meaningful changes.
- Public API
  - Widgets:
    - `ImageDimensionPanel(...)` with numerous controllers and callbacks (see source).
- Key dependencies: `DimensionRow`, `InterpolationSelector`, `ResolutionSelector`, `OutlinedActionButton`, `UnitValueController`, `SectionSidebar`.
- Data flow & state
  - Inputs: Text/value controllers, linked flag, units, dpi, interpolation.
  - Outputs: Emits unit changes, DPI changes, interpolation changes, and `onResizeTap`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Tracks baselines of committed values; listeners update UI and determine if Resize is enabled; resets baselines on DPI change.
- Invariants & caveats: Resize enabled only if enabled=true and at least one valid numeric field differs from baseline; DPI influences conversions.
- Extension points: Validation messaging; error states; live aspect lock.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
