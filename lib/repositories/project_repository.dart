import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/project_model.dart';

class ProjectRepository {
  final Box<Project> _projectBox;

  ProjectRepository(this._projectBox);

  ValueListenable<Box<Project>> getProjectsListenable() {
    return _projectBox.listenable();
  }

  List<Project> getProjects() {
    return _projectBox.values.toList();
  }

  Future<void> addProject(Project project) {
    return _projectBox.add(project);
  }

  Future<void> deleteProject(int key) {
    return _projectBox.delete(key);
  }

  Future<void> updateProject(int key, Project project) {
    return _projectBox.put(key, project);
  }
}
