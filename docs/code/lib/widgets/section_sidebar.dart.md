# section_sidebar.dart

- Path: lib/widgets/section_sidebar.dart
- Purpose: Sidebar section container with a title (and optional toggle) and a standardized row layout component `SectionInput` for inputs/actions.
- Public API
  - Widgets:
    - `SectionSidebar({title, children=[], showTitleToggle=false, titleToggleOn=true, onTitleToggle})`
    - `SectionInput({left, right, full, action, actionIconAsset, onActionTap, actionDisabled=false})`
- Key dependencies: Theme colors/typography, `InputValueType` (for `SectionInput.fullText` factory), Grufio icons for title toggle.
- Data flow & state
  - Inputs: Title, child widgets, toggle state/callback; input layout contents.
  - Outputs: Emits toggle changes via `onTitleToggle`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Section has white background, bottom border, 12px padding; `SectionInput` reserves a trailing 24x24 action slot.
- Invariants & caveats: `SectionInput` always reserves trailing action to align rows; when `full` is set, left/right are ignored.
- Extension points: Action icon rendering; section variants.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
