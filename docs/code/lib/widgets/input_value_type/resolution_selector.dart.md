# resolution_selector.dart

- Path: lib/widgets/input_value_type/resolution_selector.dart
- Purpose: Dropdown selector for image DPI with `dpi` suffix and read-only support.
- Public API
  - Widgets:
    - `ResolutionSelector(value, onChanged, {enabled=true, readOnlyView=false})`
- Key dependencies: `InputValueType`, `SectionInput`.
- Data flow & state
  - Inputs: Current dpi (int), change callback.
  - Outputs: Emits integer dpi on selection.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Prefix help icon (16px); default items [72, 96, 144]; displays `dpi` suffix.
- Invariants & caveats: Converts items to strings for dropdown; guards against parse failures.
- Extension points: Custom lists; direct numeric entry.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
