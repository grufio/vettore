# image_upload_service.dart

- Path: lib/services/image_upload_service.dart
- Purpose: Handles inserting uploaded images into the DB, decoding metadata (dimensions, DPI) in isolates, and seeding physical pixel fields.
- Public API
  - Classes:
    - `UploadedImageResult(imageId, width?, height?, dpi)`
    - `ImageUploadService`: `insertImageAndMetadata(ref, bytes)`
  - Providers:
    - `imageUploadServiceProvider`
- Key dependencies: `AppDatabase` (images table), `compute` (isolate offload), `image_compute` helpers, `appDatabaseProvider`.
- Data flow & state
  - Inputs: Raw image bytes.
  - Outputs: Inserts `images` row (orig* fields, mime), updates DPI and phys px, returns `UploadedImageResult`.
  - Providers/Streams watched: Reads `appDatabaseProvider`.
- Rendering/Side effects: DB writes; debug print for stored image.
- Invariants & caveats: Default DPI 96 if absent; uses `detectMimeType`; sets phys px from decoded dims.
- Extension points: Additional metadata; error handling; storage backends.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
