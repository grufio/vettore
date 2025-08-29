import 'package:vettore/repositories/project_new_repository.dart';

class ProjectNewService {
  final ProjectsNewRepository repo;
  ProjectNewService({required this.repo});

  Future<int> createDraft(String title, {String? author}) {
    return repo.insertDraft(title: title, author: author);
  }
}
