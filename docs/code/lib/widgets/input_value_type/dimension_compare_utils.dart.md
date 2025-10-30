# dimension_compare_utils.dart

- Path: lib/widgets/input_value_type/dimension_compare_utils.dart
- Purpose: Text comparison helpers for dimension fields (normalize/parseable checks and baseline comparison).
- Public API
  - Functions: `trimTrailingDot`, `isParsableNumber`, `normalizeComparable`, `differsFromBaseline`.
- Key dependencies: None.
- Data flow & state
  - Inputs: Raw strings.
  - Outputs: Normalized strings/booleans.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: `isParsableNumber` uses `double.tryParse` after trimming final '.'; localization not handled.
- Extension points: Locale-aware parsing.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
