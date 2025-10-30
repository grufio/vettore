# lego_colors_importer.dart

- Path: lib/services/lego_colors_importer.dart
- Purpose: Imports LEGO colors from a CSV asset into the `lego_colors` table, parsing IDs, names, materials, RGB and timeline years.
- Public API
  - Classes:
    - `LegoColorsImporter`: `importFromAssetsCsv(assetPath)` reads and upserts rows.
- Key dependencies: `csv` (CsvToListConverter), `rootBundle` (loadString), `AppDatabase.customStatement`.
- Data flow & state
  - Inputs: Asset CSV path.
  - Outputs: Inserts/updates rows in `lego_colors` with parsed fields; returns count inserted.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Reads asset; issues raw SQL upserts.
- Invariants & caveats: Expects header with `legoID, legoName, material, mecabricksRGB, timeline`; timeline parsed as single year or range; empty RGB stored as NULL.
- Extension points: Add validation; support alternate CSV formats; move to typed companions.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
