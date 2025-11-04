# artboard_view.dart

- Path: lib/widgets/artboard_view.dart
- Purpose: Canvas-like artboard that centers the image canvas within an `InteractiveViewer`, supports pan/zoom, and draws a crisp hairline border regardless of scale/DPR.
- Public API
  - Widgets:
    - `ArtboardView(controller, boardW, boardH, canvasW, canvasH, bytes, {outerPad=0, viewportKey})`
  - Painters:
    - `HairlineCanvasBorderPainter` (unused in this view), `HairlineBorderPainter(scale, dpr)`
- Key dependencies: `InteractiveViewer`, theme colors.
- Data flow & state
  - Inputs: Board/canvas sizes, image bytes, controller, padding.
  - Outputs: Renders image bytes (no filtering, gaplessPlayback) and a hairline border.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Expands to viewport; sets wide boundary margins; hairline border thickness compensates for scale and DPR via inset.
- Invariants & caveats: Min/max zoom [0.25, 8.0]; image centered with `OverflowBox` to avoid scaling.
- Extension points: Grid overlay; rulers; background textures.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
