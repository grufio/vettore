import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show FilterQuality;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/image_providers.dart';
import 'package:grufio/services/image_compute.dart' as ic;
import 'package:grufio/services/logger.dart';
import 'package:path_provider/path_provider.dart';

// ignore_for_file: always_use_package_imports
import '../providers/application_providers.dart';
import '../providers/runtime_settings_provider.dart';

class ImageProcessingService {
  const ImageProcessingService();

  Future<void> quantizeImage(WidgetRef ref, int projectId) async {
    final projectRepository = ref.read(projectRepositoryPgProvider);
    final settings = ref.read(runtimeSettingsProvider);
    final images = ref.read(imageRepositoryPgProvider);
    final project = await projectRepository.getById(projectId);
    if (project.imageId == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/quantize.py';
      final scriptContent = await rootBundle.loadString('scripts/quantize.py');
      await File(scriptPath).writeAsString(scriptContent);

      final inputPath = '${tempDir.path}/temp_in.png';
      final outputPath = '${tempDir.path}/temp_out.png';
      final inputBytes = await images.getBestBytes(project.imageId!);
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
      // Palette result is printed by script; not persisted in PG schema

      final ic.DecodedDimensions decodedDims =
          await compute(ic.decodeDimensions, newImageData);
      if (decodedDims.width == null || decodedDims.height == null) {
        throw Exception('Could not decode the quantized image output.');
      }

      await images.setConverted(project.imageId!, newImageData);
      // Bump project updated_at via dynamic updateFields (no field changes needed)
      await projectRepository.updateFields(projectId);
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
    final projectRepository = ref.read(projectRepositoryPgProvider);
    final images = ref.read(imageRepositoryPgProvider);
    final project = await projectRepository.getById(projectId);
    if (project.imageId == null) return;

    final tempDir = await getTemporaryDirectory();
    final scriptPath = '${tempDir.path}/resize_cv.py';
    final inputPath = '${tempDir.path}/cv_in.png';
    final outputPath = '${tempDir.path}/cv_out.png';

    final scriptContent = await rootBundle.loadString('scripts/resize_cv.py');
    await File(scriptPath).writeAsString(scriptContent);

    final orig = await images.getBestBytes(project.imageId!);
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
    // Dimensions are parsed for verification only (not persisted in PG schema)
    // final dims = jsonDecode(result.stdout as String) as Map<String, dynamic>;

    await images.setConverted(project.imageId!, newImageData);
    await projectRepository.updateFields(projectId);

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
    final projectRepository = ref.read(projectRepositoryPgProvider);
    final images = ref.read(imageRepositoryPgProvider);
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
      final orig = await images.getBestBytes(project.imageId!);
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
      // Dimensions JSON only for debug/verification; not persisted
      // final dimensionsJson = jsonDecode(result.stdout as String);

      await images.setConverted(project.imageId!, newImageData);
      await projectRepository.updateFields(projectId);

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
    final projectRepository = ref.read(projectRepositoryPgProvider);
    final project = await projectRepository.getById(projectId);
    if (project.imageId == null) return;

    // Unique colors not persisted in PG schema; skip counting.
    await projectRepository.updateFields(projectId);
  }
}

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return const ImageProcessingService();
});
