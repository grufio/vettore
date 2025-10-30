# logger.dart

- Path: lib/services/logger.dart
- Purpose: Thin wrapper around `dart:developer.log` for warning-level logs under the `vettore` logger name.
- Public API
  - Functions:
    - `logWarn(message, [error, stackTrace])`: Logs with level 900 and optional error/stack trace.
- Key dependencies: `dart:developer`.
- Data flow & state
  - Inputs: Message and optional error/stack.
  - Outputs: Log event to developer console.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: No UI; writes to log.
- Invariants & caveats: Level 900 corresponds to warning; consistent logger name `vettore`.
- Extension points: Add info/error helpers; connect to external logging sinks.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
