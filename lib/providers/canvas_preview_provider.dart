import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/canvas_image_helpers.dart';

/// Canvas preview size provider (px) derived strictly from project fields.
/// Stream-based so updates reactively when project dimensions change.
final canvasPreviewPxProvider =
    StreamProvider.family<Size, int>((ref, projectId) {
  return ref.watch(projectByIdProvider(projectId).stream).map((proj) {
    if (proj == null) return const Size(100, 100);
    // 96 dpi preview baseline; no coupling with image.
    return getCanvasPreviewPx(
      widthValue: proj.canvasWidthValue,
      widthUnit: proj.canvasWidthUnit,
      heightValue: proj.canvasHeightValue,
      heightUnit: proj.canvasHeightUnit,
    );
  });
});
