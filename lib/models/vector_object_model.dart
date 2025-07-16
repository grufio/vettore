import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'vector_object_model.g.dart';

@HiveType(typeId: 3)
class VectorObject {
  @HiveField(0)
  final double left;

  @HiveField(1)
  final double top;

  @HiveField(2)
  final double width;

  @HiveField(3)
  final double height;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final int colorIndex;

  // Constructor for Hive
  VectorObject({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.colorValue,
    required this.colorIndex,
  });

  // Factory for convenience when creating from Rect and Color
  factory VectorObject.fromRectAndColor({
    required Rect rect,
    required Color color,
    required int colorIndex,
  }) {
    return VectorObject(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      colorValue: color.toARGB32(),
      colorIndex: colorIndex,
    );
  }

  Rect get rect => Rect.fromLTWH(left, top, width, height);
  Color get color => Color(colorValue);

  int findClosestColor(List<Color> palette) {
    if (palette.isEmpty) return -1;

    int minDistance = 1000000;
    Color closestColor = palette.first;

    for (final pColor in palette) {
      final distance =
          (pColor.red - color.red).abs() +
          (pColor.green - color.green).abs() +
          (pColor.blue - color.blue).abs();

      if (distance < minDistance) {
        minDistance = distance;
        closestColor = pColor;
      }
    }
    return palette.indexOf(closestColor);
  }
}
