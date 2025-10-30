# dropdown_item.dart

- Path: lib/widgets/input_value_type/dropdown_item.dart
- Purpose: Single row in dropdown panel with optional checkmark for selected item and hover highlight.
- Public API
  - Widgets:
    - `DropdownItem(label, {isSelected, highlighted, onTap, onHover})`
- Key dependencies: `Grufio.checkmark`, theme colors.
- Data flow & state
  - Inputs: Selection/highlight state; callbacks.
  - Outputs: Emits tap/hover.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: 24px row, 8px padding, hover bg; 16px checkmark for selected.
- Invariants & caveats: Text truncated to one line.
- Extension points: Keyboard focus visuals.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
