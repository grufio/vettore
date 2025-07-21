import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/palette_repository.dart';

final paletteListStreamProvider = StreamProvider<List<FullPalette>>((ref) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchAllPalettes();
});

final paletteListLogicProvider = Provider((ref) {
  final paletteRepository = ref.read(paletteRepositoryProvider);
  return PaletteListLogic(paletteRepository);
});

class PaletteListLogic {
  final PaletteRepository _paletteRepository;

  PaletteListLogic(this._paletteRepository);

  Future<void> createNewPalette(String name) async {
    final newPalette = PalettesCompanion.insert(
      name: name,
    );
    await _paletteRepository.addPalette(newPalette, []);
  }

  Future<void> deletePalette(int id) async {
    await _paletteRepository.deletePalette(id);
  }
}
