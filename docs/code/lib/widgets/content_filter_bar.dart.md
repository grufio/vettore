# content_filter_bar.dart

- Path: lib/widgets/content_filter_bar.dart
- Purpose: Horizontally scrollable bar of filter chips with keyboard navigation and auto-centering of the active chip.
- Public API
  - Classes:
    - `FilterItem(id, label)`
  - Widgets:
    - `ContentFilterBar(items, activeId, onChanged, {height=40, horizontalPadding=24, gap=4, scrollable=true})`
- Key dependencies: `ContentChip`, Flutter focus/shortcuts.
- Data flow & state
  - Inputs: List of items, active id, and change callback.
  - Outputs: Emits selected id on tap or keyboard navigation.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Ensures active item is visible after changes; supports arrow-left/right navigation.
- Invariants & caveats: Rebuilds key list when items length changes; gap between items configurable.
- Extension points: Add home/end shortcuts; tooltips; badges.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
