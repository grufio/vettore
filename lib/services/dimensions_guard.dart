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
    // Only apply once per image (initialization). Do not overwrite user edits.
    return !initialized;
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
