# prefix_icon.dart

- Path: lib/widgets/input_value_type/prefix_icon.dart
- Purpose: Renders a deterministic prefix icon for inputs based on a string id, using Grufio font icons.
- Public API
  - Widgets:
    - `PrefixIcon(asset, {size=16, alignment=centerLeft, fit=BoxFit.none, color=kGrey70})`
- Key dependencies: `Grufio` icons, theme colors.
- Data flow & state
  - Inputs: Asset id string (`help`, `width`, `height`, `document-blank`).
  - Outputs: Icon widget.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Sizes the icon in a fixed square box with center alignment.
- Invariants & caveats: Unknown ids render an empty box.
- Extension points: Add more mappings; fallback icon.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
