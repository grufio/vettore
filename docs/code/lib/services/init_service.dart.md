# init_service.dart

- Path: lib/services/init_service.dart
- Purpose: Runs one-time background initialization tasks on app startup, guarded by flags persisted in `SettingsService`.
- Public API
  - Classes:
    - `InitService`: `run()` executes idempotent tasks: importing LEGO colors from CSV assets and cleaning vendor rows.
- Key dependencies: `AppDatabase` (customStatement), `SettingsService` (`getInt`/`setInt`), `LegoColorsImporter`.
- Data flow & state
  - Inputs: None (invoked by app startup).
  - Outputs: Writes to DB (vendor cleanup) and to `settings` flags marking tasks as done.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No UI; side effects include DB writes and asset-driven import.
- Invariants & caveats: Tasks are retried if they fail (flags only set on success); keys: `init.lego_import_done`, `init.vendor_cleanup_done`.
- Extension points: Add more startup tasks; expose granular execution/logging.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
