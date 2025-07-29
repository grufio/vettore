import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';

final paletteListStreamProvider = StreamProvider<List<FullPalette>>((ref) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchAllPalettes();
});

final paletteListLogicProvider = Provider((ref) {
  return PaletteListLogic(ref);
});

class PaletteListLogic {
  final Ref _ref;

  PaletteListLogic(this._ref);

  Future<void> createNewPalette(String name) async {
    final paletteRepository = _ref.read(paletteRepositoryProvider);
    final newPalette = PalettesCompanion.insert(
      name: name,
    );
    await paletteRepository.addPalette(newPalette, []);
  }

  Future<void> deletePalette(int id) async {
    final projectRepository = _ref.read(projectRepositoryProvider);
    final paletteRepository = _ref.read(paletteRepositoryProvider);

    // Find the project associated with this palette
    final project = await projectRepository.findProjectByPaletteId(id);

    if (project != null) {
      // If a project is found, reset it. The reset logic handles clearing the palette.
      await _ref.read(projectLogicProvider(project.id)).resetImage();
    } else {
      // If no project is found (orphaned palette), just delete the palette.
      await paletteRepository.deletePalette(id);
    }
  }
}
