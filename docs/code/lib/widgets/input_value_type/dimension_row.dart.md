# dimension_row.dart

- Path: lib/widgets/input_value_type/dimension_row.dart
- Purpose: Unified width/height row with unit selector, optional link toggle, and integration with `UnitValueController` for unit/DPI synchronization.
- Public API
  - Widgets:
    - `DimensionRow(primaryController, {partnerController, valueController, enabled, isWidth, showLinkToggle=false, initialLinked=false, onLinkChanged, onUnitChanged, readOnlyView=false, dpiOverride, units, initialUnit, inputFormatters, clampPxMin, clampPxMax, clampDpi})`
- Key dependencies: `UnitSelectorField`, `UnitValueController`, `ButtonToggle`, unit formatting helpers, `SectionInput`.
- Data flow & state
  - Inputs: Text controllers (primary/partner), optional `UnitValueController`, flags, units, DPI override.
  - Outputs: Emits unit/linked changes; echoes model value into text when controller value changes.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Syncs controller DPI/unit via post-frame; formats text to 2 decimals on blur; disables edit in read-only view.
- Invariants & caveats: Typing-only mode—does not compute aspect; linking managed via `UnitValueController` when provided.
- Extension points: Validation/clamping using provided bounds; error feedback.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
