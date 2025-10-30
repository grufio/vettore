# grufio_tab_data.dart

- Path: lib/models/grufio_tab_data.dart
- Purpose: Immutable data model representing a header tab (icon id, optional label/width, and optional project/vendor ids for routing/context).
- Public API
  - Classes:
    - `GrufioTabData(iconId, {label, width, projectId, vendorId})`
- Key dependencies: `meta` `@immutable`.
- Data flow & state
  - Inputs: Constructed by callers; used by header/tabs and routing.
  - Outputs: Pure data object.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: None.
- Invariants & caveats: `iconId` maps via `grufioById` registry; `projectId` null for non-project tabs; width is an optional UI hint.
- Extension points: Add more context fields if tabs grow features.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
