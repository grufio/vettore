# dropdown_overlay.dart

- Path: lib/widgets/input_value_type/dropdown_overlay.dart
- Purpose: Creates and manages an overlay dropdown panel with keyboard navigation, hover highlights, and optional centered positioning.
- Public API
  - Constants: `kDropdownItemHeight`, `kDropdownPanelWidth`
  - Functions: `createDropdownOverlay({...})`, `removeDropdownOverlay(entry)`
- Key dependencies: Flutter `Overlay`, `CompositedTransformFollower`, `DropdownItem`, theme colors.
- Data flow & state
  - Inputs: Items, selected value, event callbacks, focus node, highlight listeneer, target geometry.
  - Outputs: OverlayEntry inserted into overlay; invokes selection/dismiss callbacks.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Positions panel above/below or centered; handles keys (arrows, home/end, enter, esc).
- Invariants & caveats: Capped visible items to 8; computes panel height; requires a valid target render box.
- Extension points: Typeahead filtering; virtualization for long lists.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
