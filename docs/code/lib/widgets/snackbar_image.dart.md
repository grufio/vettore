# snackbar_image.dart

- Path: lib/widgets/snackbar_image.dart
- Purpose: Floating snackbar-style control with zoom in/out/fit buttons for image previews.
- Public API
  - Widgets:
    - `SnackbarImage({onZoomIn, onZoomOut, onFitToScreen})`
- Key dependencies: `Grufio.zoomIn/zoomOut/zoomFit`, theme colors.
- Data flow & state
  - Inputs: Optional callbacks.
  - Outputs: Invokes callbacks on button taps.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: 40px high capsule with border and rounded corners; icon buttons with hover color change; icon size 24.
- Invariants & caveats: No internal state beyond hover; renders even if callbacks are null (inactive style).
- Extension points: Add Reset button; tooltips; keyboard shortcuts.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
