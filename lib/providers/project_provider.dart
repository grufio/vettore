import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:vettore/main.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:flutter/material.dart';

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
      try {
        final project = projectRepository.getProjects().firstWhere(
          (p) => p.key == projectKey,
        );
        return ProjectNotifier(
          ProjectState(project: project),
          projectRepository,
          projectService,
        );
      } catch (e) {
        return ProjectNotifier(
          const ProjectState(),
          projectRepository,
          projectService,
        );
      }
    });

class ProjectNotifier extends StateNotifier<ProjectState> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;

  ProjectNotifier(
    super.projectState,
    this._projectRepository,
    this._projectService,
  );

  Future<void> convertProject() async {
    if (state.project == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedProject = await _projectService.performVectorConversion(
        state.project!,
      );
      _projectRepository.updateProject(state.project!.key, updatedProject);
      state = state.copyWith(project: updatedProject);
    } catch (e) {
      // Handle or log the error appropriately
      debugPrint('Error during vector conversion: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateImage(double scalePercent) async {
    if (state.project == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      // Handle legacy projects that don't have originalImageData yet.
      final bool isLegacyProject = state.project!.originalImageData == null;
      final Uint8List sourceImageData = isLegacyProject
          ? state.project!.imageData
          : state.project!.originalImageData!;
      final double? sourceImageWidth = isLegacyProject
          ? state.project!.imageWidth
          : state.project!.originalImageWidth;
      final double? sourceImageHeight = isLegacyProject
          ? state.project!.imageHeight
          : state.project!.originalImageHeight;

      final result = await compute(_performImageUpdate, {
        'imageData': sourceImageData,
        'scalePercent': scalePercent,
      });

      final updatedProjectData = state.project!.copyWith(
        imageData: result['imageData'],
        imageWidth: result['width'],
        imageHeight: result['height'],
        isConverted: false,
        vectorObjects: [],
        uniqueColorCount: 0,
        // If it's a legacy project, "upgrade" it by setting original data.
        originalImageData: sourceImageData,
        originalImageWidth: sourceImageWidth,
        originalImageHeight: sourceImageHeight,
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

  final originalImage = img.decodeImage(imageData);
  if (originalImage == null) {
    throw Exception('Could not decode image for updating.');
  }

  final newWidth = (originalImage.width * scalePercent / 100).round();
  final newHeight = (originalImage.height * scalePercent / 100).round();

  final resizedImage = img.copyResize(
    originalImage,
    width: newWidth > 0 ? newWidth : 1,
    height: newHeight > 0 ? newHeight : 1,
    interpolation: img.Interpolation.average,
  );

  return {
    'imageData': Uint8List.fromList(img.encodePng(resizedImage)),
    'width': resizedImage.width.toDouble(),
    'height': resizedImage.height.toDouble(),
  };
}
