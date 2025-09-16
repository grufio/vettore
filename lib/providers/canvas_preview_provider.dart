import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/canvas_image_helpers.dart';

/// Canvas preview size provider (px) derived strictly from project fields.
final canvasPreviewPxProvider =
    FutureProvider.family<Size, int>((ref, projectId) async {
  final proj = await ref.watch(projectByIdProvider(projectId).future);
  if (proj == null) return const Size(100, 100);
  // 96 dpi preview baseline; no coupling with image.
  return getCanvasPreviewPx(
    widthValue: proj.canvasWidthValue,
    widthUnit: proj.canvasWidthUnit,
    heightValue: proj.canvasHeightValue,
    heightUnit: proj.canvasHeightUnit,
    previewDpi: 96,
  );
});
