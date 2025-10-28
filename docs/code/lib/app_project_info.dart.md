# app_project_info.dart

- Path: lib/app_project_info.dart
- Purpose: Project Info shell page. Renders a 33px left side menu, a resizable left side panel with `ProjectNavigation`, a content toolbar and filter bar, and the `AssetGallery` (vendors hidden).
- Public API
  - Classes/Widgets (exported):
    - `AppProjectInfoPage`: Stateful page with optional `projectId` parameter.
- Key dependencies: `SideMenu33`, `SidePanel`, `ProjectNavigation`, `ContentToolbar`, `ContentFilterBar`, `AddProjectButton`, `AssetGallery`, `kWhite`.
- Data flow & state
  - Inputs: `projectId` (unused for data yet, reserved for context).
  - Outputs: UI state updates for side menu selection, side panel width, and active filter.
  - Providers/Streams watched: None (pure UI composition currently).
- Rendering/Side effects: Side panel width clamped to 200–400 with resize/reset; toggling menu selection only affects styling; gallery shows projects only.
- Invariants & caveats: `SideMenu33` on/off switches style; `ProjectNavigation` tap is a no-op placeholder.
- Extension points: Wire navigation actions; load project-specific data; filter gallery by `projectId`.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
