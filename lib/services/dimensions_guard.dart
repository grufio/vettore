import 'package:flutter/widgets.dart';

/// Utility for deciding when to apply image dimensions to controllers
/// and for writing values safely.
class DimensionsGuard {
  /// Returns true when new dimensions should be applied to the UI.
  /// Applies when width/height differ from current, or when not initialized yet.
  static bool shouldApply({
    required int? currentWidth,
    required int? currentHeight,
    required int? newWidth,
    required int? newHeight,
    required bool initialized,
  }) {
    // Apply when not initialized, when current fields are empty,
    // or when the new dimensions differ from what's currently shown.
    if (!initialized) return true;
    if (currentWidth == null || currentHeight == null) return true;
    if (newWidth == null || newHeight == null) return false;
    return currentWidth != newWidth || currentHeight != newHeight;
  }

  /// Writes dimensions into the provided controllers if non-null.
  static void writeControllers({
    required TextEditingController widthController,
    required TextEditingController heightController,
    required int? width,
    required int? height,
  }) {
    if (width != null) {
      widthController.text = width.toString();
    }
    if (height != null) {
      heightController.text = height.toString();
    }
  }
}
