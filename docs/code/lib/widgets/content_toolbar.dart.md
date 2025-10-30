# content_toolbar.dart

- Path: lib/widgets/content_toolbar.dart
- Purpose: Simple top toolbar with optional title on the left and a trailing actions row on the right; draws a bottom border.
- Public API
  - Widgets:
    - `ContentToolbar({title, trailing, height=48, horizontalPadding=24, gap=8})`
- Key dependencies: Theme colors (`kWhite`, `kBordersColor`, `kGrey100`) and `appTextStyles`.
- Data flow & state
  - Inputs: Optional title string, trailing widgets list, sizing/padding values.
  - Outputs: Renders provided trailing widgets spaced by `gap`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Fixed height container; ellipsizes long titles; inserts gaps between trailing items.
- Invariants & caveats: When no title, a `Spacer` occupies left side; title font forced to medium 14.
- Extension points: Add leading slot; sticky behavior; overflow menu.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
