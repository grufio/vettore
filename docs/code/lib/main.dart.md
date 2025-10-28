# main.dart

- Path: lib/main.dart
- Purpose: Application entry point. Initializes Flutter and platform windowing (macOS), sets up database and settings, runs one-time background initialization, and boots the app using `WidgetsApp.router` with `appRouter`.
- Public API
  - Classes/Widgets (exported):
    - `MyApp`: Root widget that returns `WidgetsApp.router` configured with `appRouter` and base color `kWhite`.
  - Functions (exported):
    - `main()`: Top-level async entry; performs setup and calls `runApp`.
- Key dependencies: `bitsdojo_window`, `window_manager` (macOS window), `flutter_riverpod` (`ProviderScope`), `AppDatabase`, `SettingsService`, `InitService`, `appRouter`, `kWhite`.
- Data flow & state
  - Inputs: None
  - Outputs: Provider overrides for `settingsServiceProvider`, `appDatabaseProvider`; schedules `InitService.run()`.
  - Providers/Streams watched: None (only overrides are provided).
- Rendering/Side effects: Creates DB and settings; kicks off background init (`unawaited`); on macOS sets min window size, centers, and shows window before first frame.
- Invariants & caveats: Window setup is macOS-only; background init is non-blocking; `SettingsService.init()` awaited prior to UI to ensure persistence is available.
- Extension points: Add global error handling/observers; inject more providers; platform-specific window customizations.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
