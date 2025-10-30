# image_dimensions_section.dart

- Path: lib/widgets/image_dimensions_section.dart
- Purpose: Composition widget that binds project/image providers, persists DPI, syncs units from settings, and renders `ImageDimensionPanel`.
- Public API
  - Widgets:
    - `ImageDimensionsSection(projectId, widthTextController, heightTextController, imgCtrl, linkWH, onLinkChanged, interpolation, onInterpolationChanged, onResizeTap)`
- Key dependencies: `imageIdStableProvider`, `imageDpiProvider`, `imageWidthUnitProvider`, `imageHeightUnitProvider`, `appDatabaseProvider`, `ImageDetailController`, `ImageDimensionPanel`.
- Data flow & state
  - Inputs: Project id, controllers, flags.
  - Outputs: Updates DPI in DB; invalidates DPI provider; syncs units via controller callbacks.
  - Providers/Streams watched: Multiple providers for image id, dpi, and unit defaults.
- Rendering/Side effects: Schedules post-frame unit sync; writes DPI to DB on change.
- Invariants & caveats: Uses 96 DPI fallback; unit providers hold last selection per project.
- Extension points: Add validation; optimistic updates; error handling for DPI writes.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
