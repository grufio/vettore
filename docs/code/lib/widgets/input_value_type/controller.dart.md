# controller.dart

- Path: lib/widgets/input_value_type/controller.dart
- Purpose: Programmatic controller to open/close/toggle dropdowns and navigate/confirm selection in `InputValueType`.
- Public API
  - Classes:
    - `InputDropdownController` with methods: `attach(open, close, toggle, next, prev, confirm)`, `open`, `close`, `toggle`, `highlightNext`, `highlightPrev`, `confirm`.
- Key dependencies: None (callbacks wired by `InputValueType`).
- Data flow & state
  - Inputs: Attached callbacks supplied by the widget.
  - Outputs: Invokes attached actions.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: Must call `attach` before using methods.
- Extension points: Add listeners for open/close events.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
