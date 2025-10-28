# app_router.dart

- Path: lib/app_router.dart
- Purpose: Defines global `GoRouter` with a `ShellRoute` that keeps `AppHeaderBar` persistent across routes. Manages tab selection/closing, routes for home and project detail, and coordinates tab creation/label updates from the database based on navigation.
- Public API
  - Constants:
    - `appRouter`: Configured `GoRouter` instance used by the app.
- Key dependencies: `go_router`, `flutter_riverpod` (consumers, providers), `AppOverviewPage`, `AppProjectInfoPage`, `AppHeaderBar`, `tabsProvider`, `activeTabIndexProvider`, `tabsServiceProvider`, `projectRepositoryProvider`, `TabsSyncRouterObserver`, `kWhite`.
- Data flow & state
  - Inputs: `GoRouterState` (`pathParameters['id']`), Riverpod providers (`tabsProvider`, `activeTabIndexProvider`).
  - Outputs: Navigation via `context.go`; updates to providers on tab select/close; async label update for project tabs.
  - Providers/Streams watched: `tabsProvider`, `activeTabIndexProvider`; reads `tabsServiceProvider`, `projectRepositoryProvider`.
- Rendering/Side effects: Renders `AppHeaderBar` above all content; on `/project/:id`, schedules a post-frame callback to add/select the tab with a fallback label then asynchronously updates the tab label from DB.
- Invariants & caveats: Index 0 routes to home; project tabs navigate to `/project/:id`; label fetch errors are ignored; uses post-frame to avoid build-timing issues.
- Extension points: Add routes, redirect logic, error pages; expand tab synchronization behavior.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
