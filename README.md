# vettore

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Model/Type fields

- Model: stored on `projects.model` as `bricks` or `colors`.
- Type: stored on `projects.vendor_id` referencing `vendors.id`.
- Vendors are classified via `vendors.vendor_category` (`bricks` or `colors`) to filter Type choices.
- UI behavior in `lib/app_project_detail.dart`:
  - The “Model” dropdown (Bricks/Colors) controls the available “Type” options.
  - Bricks → default Type is Lego; Colors → default Type is Schmincke.
  - Selections are persisted immediately to the database.

### Migration
- Schema version: 19.
- Added columns (guarded): `vendors.vendor_category`, `projects.model`, `projects.vendor_id`.
- Seeded vendor: `Lego` with `vendor_category='bricks'`.
- Indexes: `idx_vendors_vendor_category`, `idx_projects_model`, `idx_projects_vendor_id`.

## DPI and Units

 - Default DPI: 96. On import, DPI is set from EXIF when available; otherwise 96.
 - Conversions: internal math uses exact factors; no rounding applied during conversion.
 - Precision policy:
   - Single source of truth: physical size in pixels (float) at 4‑decimal precision per side (`images.phys_width_px4`, `images.phys_height_px4`).
   - UI display: always 2 decimals for every unit (including `px`).
   - Raster/preview: snapped integer pixels (nearest) only for rendering and OpenCV resize.
 - Typing: no live formatting while typing; formatting to 2 decimals happens on blur/unit change. Physical values commit on Resize.
 - Resize flow: compute physical target (float) from typed values + DPI → persist phys floats → round to nearest integer px for raster → OpenCV resize → invalidate providers.
 - Resize prerequisites: at least one field must be numeric; enabled when typed 2‑dec differs from committed phys 2‑dec.

### Schema v27

- Added columns to `images`:
  - `phys_width_px4 REAL`
  - `phys_height_px4 REAL`
- Backfill: initialize phys from converted dims when present; else from original dims.
- Providers:
  - `imagePhysPixelsProvider` returns physical floats; `imageDimensionsProvider` returns raster ints for preview.

## Tooling scripts (tool/)

These Dart scripts support data verification and maintenance. Run them with Flutter's Dart VM:

```bash
flutter pub get
```

### verify_density.dart
- Purpose: Verifies that vendor color density values are within expected bounds or populated where required.
- Run:
```bash
flutter run -t tool/verify_density.dart
```

### verify_weights.dart
- Purpose: Checks and validates color weights; reports missing or anomalous data.
- Run:
```bash
flutter run -t tool/verify_weights.dart
```

### fetch_color_weights.dart
- Purpose: Scrapes weight info from vendor pages and updates the local DB (`vendor_colors.weight_in_grams`).
- Notes:
  - Requires network access; be considerate with frequency.
  - Uses a short delay between requests (500ms) to avoid hammering.
- Run:
```bash
flutter run -t tool/fetch_color_weights.dart
```

### calculate_density.dart
- Purpose: Calculates color density using available weight/volume information and writes results back.
- Run:
```bash
flutter run -t tool/calculate_density.dart
```

### patch_missing_weights.dart
- Purpose: Fills missing weight entries using heuristics or derived values; intended for cleanup passes.
- Run:
```bash
flutter run -t tool/patch_missing_weights.dart
```

### reachability.dart (custom analyzer)
- Purpose: Detects unreachable/unused Dart files via static import/export/part traversal.
- CI: `./.github/workflows/reachability.yml` fails PRs with unreachable files.
- Local run:
```bash
flutter run -t tool/reachability.dart -- <options>
```
- Common flags:
  - `--entry lib/main.dart` to set a specific entrypoint
  - `--delete` to remove files after confirmation (use with caution)

## CI

- PRs run `flutter analyze` and `flutter test` via `.github/workflows/flutter_ci.yml`.
