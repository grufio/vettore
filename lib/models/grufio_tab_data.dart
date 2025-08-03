import 'package:flutter/foundation.dart';

@immutable
class GrufioTabData {
  final String iconPath;
  final String? label;
  final double? width;

  const GrufioTabData({
    required this.iconPath,
    this.label,
    this.width,
  });
}
