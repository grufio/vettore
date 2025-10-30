# interpolation_selector.dart

- Path: lib/widgets/input_value_type/interpolation_selector.dart
- Purpose: Dropdown selector for interpolation method, rendered via `InputValueType` inside a `SectionInput`.
- Public API
  - Widgets:
    - `InterpolationSelector(value, onChanged, {enabled=true, readOnlyView=false})`
- Key dependencies: `kInterpolations`, `InputValueType`, `SectionInput`.
- Data flow & state
  - Inputs: Current value and callback.
  - Outputs: Emits selected string on pick.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Prefix help icon (16px); read-only view support.
- Invariants & caveats: Uses a fixed list `kInterpolations`.
- Extension points: Allow custom lists; tooltips per item.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
