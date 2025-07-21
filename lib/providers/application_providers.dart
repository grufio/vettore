import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/repositories/palette_repository.dart';

//-
//-
//-         CORE DATA PROVIDERS
//-
//-

// The single instance of our database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// The single instance of our project repository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProjectRepository(db);
});

// The single instance of our palette repository
final paletteRepositoryProvider = Provider<PaletteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PaletteRepository(db);
});

//-
//-
//-         SERVICE PROVIDERS
//-
//-

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});
