# context_menu.dart

- Path: lib/widgets/context_menu.dart
- Purpose: Lightweight custom context menu implemented with an Overlay, keyboard dismiss (ESC), outside-tap dismiss, and hover styles.
- Public API
  - Classes:
    - `ContextMenuItem(label, onTap)`
    - `ContextMenuController.close()`
    - `ContextMenu.show(context, globalPosition, items, {onClose})` → `ContextMenuController`
- Key dependencies: Flutter `Overlay`, `RawKeyboardListener`, theme colors, dropdown sizing constants.
- Data flow & state
  - Inputs: Global screen position and menu items.
  - Outputs: Creates an `OverlayEntry`; invokes item callbacks; calls `onClose` on dismiss.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Inserts overlay; listens for ESC and focus loss to dismiss; outside tap closes; hover highlights rows.
- Invariants & caveats: Only one menu active at a time (single-open guard); focus requested to capture ESC.
- Extension points: Submenus; icons/shortcuts per row; accessibility labels.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
