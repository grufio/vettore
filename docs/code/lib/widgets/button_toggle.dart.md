# button_toggle.dart

- Path: lib/widgets/button_toggle.dart
- Purpose: Link/unlink toggle control with hover/disabled styles using Grufio icons.
- Public API
  - Widgets:
    - `ButtonToggle(value, onChanged, {onIconAsset='link', offIconAsset='unlink', disabled=false})`
- Key dependencies: `Grufio.link`/`Grufio.unlink`, theme colors.
- Data flow & state
  - Inputs: Current value, callback, optional icon ids, disabled flag.
  - Outputs: Emits toggled value via `onChanged`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: 24x24 container with hover bg and optional border when active; icon size 16.
- Invariants & caveats: Uses deterministic icon ids `link`/`unlink`; semantics label switches accordingly.
- Extension points: Keyboard toggle; focus visuals.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
