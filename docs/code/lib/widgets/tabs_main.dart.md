# tabs_main.dart

- Path: lib/widgets/tabs_main.dart
- Purpose: Implements `GrufioTab` (a header tab widget) and `GrufioTabButton` (add-tab button), using the Grufio icon font and app theme to render active/hover/idle states.
- Public API
  - Widgets:
    - `GrufioTab`: Clickable tab with optional label and close button; controlled via props (`iconId`, `label`, `isActive`, `onTap`, `onClose`, borders, width).
    - `GrufioTabButton`: Fixed-size 40x40 button with add icon; triggers `onTap`.
- Key dependencies: `Grufio` icons (`grufio_icons.dart`, `grufio_registry.dart`), theme colors (`kTab*`), Flutter mouse regions and gestures.
- Data flow & state
  - Inputs: Props listed above.
  - Outputs: Emits taps via callbacks; no external state persistence.
  - Providers/Streams watched: None.
- Rendering/Side effects: Handles hover state, shows/hides close button opacity for inactive tabs, logs icon sizes once for debugging; snaps icon to 20x20 inside tab area; draws borders per flags.
- Invariants & caveats: Size constants: tab height 40, icon 20, font size 12; label uses Inter; home tab typically non-closable (enforced by caller).
- Extension points: Keyboard navigation; context menus; badges; adjustable sizes.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
