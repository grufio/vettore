# unit_selector_field.dart

- Path: lib/widgets/input_value_type/unit_selector_field.dart
- Purpose: Thin wrapper around `InputValueType` that wires a unit dropdown and mirrors the selected unit as suffix; centralizes number sanitization.
- Public API
  - Widgets:
    - `UnitSelectorField(controller, {focusNode, placeholder, prefixIconAsset, prefixIconFit, prefixIconAlignment, readOnly, readOnlyView, units, selectedUnit, onUnitSelected, inputFormatters})`
- Key dependencies: `InputValueType`, `sanitizeNumber`.
- Data flow & state
  - Inputs: Controllers, unit list, current unit, callbacks.
  - Outputs: Emits `onUnitSelected` when selection changes; sanitizes typed text.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Uses selector variant to flip suffix text to chevron on hover.
- Invariants & caveats: Ensures caret position is preserved after sanitization.
- Extension points: Validation; error display.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
