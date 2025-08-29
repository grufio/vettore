import 'package:drift/drift.dart';
import 'package:vettore/data/database.dart';

class ProjectsNewRepository {
  final AppDatabase _db;
  ProjectsNewRepository(this._db);

  Stream<List<DbProjectNew>> watchAll() => _db.select(_db.projectsNew).watch();

  Future<List<DbProjectNew>> getAll() => _db.select(_db.projectsNew).get();

  Stream<DbProjectNew> watchById(int id) =>
      (_db.select(_db.projectsNew)..where((p) => p.id.equals(id)))
          .watchSingle();

  Future<DbProjectNew> getById(int id) =>
      (_db.select(_db.projectsNew)..where((p) => p.id.equals(id))).getSingle();

  Future<int> insert(ProjectsNewCompanion project) =>
      _db.into(_db.projectsNew).insert(project);

  Future<int> insertDraft({
    required String title,
    String? author,
    String status = 'draft',
    int? imageId,
    int? createdAt,
    int? updatedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = ProjectsNewCompanion.insert(
      title: title,
      author: Value(author),
      status: Value(status),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      imageId: Value(imageId),
    );
    return _db.into(_db.projectsNew).insert(data);
  }

  Future<void> update(ProjectsNewCompanion project) =>
      (_db.update(_db.projectsNew)..where((p) => p.id.equals(project.id.value)))
          .write(project);

  Future<void> delete(int id) =>
      (_db.delete(_db.projectsNew)..where((p) => p.id.equals(id))).go();
}
