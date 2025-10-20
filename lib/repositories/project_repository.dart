import 'package:drift/drift.dart';
import 'package:vettore/data/database.dart';

class ProjectRepository {
  ProjectRepository(this._db);
  final AppDatabase _db;

  Stream<List<DbProject>> watchAll() => _db.select(_db.projects).watch();

  Future<List<DbProject>> getAll() => _db.select(_db.projects).get();

  Stream<DbProject?> watchById(int id) =>
      (_db.select(_db.projects)..where((p) => p.id.equals(id)))
          .watchSingleOrNull();

  Future<DbProject> getById(int id) =>
      (_db.select(_db.projects)..where((p) => p.id.equals(id))).getSingle();

  Future<int> insert(ProjectsCompanion project) =>
      _db.into(_db.projects).insert(project);

  Future<int> insertDraft({
    required String title,
    String? author,
    String status = 'draft',
    int? imageId,
    int? createdAt,
    int? updatedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = ProjectsCompanion.insert(
      title: title,
      author: Value(author),
      status: Value(status),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      imageId: Value(imageId),
      canvasWidthPx: const Value(100),
      canvasHeightPx: const Value(100),
      canvasWidthValue: const Value(100.0),
      canvasWidthUnit: const Value('mm'),
      canvasHeightValue: const Value(100.0),
      canvasHeightUnit: const Value('mm'),
      gridCellWidthValue: const Value(10.0),
      gridCellWidthUnit: const Value('mm'),
      gridCellHeightValue: const Value(10.0),
      gridCellHeightUnit: const Value('mm'),
    );
    return _db.into(_db.projects).insert(data);
  }

  Future<void> update(ProjectsCompanion project) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(project.id.value)))
          .write(project);

  Future<void> delete(int id) =>
      (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
}
