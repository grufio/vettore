import 'package:flutter/foundation.dart';

@immutable
class GrufioTabData {
  final String iconPath;
  final String? label;
  final double? width;
  final int? projectId; // null for non-project tabs (e.g., Home)

  const GrufioTabData({
    required this.iconPath,
    this.label,
    this.width,
    this.projectId,
  });
}
