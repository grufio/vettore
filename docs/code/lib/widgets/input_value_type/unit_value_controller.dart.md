# unit_value_controller.dart

- Path: lib/widgets/input_value_type/unit_value_controller.dart
- Purpose: Controller storing a base pixel value with unit/DPI, providing conversions, user-typed echo stabilization, and optional linking to a partner controller via aspect ratio.
- Public API
  - Classes:
    - `UnitValueController({valuePx, unit='px', dpi=96})` with getters and methods: `setDpi`, `setUnit`, `setValueFromUnit`, `setValuePx`, `getValueInUnit`, `getDisplayValueInUnit`, `linkWith`, `setLinked`, `setAspect`.
- Key dependencies: `unit_conversion.convertUnit`.
- Data flow & state
  - Inputs: Unit/DPI/value changes; optional partner link.
  - Outputs: `notifyListeners()` on changes; propagates to partner when linked.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None; pure controller.
- Invariants & caveats: Echo logic avoids flip-flop rounding; linking uses partner/this aspect; dpi must be >0.
- Extension points: Persist state; validation hooks; two-way link setup helpers.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
