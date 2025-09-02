import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
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
  final DbProject project;
  final Image? decodedImage;

  const ProjectState({required this.project, this.decodedImage});

  @override
  List<Object?> get props => [project, decodedImage];
}

// Provides a stream of a single project for the editor page.
final projectStreamProvider =
    StreamProvider.autoDispose.family<ProjectState, int>((ref, projectId) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final db = ref.watch(appDatabaseProvider);

  // Return a new stream that transforms the DbProject stream into a ProjectState stream
  return projectRepository
      .watchById(projectId)
      .where((p) => p != null)
      .cast<DbProject>()
      .asyncMap((project) async {
    Image? decodedImage;
    if (project.imageId != null) {
      try {
        final row = await (db.select(db.images)
              ..where((t) => t.id.equals(project.imageId!)))
            .getSingleOrNull();
        final bytes = row?.convSrc ?? row?.origSrc;
        if (bytes != null && bytes.isNotEmpty) {
          final codec = await instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          decodedImage = frame.image;
        }
      } catch (_) {}
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
    final settings = ref.read(settingsServiceProvider);
    final db = ref.read(appDatabaseProvider);
    final project = await projectRepository.getById(projectId);

    if (project.imageId == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/quantize.py';
      final scriptContent = await rootBundle.loadString('scripts/quantize.py');
      await File(scriptPath).writeAsString(scriptContent);

      final inputPath = '${tempDir.path}/temp_in.png';
      final outputPath = '${tempDir.path}/temp_out.png';
      final imageRow = await (db.select(db.images)
            ..where((t) => t.id.equals(project.imageId!)))
          .getSingle();
      final inputBytes = imageRow.convSrc ?? imageRow.origSrc;
      if (inputBytes == null || inputBytes.isEmpty) return;
      await File(inputPath).writeAsBytes(inputBytes);

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

      // Decode the new image to get its dimensions
      final img.Image? decodedQuantizedImage = img.decodeImage(newImageData);
      if (decodedQuantizedImage == null) {
        throw Exception('Could not decode the quantized image output.');
      }

      await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
          .write(ImagesCompanion(
        convSrc: Value(newImageData),
        convBytes: Value(newImageData.length),
        convWidth: Value(decodedQuantizedImage.width),
        convHeight: Value(decodedQuantizedImage.height),
        convUniqueColors: Value(paletteList.length),
      ));
      final now = DateTime.now().millisecondsSinceEpoch;
      await projectRepository.update(
          ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)));
    } catch (e) {
      // Re-throw the exception to be caught by the UI layer if needed.
      rethrow;
    }
  }

  /// Generates the vector grid from the currently converted image data.
  /// This should only be called after `quantizeImage` has been successfully run.
  Future<void> generateGrid() async {
    // Not supported with current schema; no persistent vector storage.
    return;
  }

  Future<void> updateImage(
      double scalePercent, FilterQuality filterQuality) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final project = await projectRepository.getById(projectId);

    if (project.imageId == null) {
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
      final imageRow = await (db.select(db.images)
            ..where((t) => t.id.equals(project.imageId!)))
          .getSingle();
      final orig = imageRow.origSrc;
      if (orig == null || orig.isEmpty) return;
      await inputFile.writeAsBytes(orig);

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

      // Calculate unique colors for info
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

      await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
          .write(ImagesCompanion(
        convSrc: Value(newImageData),
        convBytes: Value(newImageData.length),
        convWidth: Value(newWidth.toInt()),
        convHeight: Value(newHeight.toInt()),
        convUniqueColors: Value(uniqueColorCount),
      ));
      final now = DateTime.now().millisecondsSinceEpoch;
      await projectRepository.update(
          ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetImage() async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final project = await projectRepository.getById(projectId);

    if (project.imageId == null) return;

    int uniqueColorCount = 0;
    final imageRow = await (db.select(db.images)
          ..where((t) => t.id.equals(project.imageId!)))
        .getSingleOrNull();
    final orig = imageRow?.origSrc;
    if (orig != null) {
      final image = img.decodeImage(orig);
      if (image != null) {
        final colors = <int>{};
        for (final p in image) {
          colors.add(img.rgbaToUint32(
              p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt()));
        }
        uniqueColorCount = colors.length;
      }
    }

    await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
        .write(const ImagesCompanion(
      convSrc: Value.absent(),
      convBytes: Value.absent(),
      convWidth: Value.absent(),
      convHeight: Value.absent(),
    ));
    final now = DateTime.now().millisecondsSinceEpoch;
    await projectRepository
        .update(ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)));
  }
}
