import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: always_use_package_imports
import '../providers/application_providers.dart';

/// Project image id (nullable) fetched from Postgres `projects.image_id`.
final projectImageIdProvider =
    FutureProvider.family<int?, int>((ref, projectId) async {
  final repo = ref.read(projectRepositoryPgProvider);
  final row = await repo.getByIdOrNull(projectId);
  return row?.imageId;
});


