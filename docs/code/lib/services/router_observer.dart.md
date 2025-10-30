# router_observer.dart

- Path: lib/services/router_observer.dart
- Purpose: Navigator observer that keeps header tabs synchronized with URL changes. When navigating to `/project/:id`, ensures the corresponding tab exists, selects it, and asynchronously updates its label from the database.
- Public API
  - Classes:
    - `TabsSyncRouterObserver`: Extends `NavigatorObserver`; reacts to push/replace/pop and triggers tab sync.
- Key dependencies: `go_router` (location), `flutter_riverpod` (`ProviderScope.containerOf`), `tabsServiceProvider`, `tabsProvider`, `projectRepositoryProvider`, `DbProject`.
- Data flow & state
  - Inputs: Current route/location from GoRouter; project id parsed from path.
  - Outputs: Calls `TabsService.addOrSelectProjectTab`, then updates label via `tabsProvider.notifier.updateProjectTabLabel`.
  - Providers/Streams watched: Reads providers via container; no watching in build.
- Rendering/Side effects: No rendering; side effects include provider updates and DB fetch for project title.
- Invariants & caveats: Only operates on `/project/:id`; ignores errors fetching title; deduplication by projectId handled by `TabsService/TabsNotifier`.
- Extension points: Extend `_syncForRoute` to support more routes or label sources; add error logging.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
