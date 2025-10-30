# image_preview.dart

- Path: lib/widgets/image_preview.dart
- Purpose: Displays the image on an artboard with pan/zoom via `TransformationController` and overlays a floating snackbar with zoom controls.
- Public API
  - Widgets:
    - `ImagePreview(controller, boardW, boardH, canvasW, canvasH, bytes, viewportKey)`
- Key dependencies: `ArtboardView`, `SnackbarImage`, `TransformationController`.
- Data flow & state
  - Inputs: Dimensions for board/canvas, raw image bytes, controller, viewport key.
  - Outputs: Applies matrix updates to controller for zoom in/out and fit.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Centers zoom on viewport focal point when available; falls back to scaling around origin when viewport size unknown.
- Invariants & caveats: Zoom clamped to [0.25, 8.0]; snackbar only shown when `bytes != null`.
- Extension points: Add pan-to-cursor; double-click zoom; reset-to-1x.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
