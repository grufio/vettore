# settings_service.dart

- Path: lib/services/settings_service.dart
- Purpose: Centralized app settings service backed by the Drift `settings` table, with an in-memory cache and typed getters/setters. Also defines a provider override hook used at app startup.
- Public API
  - Providers:
    - `settingsServiceProvider`: must be overridden with an initialized `SettingsService` instance.
  - Classes:
    - `SettingsService`: `ChangeNotifier` exposing typed getters/setters for primitives and many domain-specific keys (PDF/output/page/unit and Gemini API settings). Methods: `init`, `getInt`, `setInt`, `getStringOrNull`, `setString`, and typed accessors.
- Key dependencies: `flutter_riverpod` (provider), `AppDatabase` (Drift), `SettingsCompanion`.
- Data flow & state
  - Inputs: Calls from UI/services to read/write settings.
  - Outputs: DB writes via `insertOnConflictUpdate`; notifies listeners after writes; memoizes to `_cache`.
  - Providers/Streams watched: None; created and overridden by the app.
- Rendering/Side effects: No UI; writes to DB and notifies listeners.
- Invariants & caveats: `init()` must be awaited before use; values are stored as strings in DB and parsed to requested types; unknown types default to provided fallback; booleans parsed from string equality with `true`.
- Extension points: Add additional typed keys; migrate to stronger schema if needed; add batching.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
