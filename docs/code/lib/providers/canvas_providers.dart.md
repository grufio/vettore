# canvas_providers.dart

- Path: lib/providers/canvas_providers.dart
- Purpose: Local state for canvas preview dimensions used by UI.
- Public API
  - Data classes:
    - `CanvasSpec(widthPx, heightPx)`
  - Providers/Notifiers:
    - `CanvasSpecNotifier` with `setSpec`.
    - `canvasSpecProvider`: `StateNotifierProvider<CanvasSpecNotifier, CanvasSpec>`
- Key dependencies: `flutter_riverpod`.
- Data flow & state
  - Inputs: UI-initiated size changes.
  - Outputs: Emits new `CanvasSpec` to consumers.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No direct rendering.
- Invariants & caveats: Defaults to 100x100 px; caller ensures constraints.
- Extension points: Add unit-aware spec or DPI coupling; persistence.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
