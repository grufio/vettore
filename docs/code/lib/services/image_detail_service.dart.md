# image_detail_service.dart

- Path: lib/services/image_detail_service.dart
- Purpose: Utilities for converting between units and physical pixels, computing target sizes (linked/unlinked), persisting physical pixel floats, and orchestrating resize operations.
- Public API
  - Classes:
    - `ImageDetailService`: methods `toPhysPx`, `computeTargetPhys`, `rasterFromPhys`, `persistPhys`, `performResize`.
  - Providers:
    - `imageDetailServiceProvider`
- Key dependencies: `convertUnit` (unit conversion), `AppDatabase` (customStatement), `projectLogicProvider`, `imageBytesProvider`.
- Data flow & state
  - Inputs: User-typed values, units, dpi, current phys dims.
  - Outputs: DB updates for `phys_width_px4/phys_height_px4`; provider invalidations; delegates resize to project logic.
  - Providers/Streams watched: Reads providers via `WidgetRef`.
- Rendering/Side effects: No UI; orchestrates DB writes and provider invalidation.
- Invariants & caveats: Linked mode preserves aspect ratio using current phys dims; raster rounding uses `round()`.
- Extension points: Add more conversions; hooks for validation; async progress.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
