# app_overview.dart

- Path: lib/app_overview.dart
- Purpose: Overview (home) page and supporting header tabs widget for macOS. Shows left navigation (projects/vendors), toolbar and filter bar, and the `AssetGallery`. Handles creating a new project and navigating to its detail page.
- Public API
  - Classes/Widgets (exported):
    - `GrufioTabsApp`: Renders tabs row given a list of `GrufioTabData` and active index.
    - `AppOverviewPage`: Page widget with optional header; hosts side panel, toolbar, filters, and gallery.
- Key dependencies: `go_router`, `drift` (Value wrapper for inserts), `flutter_riverpod`, `projectRepositoryProvider`, `tabsServiceProvider`, `homeNavSelectedIndexProvider`, `SidePanel`, `ProjectNavigation`, `ContentToolbar`, `ContentFilterBar`, `AssetGallery`, `AddProjectButton`, `kWhite`.
- Data flow & state
  - Inputs: `AppOverviewPage` props (`showHeader`, callbacks).
  - Outputs: Creates project in DB, navigates to `/project/:id`, updates header tabs via `tabsServiceProvider`.
  - Providers/Streams watched: `homeNavSelectedIndexProvider` (in multiple Consumers); reads `projectRepositoryProvider`, `tabsServiceProvider`.
- Rendering/Side effects: macOS-specific header and layout; dynamic side panel width with resize; project creation (`insert` via Drift) then navigation; gallery filters by nav index.
- Invariants & caveats: Home tab (index 0) not closable in local header; `showHeader: false` variant renders only content area; side panel width clamped 200–400.
- Extension points: Add more filters or nav categories; adjust gallery/show rules; replace local tabs with global tabs if desired.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
