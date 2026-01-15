import 'package:flutter_riverpod/flutter_riverpod.dart';
// project_provider not needed here
import 'package:grufio/services/settings_service.dart';

// Removed ImageSpec/imageSpecProvider (unused)

// Persist user-selected units per project for Image tab width/height inputs
final imageWidthUnitProvider =
    StateProvider.family<String, int>((ref, projectId) {
  final settings = ref.read(settingsServiceProvider);
  return settings.imageDefaultUnit;
});
final imageHeightUnitProvider =
    StateProvider.family<String, int>((ref, projectId) {
  final settings = ref.read(settingsServiceProvider);
  return settings.imageDefaultUnit;
});
