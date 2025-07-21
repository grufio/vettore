import 'package:vettore/data/database.dart';

class ProjectRepository {
  final AppDatabase _db;

  ProjectRepository(this._db);

  // Watch for changes to the projects table
  Stream<List<Project>> watchProjects() {
    return _db.select(_db.projects).watch();
  }

  // Get a list of all projects once
  Future<List<Project>> getProjects() {
    return _db.select(_db.projects).get();
  }

  // Watch for changes to a single project
  Stream<Project> watchProject(int id) {
    return (_db.select(_db.projects)..where((p) => p.id.equals(id)))
        .watchSingle();
  }

  // Get a single project by its ID
  Future<Project> getProject(int id) {
    return (_db.select(_db.projects)..where((p) => p.id.equals(id)))
        .getSingle();
  }

  // Add a new project
  Future<int> addProject(ProjectsCompanion project) {
    return _db.into(_db.projects).insert(project);
  }

  // Delete a project by its ID
  Future<void> deleteProject(int id) {
    return (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
  }

  // Update an existing project
  Future<void> updateProject(ProjectsCompanion project) {
    return (_db.update(_db.projects)
          ..where((p) => p.id.equals(project.id.value)))
        .write(project);
  }
}
