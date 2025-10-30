# chip_filter.dart

- Path: lib/widgets/chip_filter.dart
- Purpose: Filter chip widget used by `ContentFilterBar`, with active/inactive and hover styles.
- Public API
  - Widgets:
    - `ContentChip.active(label)`
    - `ContentChip.inactive(label)`
- Key dependencies: Theme colors/typography.
- Data flow & state
  - Inputs: Label and active state.
  - Outputs: None; parent handles taps.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: 20px height, 8px horizontal padding, rounded corners; inactive chips show hover background.
- Invariants & caveats: Clears hover when transitioning from active to inactive to avoid stale state.
- Extension points: Add icons; close buttons; focus outlines.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
