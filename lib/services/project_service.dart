import 'package:vettore/repositories/project_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:vettore/data/database.dart';

/// ProjectService centralizes common project operations via the repository
class ProjectService {
  final ProjectRepository repo;
  ProjectService({required this.repo});

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
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.update(
      ProjectsCompanion(
        id: drift.Value(projectId),
        title: title != null ? drift.Value(title) : const drift.Value.absent(),
        author:
            author != null ? drift.Value(author) : const drift.Value.absent(),
        status:
            status != null ? drift.Value(status) : const drift.Value.absent(),
        imageId:
            imageId != null ? drift.Value(imageId) : const drift.Value.absent(),
        canvasWidthPx: canvasWidthPx != null
            ? drift.Value(canvasWidthPx)
            : const drift.Value.absent(),
        canvasHeightPx: canvasHeightPx != null
            ? drift.Value(canvasHeightPx)
            : const drift.Value.absent(),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateTitle(dynamic ref, int projectId, String title) async {
    await repo.update(
      ProjectsCompanion(
        id: drift.Value(projectId),
        title: drift.Value(title),
        updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> updateCanvasSpec(
    dynamic ref,
    int projectId, {
    required double widthValue,
    required String widthUnit,
    required double heightValue,
    required String heightUnit,
  }) async {
    await repo.update(
      ProjectsCompanion(
        id: drift.Value(projectId),
        canvasWidthValue: drift.Value(widthValue),
        canvasWidthUnit: drift.Value(widthUnit),
        canvasHeightValue: drift.Value(heightValue),
        canvasHeightUnit: drift.Value(heightUnit),
        updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> updateGridSpec(
    dynamic ref,
    int projectId, {
    required double cellWidthValue,
    required String cellWidthUnit,
    required double cellHeightValue,
    required String cellHeightUnit,
  }) async {
    await repo.update(
      ProjectsCompanion(
        id: drift.Value(projectId),
        gridCellWidthValue: drift.Value(cellWidthValue),
        gridCellWidthUnit: drift.Value(cellWidthUnit),
        gridCellHeightValue: drift.Value(cellHeightValue),
        gridCellHeightUnit: drift.Value(cellHeightUnit),
        updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
