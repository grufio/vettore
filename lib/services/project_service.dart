import 'package:drift/drift.dart' as drift;
import 'package:vettore/data/database.dart';
import 'package:vettore/repositories/project_repository.dart';

/// ProjectService centralizes common project operations via the repository
class ProjectService {
  ProjectService({required this.repo});
  final ProjectRepository repo;

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
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.runInTransaction(() async {
      await repo.update(
        ProjectsCompanion(
          id: drift.Value(projectId),
          title:
              title != null ? drift.Value(title) : const drift.Value.absent(),
          author:
              author != null ? drift.Value(author) : const drift.Value.absent(),
          status:
              status != null ? drift.Value(status) : const drift.Value.absent(),
          imageId: imageId != null
              ? drift.Value(imageId)
              : const drift.Value.absent(),
          canvasWidthPx: canvasWidthPx != null
              ? drift.Value(canvasWidthPx)
              : const drift.Value.absent(),
          canvasHeightPx: canvasHeightPx != null
              ? drift.Value(canvasHeightPx)
              : const drift.Value.absent(),
          canvasWidthValue: canvasWidthValue != null
              ? drift.Value(canvasWidthValue)
              : const drift.Value.absent(),
          canvasWidthUnit: canvasWidthUnit != null
              ? drift.Value(canvasWidthUnit)
              : const drift.Value.absent(),
          canvasHeightValue: canvasHeightValue != null
              ? drift.Value(canvasHeightValue)
              : const drift.Value.absent(),
          canvasHeightUnit: canvasHeightUnit != null
              ? drift.Value(canvasHeightUnit)
              : const drift.Value.absent(),
          gridCellWidthValue: gridCellWidthValue != null
              ? drift.Value(gridCellWidthValue)
              : const drift.Value.absent(),
          gridCellWidthUnit: gridCellWidthUnit != null
              ? drift.Value(gridCellWidthUnit)
              : const drift.Value.absent(),
          gridCellHeightValue: gridCellHeightValue != null
              ? drift.Value(gridCellHeightValue)
              : const drift.Value.absent(),
          gridCellHeightUnit: gridCellHeightUnit != null
              ? drift.Value(gridCellHeightUnit)
              : const drift.Value.absent(),
          updatedAt: drift.Value(now),
        ),
      );
    });
  }
}
