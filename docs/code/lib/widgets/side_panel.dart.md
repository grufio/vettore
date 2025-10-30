# side_panel.dart

- Path: lib/widgets/side_panel.dart
- Purpose: Reusable left/right side panel with optional resizing, top padding, and horizontal padding; draws a separating border.
- Public API
  - Enums:
    - `SidePanelSide { left, right }`
  - Widgets:
    - `SidePanel(side, child, {width, topPadding, horizontalPadding, resizable, minWidth, maxWidth, onResizeDelta, onResetWidth})`
- Key dependencies: Theme colors for borders/background.
- Data flow & state
  - Inputs: Sizing, padding, callbacks for resize.
  - Outputs: Emits horizontal drag deltas and double-tap reset.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Draws left/right border; shows 8px wide drag zone when resizable.
- Invariants & caveats: Width clamped to [minWidth, maxWidth]; topPadding default 8.
- Extension points: Add persistent width storage; keyboard resizing.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
