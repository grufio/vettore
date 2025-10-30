# grufio_registry.dart

- Path: lib/icons/grufio_registry.dart
- Purpose: Deterministic mapping from stable string IDs to Grufio `IconData`, used across the app for consistency.
- Public API
  - Constants:
    - `grufioById`: `Map<String, IconData>` mapping ids like `home`, `add`, `zoom-in` to `Grufio.*`.
- Key dependencies: `Grufio` icon class.
- Data flow & state
  - Inputs: String ids.
  - Outputs: `IconData` for rendering with `Icon`.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: String ids must match keys present; incomplete coverage defaults handled by callers.
- Extension points: Add more ids as glyphs are added.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
