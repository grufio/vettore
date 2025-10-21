import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show FilterQuality;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/services/logger.dart';
import 'package:vettore/services/settings_service.dart';

class ImageProcessingService {
  const ImageProcessingService();

  Future<void> quantizeImage(WidgetRef ref, int projectId) async {
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

      final ic.DecodedDimensions decodedDims =
          await compute(ic.decodeDimensions, newImageData);
      if (decodedDims.width == null || decodedDims.height == null) {
        throw Exception('Could not decode the quantized image output.');
      }

      await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
          .write(ImagesCompanion(
        convSrc: Value(newImageData),
        convBytes: Value(newImageData.length),
        convWidth: Value(decodedDims.width),
        convHeight: Value(decodedDims.height),
        convUniqueColors: Value(paletteList.length),
      ));
      final now = DateTime.now().millisecondsSinceEpoch;
      await projectRepository.update(
        ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)),
      );
      // Invalidate derived bytes
      ref.invalidate(imageBytesProvider(project.imageId!));
    } catch (e, st) {
      logWarn('quantizeImage failed for project $projectId', e, st);
      rethrow;
    }
  }

  Future<void> resizeToCv(
    WidgetRef ref, {
    required int projectId,
    required int targetW,
    required int targetH,
    required String interpolationName,
  }) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final project = await projectRepository.getById(projectId);
    if (project.imageId == null) return;

    final tempDir = await getTemporaryDirectory();
    final scriptPath = '${tempDir.path}/resize_cv.py';
    final inputPath = '${tempDir.path}/cv_in.png';
    final outputPath = '${tempDir.path}/cv_out.png';

    final scriptContent = await rootBundle.loadString('scripts/resize_cv.py');
    await File(scriptPath).writeAsString(scriptContent);

    final imageRow = await (db.select(db.images)
          ..where((t) => t.id.equals(project.imageId!)))
        .getSingle();
    final orig = imageRow.origSrc;
    if (orig == null || orig.isEmpty) return;
    await File(inputPath).writeAsBytes(orig);

    final result = await Process.run('python3', [
      scriptPath,
      inputPath,
      outputPath,
      targetW.toString(),
      targetH.toString(),
      interpolationName,
    ]);
    if (result.exitCode != 0) {
      throw Exception('OpenCV resize failed: ${result.stderr}');
    }

    final newImageData = await File(outputPath).readAsBytes();
    final dims = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final newW = dims['width'] as int;
    final newH = dims['height'] as int;

    final ic.UniqueColorsResult uc2 =
        await compute(ic.decodeUniqueColors, newImageData);
    final int uniqueColorCount = uc2.count;

    await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
        .write(ImagesCompanion(
      convSrc: Value(newImageData),
      convBytes: Value(newImageData.length),
      convWidth: Value(newW),
      convHeight: Value(newH),
      convUniqueColors: Value(uniqueColorCount),
    ));

    final now = DateTime.now().millisecondsSinceEpoch;
    await projectRepository.update(
      ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)),
    );

    if (project.imageId != null) {
      ref.invalidate(imageBytesProvider(project.imageId!));
    }

    try {
      await File(scriptPath).delete();
      await File(inputPath).delete();
      await File(outputPath).delete();
    } catch (e, st) {
      logWarn('cleanup temp files failed in resizeToCv for $projectId', e, st);
    }
  }

  Future<void> updateImage(
    WidgetRef ref, {
    required int projectId,
    required double scalePercent,
    required FilterQuality filterQuality,
  }) async {
    final projectRepository = ref.read(projectRepositoryProvider);
    final db = ref.read(appDatabaseProvider);
    final project = await projectRepository.getById(projectId);
    if (project.imageId == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/resize.py';
      final scriptContent = await rootBundle.loadString('scripts/resize.py');
      final scriptFile = File(scriptPath);
      await scriptFile.writeAsString(scriptContent);

      final inputPath = '${tempDir.path}/resize_in.png';
      final inputFile = File(inputPath);
      final imageRow = await (db.select(db.images)
            ..where((t) => t.id.equals(project.imageId!)))
          .getSingle();
      final orig = imageRow.origSrc;
      if (orig == null || orig.isEmpty) return;
      await inputFile.writeAsBytes(orig);

      final outputPath = '${tempDir.path}/resize_out.png';
      final interpolation =
          filterQuality == FilterQuality.high ? 'cubic' : 'nearest';

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

      final newImageData = await File(outputPath).readAsBytes();
      final dimensionsJson = jsonDecode(result.stdout as String);
      final newWidth = (dimensionsJson['width'] as int).toDouble();
      final newHeight = (dimensionsJson['height'] as int).toDouble();

      final ic.UniqueColorsResult uc =
          await compute(ic.decodeUniqueColors, newImageData);
      final int uniqueColorCount = uc.count;

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

      if (project.imageId != null) {
        ref.invalidate(imageBytesProvider(project.imageId!));
      }

      await scriptFile.delete();
      await inputFile.delete();
      await File(outputPath).delete();
    } catch (e, st) {
      logWarn('updateImage failed for project $projectId', e, st);
      rethrow;
    }
  }

  Future<void> resetImage(WidgetRef ref, int projectId) async {
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
      final ic.UniqueColorsResult uc3 =
          await compute(ic.decodeUniqueColors, orig);
      uniqueColorCount = uc3.count;
    }

    await (db.update(db.images)..where((t) => t.id.equals(project.imageId!)))
        .write(ImagesCompanion(
      convUniqueColors: Value(uniqueColorCount),
    ));
    final now = DateTime.now().millisecondsSinceEpoch;
    await projectRepository
        .update(ProjectsCompanion(id: Value(projectId), updatedAt: Value(now)));
  }
}

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return const ImageProcessingService();
});
