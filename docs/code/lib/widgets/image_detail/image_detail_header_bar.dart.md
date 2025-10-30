# image_detail_header_bar.dart

- Path: lib/widgets/image_detail/image_detail_header_bar.dart
- Purpose: Header bar for the image detail area; renders a `ContentFilterBar` with predefined sections and a bottom border.
- Public API
  - Widgets:
    - `ImageDetailHeaderBar(activeId, onChanged)`
- Key dependencies: `ContentFilterBar`, theme colors.
- Data flow & state
  - Inputs: `activeId` string and `onChanged` callback.
  - Outputs: Emits section id changes to parent.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Styled container with white background and bottom border.
- Invariants & caveats: Sections hard-coded (project, image, icon, conversion, grid, output).
- Extension points: Make sections configurable; add actions on the right.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
