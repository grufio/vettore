# image_detail_controller.dart

- Path: lib/services/image_detail_controller.dart
- Purpose: Lightweight controller to centralize image detail UI state (units, DPI, seeding physical pixel values) using two `UnitValueController` instances.
- Public API
  - Classes:
    - `ImageDetailController`: setters for UI DPI and units; apply remote px values and set aspect; listening helper to seed from `imagePhysPixelsProvider`.
- Key dependencies: `UnitValueController`, `imagePhysPixelsProvider` (listen/read).
- Data flow & state
  - Inputs: DPI, chosen units, provider updates for image physical pixels.
  - Outputs: Notifies bound callbacks `onWidthUnitChanged`/`onHeightUnitChanged`.
  - Providers/Streams watched: Listens to `imagePhysPixelsProvider(imageId)` to seed.
- Rendering/Side effects: No rendering; emits controller-side effects via callbacks.
- Invariants & caveats: Avoids duplicate listen by caching last image id; sets aspect ratio when both px values are available.
- Extension points: More controller responsibilities (validation, preset application, sync to DB).
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
