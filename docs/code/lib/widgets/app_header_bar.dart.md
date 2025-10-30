# app_header_bar.dart

- Path: lib/widgets/app_header_bar.dart
- Purpose: Custom header bar rendering the main tabs strip, an optional add-tab button, and a draggable window zone on macOS. Handles fullscreen-aware left padding and integrates with window events.
- Public API
  - Widgets:
    - `AppHeaderBar`: Stateful widget displaying tabs (via `GrufioTab`), add button, and optional drag zone; props include `tabs`, `activeIndex`, callbacks (`onTabSelected`, `onCloseTab`, `onAddTab`), sizing and behavior flags.
- Key dependencies: `bitsdojo_window` (`MoveWindow`), `window_manager` (fullscreen detection), `GrufioTab`, `GrufioTabButton`, theme colors (`kHeaderBackgroundColor`, `kBordersColor`).
- Data flow & state
  - Inputs: `tabs`, `activeIndex`, callbacks and layout flags.
  - Outputs: Invokes callbacks on tab select/close/add.
  - Providers/Streams watched: None.
- Rendering/Side effects: Draws a horizontal scrolling tabs row; listens to window events to toggle fullscreen padding; uses platform checks for macOS behavior.
- Invariants & caveats: Index 0 shows a left border; close buttons shown only when allowed and for non-home tabs; fullscreen padding suppressed when fullscreen.
- Extension points: Add more controls to header; customize tab appearance; add platform-specific behaviors.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
