# image_actions.dart

- Path: lib/services/image_actions.dart
- Purpose: High-level image action to commit a resize operation from typed inputs, calling `ImageDetailService` utilities and invalidating providers.
- Public API
  - Classes:
    - `ImageActions`: `resizeCommit(ref, ...)` computes target sizes, performs resize, persists physical pixels, and notifies via callback.
  - Providers:
    - `imageActionsProvider`
- Key dependencies: `imageDetailServiceProvider`, `imagePhysPixelsProvider`.
- Data flow & state
  - Inputs: Project/image ids, typed values + units, dpi, interpolation.
  - Outputs: Delegated resize + DB persist; invalidates `imagePhysPixelsProvider` and calls provided callback.
  - Providers/Streams watched: Reads `imageDetailServiceProvider`.
- Rendering/Side effects: No UI; orchestrates provider invalidations and callbacks.
- Invariants & caveats: Guard against non-positive target sizes; caller controls `linked` separately.
- Extension points: Add undo/redo; batch operations; error handling.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
