import 'package:flutter/foundation.dart';

@immutable
class GrufioTabData {
  // null unless this tab shows a vendor overview

  const GrufioTabData({
    required this.iconId,
    this.label,
    this.width,
    this.projectId,
    this.vendorId,
  });
  // Stable identifier that maps via Grufio.byId
  final String iconId;
  final String? label;
  final double? width;
  final int? projectId; // null for non-project tabs (e.g., Home)
  final int? vendorId;
}
