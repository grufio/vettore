# palette_repository.dart

- Path: lib/repositories/palette_repository.dart
- Purpose: Repository for palettes; provides efficient streams for palettes with nested colors/components, and write operations to add/update/delete palettes, colors, and components.
- Public API
  - Data classes:
    - `FullPalette(palette, colors)` groups a palette with its colors/components.
    - `PaletteColorWithComponents(color, components)` pairs a color with its components.
  - Classes:
    - `PaletteRepository(AppDatabase)`: methods `watchAllPalettes()`, `watchPalette(id)`, `addPalette(palette, colors)`, `updatePaletteColors(paletteId, newColors)`, `deletePalette(id)`, `updatePaletteDetails`, `addColorToPalette`, `updateColor`, `updateColorWithComponents`, `deleteColor`, `addComponent`, `updateComponent`, `deleteComponent`, `watchColorComponents(paletteColorId)`, `findVendorColorByName(name)`, `addColorWithComponents(color, components)`.
- Key dependencies: Drift joins (`join`, `leftOuterJoin`), `collection.groupBy`, `equatable` (value equality), `AppDatabase` tables.
- Data flow & state
  - Inputs: Palette/color/component companion objects, ids.
  - Outputs: DB transactions and streams; nested aggregation for `watchAllPalettes`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No UI; database operations; efficient grouping to avoid N+1.
- Invariants & caveats: Uses left-outer joins to include palettes without colors/components; `watchPalette` projects from `watchAllPalettes`.
- Extension points: Filtering/sorting; pagination; batch upserts; constraints on component sums.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
