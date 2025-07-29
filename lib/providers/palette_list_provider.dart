import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';

final paletteListStreamProvider = StreamProvider<List<FullPalette>>((ref) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchAllPalettes();
});

class CategorizedPalettes {
  final List<FullPalette> customPalettes;
  final List<FullPalette> imagePalettes;

  const CategorizedPalettes({
    this.customPalettes = const [],
    this.imagePalettes = const [],
  });
}

final categorizedPalettesProvider =
    Provider.autoDispose<CategorizedPalettes>((ref) {
  final palettes = ref.watch(paletteListStreamProvider).value ?? [];

  return CategorizedPalettes(
    customPalettes: palettes.where((p) => p.palette.isPredefined).toList(),
    imagePalettes: palettes.where((p) => !p.palette.isPredefined).toList(),
  );
});

final paletteListLogicProvider = Provider((ref) {
  return PaletteListLogic(ref);
});

class PaletteListLogic {
  final Ref _ref;

  PaletteListLogic(this._ref);

  Future<void> createNewCustomPalette(String name) async {
    final paletteRepository = _ref.read(paletteRepositoryProvider);
    final newPalette = PalettesCompanion.insert(
      name: name,
      isPredefined:
          const Value(true), // Corrected: Custom palettes are 'predefined'
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
