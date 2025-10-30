# suffix.dart

- Path: lib/widgets/input_value_type/suffix.dart
- Purpose: Hover-driven selector suffix for `InputValueType.selector`, toggling between text and chevron icon.
- Public API
  - Widgets:
    - `HoverSelectorSuffix({suffixText, iconAsset, onTap, showAsIcon=false, onTapDownGlobal})`
- Key dependencies: `Grufio.chevronDown`, theme colors/typography.
- Data flow & state
  - Inputs: Text/icon id, tap handlers, showAsIcon flag.
  - Outputs: Invokes `onTap` and reports global tap position.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Shows chevron on hover or when `showAsIcon` is true; otherwise shows suffix text aligned right.
- Invariants & caveats: Only supports `chevron-down` icon id.
- Extension points: Support more icons; add tooltip.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
