import 'package:drift/drift.dart';
import 'package:vettore/data/database.dart';

class ProjectsNewRepository {
  final AppDatabase _db;
  ProjectsNewRepository(this._db);

  Stream<List<DbProject>> watchAll() => _db.select(_db.projects).watch();

  Future<List<DbProject>> getAll() => _db.select(_db.projects).get();

  Stream<DbProject> watchById(int id) =>
      (_db.select(_db.projects)..where((p) => p.id.equals(id))).watchSingle();

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
    );
    return _db.into(_db.projects).insert(data);
  }

  Future<void> update(ProjectsCompanion project) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(project.id.value)))
          .write(project);

  Future<void> delete(int id) =>
      (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
}
