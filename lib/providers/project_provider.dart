import 'dart:ui';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:image/image.dart' as img;
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/services/settings_service.dart';

// A simple data class for vector objects that can be sent to isolates.
class IsolateVectorObject {
  final int x, y;
  final int color;
  IsolateVectorObject(this.x, this.y, this.color);

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'color': color};
}

// Provides a stream of a single project for the editor page.
final projectStreamProvider =
    StreamProvider.autoDispose.family<Project, int>((ref, projectId) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return projectRepository.watchProject(projectId);
});

// A provider for the business logic of the project editor.
final projectLogicProvider =
    Provider.autoDispose.family<ProjectLogic, int>((ref, projectId) {
  return ProjectLogic(ref, projectId);
});

class ProjectLogic {
  final Ref ref;
  final int projectId;

  ProjectLogic(this.ref, this.projectId);

  Future<void> convertProject() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final paletteRepository = ref.read(paletteRepositoryProvider);
    final settings = ref.read(settingsServiceProvider);
    final project = await projectRepository.getProject(projectId);

    final isFirstConversion = !project.isConverted;

    try {
      final result = await compute(_performConversionIsolate, {
        'imageData': project.imageData,
        'numberOfColors': settings.maxObjectColors,
      });

      final vectorObjects =
          result['vectorObjects'] as List<IsolateVectorObject>;
      final vectorObjectsJson = jsonEncode(vectorObjects);

      if (isFirstConversion) {
        final newPalette = PalettesCompanion.insert(
          name: '${project.name} Palette',
          thumbnail: Value(project.thumbnailData),
        );
        final colors = (result['palette'] as List<Map<String, dynamic>>)
            .map((c) => PaletteColorsCompanion.insert(
                  title: c['title']!,
                  color: c['color']!,
                  paletteId: -1, // This will be set later
                ))
            .toList();

        final newPaletteKey =
            await paletteRepository.addPalette(newPalette, colors);

        final updatedProject = project.toCompanion(false).copyWith(
              vectorObjects: Value(vectorObjectsJson),
              imageWidth: Value(result['imageWidth']),
              imageHeight: Value(result['imageHeight']),
              isConverted: const Value(true),
              uniqueColorCount: Value(result['uniqueColorCount']),
              paletteId: Value(newPaletteKey),
            );
        await projectRepository.updateProject(updatedProject);
      } else {
        final updatedProject = project.toCompanion(false).copyWith(
              vectorObjects: Value(vectorObjectsJson),
              imageWidth: Value(result['imageWidth']),
              imageHeight: Value(result['imageHeight']),
              isConverted: const Value(true),
              uniqueColorCount: Value(result['uniqueColorCount']),
            );
        await projectRepository.updateProject(updatedProject);
      }
    } catch (e) {
      debugPrint('[ProjectLogic] Error during vector conversion: $e');
    }
  }

  Future<void> updateImage(
      double scalePercent, FilterQuality filterQuality) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    try {
      final result = await compute(_performImageUpdate, {
        'imageData': project.originalImageData!,
        'scalePercent': scalePercent,
        'filterQuality': filterQuality,
      });

      final updatedProject = project.toCompanion(false).copyWith(
            imageData: Value(result['imageData'] as Uint8List),
            imageWidth: Value(result['width'] as double),
            imageHeight: Value(result['height'] as double),
            filterQualityIndex: Value(filterQuality.index),
            isConverted: const Value(false),
            vectorObjects: const Value('[]'), // Reset conversion data
            uniqueColorCount: const Value(0),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      debugPrint('[ProjectLogic] Error during image update: $e');
    }
  }

  Future<void> resetImage() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    final updatedProject = project.toCompanion(false).copyWith(
          imageData: Value(project.originalImageData!),
          imageWidth: Value(project.originalImageWidth!),
          imageHeight: Value(project.originalImageHeight!),
          filterQualityIndex: const Value(1), // Default high quality
          isConverted: const Value(false),
          vectorObjects: const Value('[]'),
          uniqueColorCount: const Value(0),
        );
    await projectRepository.updateProject(updatedProject);
  }
}

// --- ISOLATE FUNCTIONS ---

Map<String, dynamic> _performImageUpdate(Map<String, dynamic> params) {
  final Uint8List imageData = params['imageData'];
  final double scalePercent = params['scalePercent'];
  final FilterQuality filterQuality = params['filterQuality'];

  final originalImage = img.decodeImage(imageData);
  if (originalImage == null) throw Exception('Could not decode image.');

  final newWidth = (originalImage.width * scalePercent / 100).round();
  final newHeight = (originalImage.height * scalePercent / 100).round();

  final interpolation = switch (filterQuality) {
    FilterQuality.high => img.Interpolation.cubic,
    _ => img.Interpolation.nearest,
  };

  final resizedImage = img.copyResize(
    originalImage,
    width: newWidth > 0 ? newWidth : 1,
    height: newHeight > 0 ? newHeight : 1,
    interpolation: interpolation,
  );

  return {
    'imageData': Uint8List.fromList(img.encodePng(resizedImage)),
    'width': resizedImage.width.toDouble(),
    'height': resizedImage.height.toDouble(),
  };
}

Map<String, dynamic> _performConversionIsolate(Map<String, dynamic> params) {
  try {
    final Uint8List imageData = params['imageData'];
    final int numberOfColors = params['numberOfColors'];
    final img.Image? imageToConvert = img.decodeImage(imageData);

    if (imageToConvert == null) {
      throw Exception('Could not decode image');
    }

    // quantize function returns a new image that is indexed and has a palette.
    final quantizedImage = img.quantize(imageToConvert,
        numberOfColors: numberOfColors, method: img.QuantizeMethod.octree);

    final palette = quantizedImage.palette;
    if (palette == null) {
      throw Exception('Quantization failed to produce a palette.');
    }

    final List<IsolateVectorObject> vectorObjects = [];
    for (final p in quantizedImage) {
      final index = p.index.toInt();
      final r = palette.getRed(index).toInt();
      final g = palette.getGreen(index).toInt();
      final b = palette.getBlue(index).toInt();
      final a = palette.getAlpha(index).toInt();
      final c = Color.fromARGB(a, r, g, b);
      vectorObjects.add(IsolateVectorObject(p.x, p.y, c.value));
    }

    final List<Map<String, dynamic>> newPalette = [];
    for (int i = 0; i < palette.numColors; i++) {
      final r = palette.getRed(i).toInt();
      final g = palette.getGreen(i).toInt();
      final b = palette.getBlue(i).toInt();
      final a = palette.getAlpha(i).toInt();
      final c = Color.fromARGB(a, r, g, b);
      final hex =
          '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
      newPalette.add({'title': hex, 'color': c.value});
    }

    return {
      'vectorObjects': vectorObjects,
      'imageWidth': quantizedImage.width.toDouble(),
      'imageHeight': quantizedImage.height.toDouble(),
      'uniqueColorCount': palette.numColors,
      'palette': newPalette,
    };
  } catch (e) {
    debugPrint('[ProjectLogic] Error during vector conversion: $e');
    rethrow;
  }
}
