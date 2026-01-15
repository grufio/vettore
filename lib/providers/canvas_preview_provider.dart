import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/project_providers.dart';
import 'package:grufio/services/canvas_image_helpers.dart';

/// Canvas preview size provider (px) derived strictly from project fields.
/// Updates reactively when project dimensions change.
final canvasPreviewPxProvider = Provider.family<Size, int>((ref, projectId) {
  final proj = ref.watch(projectByIdProvider(projectId)).asData?.value;
  if (proj == null) {
    return const Size(100, 100);
  }
  return getCanvasPreviewPx(
    widthValue: proj.canvasWidthValue,
    widthUnit: proj.canvasWidthUnit,
    heightValue: proj.canvasHeightValue,
    heightUnit: proj.canvasHeightUnit,
  );
});
