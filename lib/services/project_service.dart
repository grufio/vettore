import 'package:vettore/repositories/project_repository.dart';

class ProjectService {
  final ProjectRepository repo;
  ProjectService({required this.repo});

  Future<int> createDraft(String title, {String? author}) {
    return repo.insertDraft(title: title, author: author);
  }
}
