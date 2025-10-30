# project_repository.dart

- Path: lib/repositories/project_repository.dart
- Purpose: CRUD and stream accessors for `projects` using Drift, plus helpers to insert a draft and run actions in a transaction.
- Public API
  - Classes:
    - `ProjectRepository(AppDatabase)`: methods `watchAll`, `getAll`, `watchById`, `getById`, `insert`, `insertDraft(...)`, `update`, `delete`, `runInTransaction`.
- Key dependencies: `AppDatabase`, `ProjectsCompanion`, Drift query builders (`select`, `update`, `delete`, `into`).
- Data flow & state
  - Inputs: Query parameters and companion objects.
  - Outputs: DB reads/writes and streams (`watch*`).
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No UI; DB operations only.
- Invariants & caveats: `insertDraft` seeds sensible defaults for canvas/grid fields and timestamps; `update` targets row by id from companion.
- Extension points: Add search/sorting; pagination; soft-delete/archive.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
