# image_spec_providers.dart

- Path: lib/providers/image_spec_providers.dart
- Purpose: Holds user-selected units for image width/height per project, sourced from `SettingsService` defaults.
- Public API
  - Providers:
    - `imageWidthUnitProvider(projectId)`: `StateProvider.family<String, int>`
    - `imageHeightUnitProvider(projectId)`: `StateProvider.family<String, int>`
- Key dependencies: `settingsServiceProvider`.
- Data flow & state
  - Inputs: Project id; reads settings for default unit.
  - Outputs: Unit strings; can be updated by UI callers.
  - Providers/Streams watched: Reads `settingsServiceProvider`.
- Rendering/Side effects: None.
- Invariants & caveats: Defaults to `imageDefaultUnit` from settings; persistence of changes left to caller.
- Extension points: Persist unit changes per project; add separate defaults.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
