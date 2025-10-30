# overview_header.dart

- Path: lib/widgets/overview/overview_header.dart
- Purpose: Thin adapter that renders `AppHeaderBar` for the overview page with given tabs and callbacks.
- Public API
  - Widgets:
    - `OverviewHeader(tabs, activeIndex, onTabSelected, onCloseTab, onAddTab)`
- Key dependencies: `AppHeaderBar`, `GrufioTabData`.
- Data flow & state
  - Inputs: Tabs and callbacks.
  - Outputs: Forwards callbacks to parent.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No additional styling; delegates to `AppHeaderBar`.
- Invariants & caveats: None.
- Extension points: Add overview-specific controls.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
