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
