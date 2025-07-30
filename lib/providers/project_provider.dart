import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
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

// A state class to hold the project data and its decoded image.
class ProjectState extends Equatable {
  final Project project;
  final Image? decodedImage;

  const ProjectState({required this.project, this.decodedImage});

  @override
  List<Object?> get props => [project, decodedImage];
}

// Provides a stream of a single project for the editor page.
final projectStreamProvider =
    StreamProvider.autoDispose.family<ProjectState, int>((ref, projectId) {
  final projectRepository = ref.watch(projectRepositoryProvider);

  // Return a new stream that transforms the Project stream into a ProjectState stream
  return projectRepository.watchProject(projectId).asyncMap((project) async {
    Image? decodedImage;
    if (project.imageData.isNotEmpty) {
      try {
        final codec = await instantiateImageCodec(project.imageData);
        final frame = await codec.getNextFrame();
        decodedImage = frame.image;
      } catch (e) {
        // The stream will continue, but with a null image.
      }
    }
    return ProjectState(project: project, decodedImage: decodedImage);
  });
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

  /// Runs the Python script to perform color quantization on the project's current image.
  /// This updates the project's image data, palette, and color count, but does not
  /// generate the vector grid.
  Future<void> quantizeImage() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final paletteRepository = ref.read(paletteRepositoryProvider);
    final settings = ref.read(settingsServiceProvider);
    final project = await projectRepository.getProject(projectId);
    int paletteId = project.paletteId ?? -1;

    try {
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
      await File(scriptPath).writeAsString(scriptContent);

      final inputPath = '${tempDir.path}/temp_in.png';
      final outputPath = '${tempDir.path}/temp_out.png';
      // Use the resized image data if available, otherwise fall back to the main image data.
      await File(inputPath)
          .writeAsBytes(project.resizedImageData ?? project.imageData);

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

      await Future.wait([
        File(scriptPath).delete(),
        File(inputPath).delete(),
        File(outputPath).delete()
      ]);

      final newColors = paletteList.map((color) {
        final r = color[0] as int;
        final g = color[1] as int;
        final b = color[2] as int;
        final c = Color.fromARGB(255, r, g, b);
        final hex =
            '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
        return PaletteColorsCompanion.insert(
          title: hex,
          color: c.value,
          paletteId: paletteId,
        );
      }).toList();

      await paletteRepository.updatePaletteColors(paletteId, newColors);

      // Decode the new image to get its actual dimensions
      final img.Image? decodedQuantizedImage = img.decodeImage(newImageData);
      if (decodedQuantizedImage == null) {
        throw Exception('Could not decode the quantized image output.');
      }

      final updatedProject = project.toCompanion(false).copyWith(
            imageData: Value(newImageData),
            resizedImageData:
                Value(newImageData), // Ensure the cache is updated
            imageWidth: Value(decodedQuantizedImage.width.toDouble()),
            imageHeight: Value(decodedQuantizedImage.height.toDouble()),
            isConverted:
                const Value(true), // Mark as converted for the grid step
            vectorObjects: const Value('[]'), // Clear old grid data
            uniqueColorCount: Value(paletteList.length),
            paletteId: Value(paletteId),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      // Re-throw the exception to be caught by the UI layer if needed.
      rethrow;
    }
  }

  /// Generates the vector grid from the currently converted image data.
  /// This should only be called after `quantizeImage` has been successfully run.
  Future<void> generateGrid() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    if (!project.isConverted) {
      return;
    }

    try {
      final img.Image? imageToConvert = img.decodeImage(project.imageData);
      if (imageToConvert == null) {
        throw Exception('Could not decode converted image.');
      }

      final List<IsolateVectorObject> vectorObjects = [];
      for (final p in imageToConvert) {
        final c =
            Color.fromARGB(p.a.toInt(), p.r.toInt(), p.g.toInt(), p.b.toInt());
        vectorObjects.add(IsolateVectorObject(p.x, p.y, c.value));
      }
      final vectorObjectsJson = jsonEncode(vectorObjects);

      final updatedProject = project.toCompanion(false).copyWith(
            vectorObjects: Value(vectorObjectsJson),
            imageWidth: Value(imageToConvert.width.toDouble()),
            imageHeight: Value(imageToConvert.height.toDouble()),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateImage(
      double scalePercent, FilterQuality filterQuality) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final project = await projectRepository.getProject(projectId);

    if (project.originalImageData == null) {
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
            resizedImageData: Value(newImageData),
            imageWidth: Value(newWidth),
            imageHeight: Value(newHeight),
            filterQualityIndex: Value(filterQuality.index),
            isConverted: const Value(false),
            vectorObjects: const Value('[]'),
            uniqueColorCount: Value(uniqueColorCount),
          );
      await projectRepository.updateProject(updatedProject);
    } catch (e) {
      rethrow;
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
          resizedImageData: Value(project.originalImageData!),
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
