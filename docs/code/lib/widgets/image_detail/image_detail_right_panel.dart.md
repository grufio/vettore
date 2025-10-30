# image_detail_right_panel.dart

- Path: lib/widgets/image_detail/image_detail_right_panel.dart
- Purpose: Right-side panel composition for the image detail page, providing a resizable `SidePanel` wrapper and a `ImageDetailDimensions` section widget.
- Public API
  - Widgets:
    - `ImageDetailRightPanel(width, onResize, onReset, child)` wraps any child in a right `SidePanel`.
    - `ImageDetailDimensions(projectId, widthController, heightController, controller, linkWH, onLinkChanged, interpolation, onInterpolationChanged, onResizeTap)`
- Key dependencies: `SidePanel`, `ImageDimensionsSection`, `ImageDetailController`.
- Data flow & state
  - Inputs: Panel sizing callbacks; dimension controls and callbacks for `ImageDetailDimensions`.
  - Outputs: Emits resize/linked/interpolation and forwards resize taps.
  - Providers/Streams watched: Not applicable in this file (downstream widgets do).
- Rendering/Side effects: No side effects; layout composition only.
- Invariants & caveats: `SidePanel` enforces min width and provides a drag handle.
- Extension points: Add more sections below dimensions.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
