# image_processing_service.dart

- Path: lib/services/image_processing_service.dart
- Purpose: Runs image processing workflows by invoking bundled Python scripts (quantization, OpenCV resize) and updates DB fields; invalidates providers to refresh UI.
- Public API
  - Classes:
    - `ImageProcessingService`: methods `quantizeImage(ref, projectId)`, `resizeToCv(ref, projectId, targetW, targetH, interpolationName)`, `updateImage(ref, projectId, scalePercent, filterQuality)`, `resetImage(ref, projectId)`.
  - Providers:
    - `imageProcessingServiceProvider`
- Key dependencies: `path_provider` (temp dir), `rootBundle` (load scripts), `Process.run` (python3), `AppDatabase`, `projectRepositoryProvider`, `image_compute` (decode dims/colors), `imageBytesProvider`, `SettingsService` (quant params), `logger`.
- Data flow & state
  - Inputs: Project id, sizing params, interpolation.
  - Outputs: Writes to `images` conv* fields and project's `updatedAt`; invalidates `imageBytesProvider`.
  - Providers/Streams watched: Reads DB and repositories via providers.
- Rendering/Side effects: File IO (temp scripts/images), external process invocation, DB writes, provider invalidations.
- Invariants & caveats: Requires Python3; cleans up temp files best-effort; uses 96 DPI default elsewhere; raises on failures; quantize returns palette via stdout JSON.
- Extension points: Move to native/Dart implementations; progress reporting; error UI.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
