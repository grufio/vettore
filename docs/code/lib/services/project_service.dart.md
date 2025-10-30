# project_service.dart

- Path: lib/services/project_service.dart
- Purpose: Service wrapper around `ProjectRepository` offering convenience operations for creating drafts and batching field updates in a single transaction/write.
- Public API
  - Classes:
    - `ProjectService`: Methods `createDraft(title, author?)` and `batchUpdate(...)` to set multiple fields at once.
- Key dependencies: `ProjectRepository`, `AppDatabase` models (`ProjectsCompanion`), `drift.Value`.
- Data flow & state
  - Inputs: Project update fields and `projectId`.
  - Outputs: Repository calls that mutate the projects table; updates `updatedAt` to now.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No UI; DB updates executed inside `runInTransaction` to batch writes.
- Invariants & caveats: Homegrown batching via optional params; absent fields are skipped using `drift.Value.absent()`; caller responsible for validations.
- Extension points: Additional high-level operations (duplicate, archive); validation layers; error handling/logging strategy.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
