import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
    int paletteId = project.paletteId ?? -1;

    try {
      // Step 1 of the new workflow: Handle legacy projects without a palette.
      if (project.paletteId == null) {
        final newPalette = PalettesCompanion.insert(
          name: '${project.name} Palette',
          thumbnail: Value(project.thumbnailData),
        );
        paletteId = await paletteRepository.addPalette(newPalette, []);
      }

      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/quantize.py';
      final scriptContent = await rootBundle.loadString('scripts/quantize.py');
      final scriptFile = File(scriptPath);
      await scriptFile.writeAsString(scriptContent);

      final inputPath = '${tempDir.path}/temp_in.png';
      final outputPath = '${tempDir.path}/temp_out.png';
      final inputFile = File(inputPath);
      await inputFile.writeAsBytes(project.imageData);

      final result = await Process.run('python3', [
        scriptPath,
        inputPath,
        outputPath,
        settings.maxObjectColors.toString(),
        settings.colorSeparation.toString(),
        settings.kl.toString(),
        settings.kc.toString(),
        settings.kh.toString(),
      ]);

      if (result.exitCode != 0) {
        throw Exception('Python script failed: ${result.stderr}');
      }

      final newImageData = await File(outputPath).readAsBytes();
      final paletteJson = result.stdout as String;
      final paletteList =
          (jsonDecode(paletteJson) as List).map((c) => c as List).toList();

      await scriptFile.delete();
      await inputFile.delete();
      await File(outputPath).delete();

      final resultData = await compute(_performPostProcessingIsolate, {
        'imageData': newImageData,
        'palette': paletteList,
      });

      final vectorObjects =
          resultData['vectorObjects'] as List<IsolateVectorObject>;
      final vectorObjectsJson = jsonEncode(vectorObjects);

      // Step 2 & 3 of the new workflow: Update the existing palette with the new colors.
      final newColors = (resultData['palette'] as List<Map<String, dynamic>>)
          .map((c) => PaletteColorsCompanion.insert(
                title: c['title']!,
                color: c['color']!,
                paletteId: paletteId, // Link to the existing palette
              ))
          .toList();

      await paletteRepository.updatePaletteColors(paletteId, newColors);

      // Update the project with the new conversion data
      final updatedProject = project.toCompanion(false).copyWith(
            imageData: Value(newImageData),
            vectorObjects: Value(vectorObjectsJson),
            imageWidth: Value(resultData['imageWidth']),
            imageHeight: Value(resultData['imageHeight']),
            isConverted: const Value(true),
            uniqueColorCount: Value(resultData['uniqueColorCount']),
            paletteId: Value(paletteId),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      debugPrint('[ProjectLogic] Error during vector conversion: $e');
    }
  }

  Future<void> updateImage(
      double scalePercent, FilterQuality filterQuality) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    if (project.originalImageData == null) {
      debugPrint('[ProjectLogic] Error: Original image data is null.');
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();

      // 1. Write the script from assets to a temp file
      final scriptPath = '${tempDir.path}/resize.py';
      final scriptContent = await rootBundle.loadString('scripts/resize.py');
      final scriptFile = File(scriptPath);
      await scriptFile.writeAsString(scriptContent);

      // 2. Write the original image to a temp input file
      final inputPath = '${tempDir.path}/resize_in.png';
      final inputFile = File(inputPath);
      await inputFile.writeAsBytes(project.originalImageData!);

      // 3. Define the output path
      final outputPath = '${tempDir.path}/resize_out.png';

      // 4. Determine interpolation
      final interpolation =
          filterQuality == FilterQuality.high ? 'cubic' : 'nearest';

      // 5. Execute the script
      final result = await Process.run('python3', [
        scriptPath,
        inputPath,
        outputPath,
        scalePercent.toString(),
        interpolation,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Python resize script failed: ${result.stderr}');
      }

      // 6. Read the results
      final newImageData = await File(outputPath).readAsBytes();
      final dimensionsJson = jsonDecode(result.stdout as String);
      final newWidth = (dimensionsJson['width'] as int).toDouble();
      final newHeight = (dimensionsJson['height'] as int).toDouble();

      // 7. Clean up temp files
      await scriptFile.delete();
      await inputFile.delete();
      await File(outputPath).delete();

      // This part remains similar: calculate unique colors and update the DB
      int uniqueColorCount = 0;
      final image = img.decodeImage(newImageData);
      if (image != null) {
        final colors = <int>{};
        for (final p in image) {
          colors.add(img.rgbaToUint32(
              p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt()));
        }
        uniqueColorCount = colors.length;
      }

      final updatedProject = project.toCompanion(false).copyWith(
            imageData: Value(newImageData),
            imageWidth: Value(newWidth),
            imageHeight: Value(newHeight),
            filterQualityIndex: Value(filterQuality.index),
            isConverted: const Value(false),
            vectorObjects: const Value('[]'), // Reset conversion data
            uniqueColorCount: Value(uniqueColorCount),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      debugPrint('[ProjectLogic] Error during image update: $e');
    }
  }

  Future<void> resetImage() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final paletteRepository = ref.read(paletteRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    // If the project has an associated palette, delete it.
    if (project.paletteId != null) {
      await paletteRepository.deletePalette(project.paletteId!);
    }

    int uniqueColorCount = 0;
    if (project.originalImageData != null) {
      final image = img.decodeImage(project.originalImageData!);
      if (image != null) {
        final colors = <int>{};
        for (final p in image) {
          colors.add(img.rgbaToUint32(
              p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt()));
        }
        uniqueColorCount = colors.length;
      }
    }

    final updatedProject = project.toCompanion(false).copyWith(
          imageData: Value(project.originalImageData!),
          imageWidth: Value(project.originalImageWidth!),
          imageHeight: Value(project.originalImageHeight!),
          filterQualityIndex: const Value(1), // Default high quality
          isConverted: const Value(false),
          vectorObjects: const Value('[]'),
          uniqueColorCount: Value(uniqueColorCount),
          paletteId: const Value(null),
        );
    await projectRepository.updateProject(updatedProject);
  }
}

// --- ISOLATE FUNCTIONS ---

Map<String, dynamic> _performPostProcessingIsolate(
    Map<String, dynamic> params) {
  final Uint8List imageData = params['imageData'];
  final List<List<dynamic>> paletteList = params['palette'];

  final img.Image? imageToConvert = img.decodeImage(imageData);

  if (imageToConvert == null) {
    throw Exception('Could not decode image');
  }

  // Create a map for quick color lookup
  final paletteMap = <int, int>{};
  for (int i = 0; i < paletteList.length; i++) {
    final color = paletteList[i];
    final r = color[0] as int;
    final g = color[1] as int;
    final b = color[2] as int;
    final c = Color.fromARGB(255, r, g, b);
    paletteMap[c.value] = i;
  }

  final List<IsolateVectorObject> vectorObjects = [];
  for (final p in imageToConvert) {
    final c =
        Color.fromARGB(p.a.toInt(), p.r.toInt(), p.g.toInt(), p.b.toInt());
    vectorObjects.add(IsolateVectorObject(p.x, p.y, c.value));
  }

  final List<Map<String, dynamic>> newPalette = [];
  for (final color in paletteList) {
    final r = color[0] as int;
    final g = color[1] as int;
    final b = color[2] as int;
    final c = Color.fromARGB(255, r, g, b);
    final hex =
        '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    newPalette.add({'title': hex, 'color': c.value});
  }

  return {
    'vectorObjects': vectorObjects,
    'imageWidth': imageToConvert.width.toDouble(),
    'imageHeight': imageToConvert.height.toDouble(),
    'uniqueColorCount': paletteList.length,
    'palette': newPalette,
  };
}
