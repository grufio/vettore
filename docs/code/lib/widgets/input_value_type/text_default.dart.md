# text_default.dart

- Path: lib/widgets/input_value_type/text_default.dart
- Purpose: Reusable single-line text input (Title, etc.) composed with `InputValueType` and `SectionInput`, with optional action icon on the right.
- Public API
  - Widgets:
    - `TextDefaultInput(controller, {focusNode, placeholder, suffixText, prefixIconAsset='document-blank', actionIconAsset, onActionTap, onSubmitted, onChanged, maxLength, textCapitalization, readOnlyView})`
- Key dependencies: `InputValueType`, `SectionInput`.
- Data flow & state
  - Inputs: Text controller and visual/behavior props.
  - Outputs: Forwards `onChanged/onSubmitted` to parent; action icon tap.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Passes sizing for prefix icon (16x16) and alignments.
- Invariants & caveats: Read-only view disables interactions and switches styling.
- Extension points: Add validation styles; prefix override.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
