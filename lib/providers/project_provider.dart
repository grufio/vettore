import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:vettore/models/project_model.dart';
import 'package:vettore/models/vector_object_model.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/repositories/palette_repository.dart';

@immutable
class ProjectState {
  const ProjectState({this.project, this.isLoading = false});
  final Project? project;
  final bool isLoading;

  ProjectState copyWith({Project? project, bool? isLoading}) {
    return ProjectState(
      project: project ?? this.project,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final projectProvider = StateNotifierProvider.autoDispose
    .family<ProjectNotifier, ProjectState, int>((ref, projectKey) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      final projectService = ref.watch(projectServiceProvider);
      final paletteRepository = ref.watch(paletteRepositoryProvider);
      try {
        final project = projectRepository.getProjects().firstWhere(
          (p) => p.key == projectKey,
        );
        return ProjectNotifier(
          ProjectState(project: project),
          projectRepository,
          projectService,
          paletteRepository,
        );
      } catch (e) {
        return ProjectNotifier(
          const ProjectState(),
          projectRepository,
          projectService,
          paletteRepository,
        );
      }
    });

class ProjectNotifier extends StateNotifier<ProjectState> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;
  final PaletteRepository _paletteRepository;

  ProjectNotifier(
    super.projectState,
    this._projectRepository,
    this._projectService,
    this._paletteRepository,
  );

  Future<void> convertProject() async {
    if (state.project == null || state.isLoading) {
      return;
    }

    final isFirstConversion = !state.project!.isConverted;
    state = state.copyWith(isLoading: true);

    try {
      // Pass only the necessary raw data to the isolate.
      final result = await compute(_performConversionIsolate, {
        'imageData': state.project!.imageData,
      });

      Project updatedProject;
      if (isFirstConversion) {
        // Create and save the new global palette
        final newPalette = Palette()
          ..name = '${state.project!.name} Palette'
          ..colors = result['palette'];
        final newPaletteKey = await _paletteRepository.addPalette(newPalette);

        updatedProject = state.project!.copyWith(
          vectorObjects: result['vectorObjects'],
          imageWidth: result['imageWidth'],
          imageHeight: result['imageHeight'],
          isConverted: true,
          uniqueColorCount: result['uniqueColorCount'],
          paletteKey: newPaletteKey,
        );
      } else {
        // On subsequent conversions, just update the vector objects
        updatedProject = state.project!.copyWith(
          vectorObjects: result['vectorObjects'],
          imageWidth: result['imageWidth'],
          imageHeight: result['imageHeight'],
          isConverted: true,
          uniqueColorCount: result['uniqueColorCount'],
        );
      }

      await _projectRepository.updateProject(
        state.project!.key,
        updatedProject,
      );
      state = state.copyWith(project: updatedProject, isLoading: false);
    } catch (e) {
      debugPrint('[ProjectProvider] Error during vector conversion: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateImage(
    double scalePercent,
    FilterQuality filterQuality,
  ) async {
    if (state.project == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await compute(_performImageUpdate, {
        'imageData': state.project!.originalImageData!,
        'scalePercent': scalePercent,
        'filterQuality': filterQuality,
      });

      final updatedProjectData = state.project!.copyWith(
        imageData: result['imageData'],
        imageWidth: result['width'],
        imageHeight: result['height'],
        filterQualityIndex: filterQuality.index,
        isConverted: false,
        vectorObjects: [],
        uniqueColorCount: 0,
      );

      await _projectRepository.updateProject(
        state.project!.key,
        updatedProjectData,
      );
      state = state.copyWith(project: updatedProjectData);
    } catch (e) {
      debugPrint('Error during image update: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetImage() async {
    if (state.project == null || state.isLoading) return;
    final updatedProject = state.project!.copyWith(
      imageData: state.project!.originalImageData,
      imageWidth: state.project!.originalImageWidth,
      imageHeight: state.project!.originalImageHeight,
      filterQualityIndex:
          FilterQuality.high.index, // Default to high quality on reset
      isConverted: false,
      vectorObjects: [],
      uniqueColorCount: 0,
    );
    await _projectRepository.updateProject(state.project!.key, updatedProject);
    state = state.copyWith(project: updatedProject);
  }
}

Map<String, dynamic> _performImageUpdate(Map<String, dynamic> params) {
  final Uint8List imageData = params['imageData'];
  final double scalePercent = params['scalePercent'];
  final FilterQuality filterQuality = params['filterQuality'];

  final originalImage = img.decodeImage(imageData);
  if (originalImage == null) {
    throw Exception('Could not decode image for updating.');
  }

  final newWidth = (originalImage.width * scalePercent / 100).round();
  final newHeight = (originalImage.height * scalePercent / 100).round();

  // Map FilterQuality to the image package's Interpolation enum
  final interpolation = switch (filterQuality) {
    FilterQuality.high => img.Interpolation.cubic,
    FilterQuality.medium => img.Interpolation.linear,
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

// This function will run in a separate isolate.
Map<String, dynamic> _performConversionIsolate(Map<String, dynamic> params) {
  final Uint8List imageData = params['imageData'];
  final img.Image? imageToConvert = img.decodeImage(imageData);

  if (imageToConvert == null) {
    throw Exception('Could not decode image');
  }

  final List<VectorObject> vectorObjects = [];
  final Map<int, int> colorIndexMap = {};
  int nextColorIndex = 1;
  final Set<Color> uniqueColorsSet = {};

  for (int y = 0; y < imageToConvert.height; y++) {
    for (int x = 0; x < imageToConvert.width; x++) {
      final pixel = imageToConvert.getPixel(x, y);
      final flutterColor = Color.fromARGB(
        pixel.a.toInt(),
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );

      uniqueColorsSet.add(flutterColor);

      int colorIndex;
      if (colorIndexMap.containsKey(flutterColor.toARGB32())) {
        colorIndex = colorIndexMap[flutterColor.toARGB32()]!;
      } else {
        colorIndex = nextColorIndex;
        colorIndexMap[flutterColor.toARGB32()] = colorIndex;
        nextColorIndex++;
      }

      vectorObjects.add(
        VectorObject.fromRectAndColor(
          rect: Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          color: flutterColor,
          colorIndex: colorIndex,
        ),
      );
    }
  }

  final uniqueColorList = uniqueColorsSet.toList();
  final List<PaletteColor> newPalette = [];
  for (int i = 0; i < uniqueColorList.length; i++) {
    final color = uniqueColorList[i];
    final hex =
        '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    newPalette.add(PaletteColor(title: hex, color: color.value));
  }

  return {
    'vectorObjects': vectorObjects,
    'imageWidth': imageToConvert.width.toDouble(),
    'imageHeight': imageToConvert.height.toDouble(),
    'uniqueColorCount': uniqueColorsSet.length,
    'palette': newPalette,
  };
}
