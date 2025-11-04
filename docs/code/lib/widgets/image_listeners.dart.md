# image_listeners.dart

- Path: lib/widgets/image_listeners.dart
- Purpose: Helper widget that wires project/image providers to an `ImageDetailController`, syncing DPI and physical pixels when the image id changes.
- Public API
  - Widgets:
    - `ImageListeners(projectId, controller)` (ConsumerStatefulWidget)
- Key dependencies: `imageIdStableProvider`, `imagePhysPixelsProvider` (via controller.listen), `imageDpiProvider`, `ImageDetailController`.
- Data flow & state
  - Inputs: Project id.
  - Outputs: Seeds controller with phys px and DPI; no UI rendering (returns `SizedBox.shrink()`).
  - Providers/Streams watched: Watches `imageIdStableProvider(projectId)`.
- Rendering/Side effects: Triggers controller updates; reads `imageDpiProvider(imageId).future` to set DPI.
- Invariants & caveats: Only reacts when image id changes; guards `mounted` before applying async DPI.
- Extension points: Listen to more image metadata changes.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
