# input_value_type.dart

- Path: lib/widgets/input_value_type/input_value_type.dart
- Purpose: Core input widget with optional dropdown behavior and custom suffix rendering (regular, selector, dropdown). Manages focus, selection, overlay dropdown, and read-only view styles.
- Public API
  - Enums: `InputVariant { regular, selector, dropdown }`
  - Widgets:
    - `InputValueType({...})` and factory `InputValueType.text(...)`
  - Classes (internal suffix button): `_IconSuffixButton` (internal)
- Key dependencies: Flutter `TextField`, `Material`, theme colors/typography, `PrefixIcon`, suffix widgets (`suffix.dart`), `dropdown_overlay.dart`, `InputDropdownController`.
- Data flow & state
  - Inputs: Text controller/focus, placeholder/suffix, dropdown items/selection, formatters, variant, read-only flags.
  - Outputs: `onChanged`, `onSubmitted`, `onItemSelected` callbacks; dropdown selection/keyboard navigation events.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Draws a 24px-high field with prefix icon; shows placeholder; manages cursor/selection rules for read-only; inserts overlay dropdown aligned to field; keyboard shortcuts (arrows/home/end/enter/esc) when dropdown open.
- Invariants & caveats: Read-only hides selection/cursor; dropdown controller can programmatically open/close/navigate; maintains internal selected item in uncontrolled mode.
- Extension points: Validation/error state; accessibility labels; multi-line variant.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
