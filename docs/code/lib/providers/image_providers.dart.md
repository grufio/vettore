# image_providers.dart

- Path: lib/providers/image_providers.dart
- Purpose: Fetch image bytes (preferring converted), per-image DPI, and physical pixel floats (width/height) from the DB.
- Public API
  - Providers:
    - `imageBytesProvider(imageId)`: `FutureProvider.family<Uint8List?>`
    - `imageDpiProvider(imageId)`: `FutureProvider.family<int?>`
    - `imagePhysPixelsProvider(imageId)`: `FutureProvider.family<(double?, double?)>`
- Key dependencies: `appDatabaseProvider`, Drift custom queries, `images` table.
- Data flow & state
  - Inputs: `imageId`.
  - Outputs: Bytes/DPI/phys px read from DB; converted bytes take precedence.
  - Providers/Streams watched: Reads `appDatabaseProvider`.
- Rendering/Side effects: No UI; DB reads only.
- Invariants & caveats: `convSrc` preferred over `origSrc`; returns nulls if rows missing; phys px are floats used as source of truth for sizing.
- Extension points: Add streams; caching; error logging.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
