import 'dart:async';

class ProjectRow {
  ProjectRow({
    required this.id,
    required this.title,
    this.author,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageId,
    required this.canvasWidthValue,
    required this.canvasWidthUnit,
    required this.canvasHeightValue,
    required this.canvasHeightUnit,
    required this.gridCellWidthValue,
    required this.gridCellWidthUnit,
    required this.gridCellHeightValue,
    required this.gridCellHeightUnit,
  });
  final int id;
  final String title;
  final String? author;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int? imageId;
  final double canvasWidthValue;
  final String canvasWidthUnit;
  final double canvasHeightValue;
  final String canvasHeightUnit;
  final double gridCellWidthValue;
  final String gridCellWidthUnit;
  final double gridCellHeightValue;
  final String gridCellHeightUnit;
}

/// No-op stub repository replacing the previous Postgres-backed implementation.
/// Methods return empty/default values so the app can compile/run without a DB.
class ProjectRepositoryPg {
  ProjectRepositoryPg();

  Stream<List<ProjectRow>> watchAll() {
    // Emit empty list and keep open
    final controller = StreamController<List<ProjectRow>>.broadcast();
    controller.add(const <ProjectRow>[]);
    return controller.stream;
  }

  Future<List<ProjectRow>> getAll() async {
    return const <ProjectRow>[];
  }

  Stream<ProjectRow?> watchById(int id) async* {
    yield await getByIdOrNull(id);
  }

  Future<ProjectRow?> getByIdOrNull(int id) async {
    return null;
  }

  Future<ProjectRow> getById(int id) async {
    throw StateError('project $id not found');
  }

  Future<int> insertDraft({
    required String title,
    String? author,
    String status = 'draft',
    int? createdAt,
    int? updatedAt,
  }) async {
    return 0;
  }

  Future<void> updateTitle(int id, String title) async {
    return;
  }

  Future<void> delete(int id) async {
    return;
  }

  Future<void> updateFields(
    int id, {
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
  }) async {}
}
