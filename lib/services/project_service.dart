// ignore_for_file: always_use_package_imports
import '../repositories/project_repository_pg.dart';

/// ProjectService centralizes common project operations via the repository
class ProjectService {
  ProjectService({required this.repo});
  final ProjectRepositoryPg repo;

  Future<int> createDraft(String title, {String? author}) {
    return repo.insertDraft(title: title, author: author);
  }

  /// Batch multiple field updates in a single write
  Future<void> batchUpdate(
    dynamic ref,
    int projectId, {
    String? title,
    String? author,
    String? status,
    int? imageId,
    int? canvasWidthPx,
    int? canvasHeightPx,
    double? canvasWidthValue,
    String? canvasWidthUnit,
    double? canvasHeightValue,
    String? canvasHeightUnit,
    double? gridCellWidthValue,
    String? gridCellWidthUnit,
    double? gridCellHeightValue,
    String? gridCellHeightUnit,
  }) async {
    await repo.updateFields(
      projectId,
      title: title,
      author: author,
      status: status,
      imageId: imageId,
      canvasWidthPx: canvasWidthPx,
      canvasHeightPx: canvasHeightPx,
      canvasWidthValue: canvasWidthValue,
      canvasWidthUnit: canvasWidthUnit,
      canvasHeightValue: canvasHeightValue,
      canvasHeightUnit: canvasHeightUnit,
      gridCellWidthValue: gridCellWidthValue,
      gridCellWidthUnit: gridCellWidthUnit,
      gridCellHeightValue: gridCellHeightValue,
      gridCellHeightUnit: gridCellHeightUnit,
    );
  }
}
