import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/application_providers.dart';
import 'package:grufio/repositories/project_repository_pg.dart';

/// Provides a stream of a single project by id backed by Postgres
final projectByIdProvider =
    StreamProvider.family<ProjectRow?, int>((ref, projectId) {
  final repo = ref.watch(projectRepositoryPgProvider);
  return repo.watchById(projectId);
});
