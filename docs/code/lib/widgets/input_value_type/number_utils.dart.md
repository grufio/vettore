# number_utils.dart

- Path: lib/widgets/input_value_type/number_utils.dart
- Purpose: Numeric helpers for input fields: sanitize to digits/one dot, clamp pixel values, and simple px↔unit conversions.
- Public API
  - Functions: `sanitizeNumber`, `clampPx`, `toPx`, `fromPx`.
- Key dependencies: `convertUnit`.
- Data flow & state
  - Inputs: Raw strings and numeric values.
  - Outputs: Sanitized string / converted numbers.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: `sanitizeNumber` permits only one '.'; locale-specific separators not handled.
- Extension points: Locale-aware parsing; min/max validation with messages.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
