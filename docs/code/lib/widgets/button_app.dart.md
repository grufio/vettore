# button_app.dart

- Path: lib/widgets/button_app.dart
- Purpose: Reusable app buttons: add/delete project and an outlined action button with hover/enable states, using Grufio icons and theme.
- Public API
  - Widgets:
    - `AddProjectButton(onTap)`
    - `DeleteProjectButton(onTap)`
    - `OutlinedActionButton(label, onTap, {minWidth, enabled})`
- Key dependencies: `Grufio` icons, theme colors/typography.
- Data flow & state
  - Inputs: Callbacks, labels, enabled flags.
  - Outputs: Emits taps to parent.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Hover styles for background/border/text; fixed heights and paddings.
- Invariants & caveats: Fixed height 24px; icon size 20px for add button; semantics implied by labels.
- Extension points: Add keyboard shortcuts; loading state.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
