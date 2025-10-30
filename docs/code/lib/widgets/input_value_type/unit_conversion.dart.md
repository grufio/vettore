# unit_conversion.dart

- Path: lib/widgets/input_value_type/unit_conversion.dart
- Purpose: Unit conversion utilities (typed and string-based) and formatting helpers for display and field text.
- Public API
  - Enums/Extensions:
    - `Unit { px, inch, point, centimeter, millimeter }`, `UnitString.asDbString`
  - Functions:
    - `parseUnit`, `convertUnitTyped`, `convertUnit`, `formatUnitValue`, `formatFieldUnitValue`
- Key dependencies: None beyond Dart.
- Data flow & state
  - Inputs: Values, units, dpi.
  - Outputs: Converted values; formatted strings.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: dpi must be >0; exact metric↔metric shortcuts; general path via inches.
- Extension points: Additional units; locale-aware formatting.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
