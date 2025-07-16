import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/main.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/repositories/palette_repository.dart';

/// A provider that returns a [PaletteNotifier] for a given palette key.
///
/// This provider is used to get the state of a single palette and to
/// update it.
final paletteProvider = StateNotifierProvider.autoDispose
    .family<PaletteNotifier, Palette?, int>((ref, paletteKey) {
      final paletteRepository = ref.watch(paletteRepositoryProvider);
      try {
        final palette = paletteRepository.getPalette(paletteKey);
        return PaletteNotifier(palette, paletteRepository);
      } catch (e) {
        return PaletteNotifier(null, paletteRepository);
      }
    });

/// A notifier that manages the state of a single palette.
class PaletteNotifier extends StateNotifier<Palette?> {
  final PaletteRepository _paletteRepository;

  PaletteNotifier(super.palette, this._paletteRepository);

  /// Updates the details of the palette (name, size, factor).
  Future<void> updateDetails({
    required String name,
    required double size,
    required double factor,
  }) async {
    if (state == null) return;
    final newState = state!.copyWith(
      name: name,
      sizeInMl: size,
      factor: factor,
    );
    await _paletteRepository.updatePalette(newState);
    state = newState;
  }

  /// Adds a new color to the palette.
  Future<void> addNewColor(PaletteColor color) async {
    if (state == null) return;
    final newColors = List<PaletteColor>.from(state!.colors)..add(color);
    final newState = state!.copyWith(colors: newColors);
    await _paletteRepository.updatePalette(newState);
    state = newState;
  }

  /// Updates an existing color in the palette.
  Future<void> updateColor(int index, PaletteColor color) async {
    if (state == null) return;
    final newColors = List<PaletteColor>.from(state!.colors);
    newColors[index] = color;
    final newState = state!.copyWith(colors: newColors);
    await _paletteRepository.updatePalette(newState);
    state = newState;
  }

  /// Deletes a color from the palette.
  Future<void> deleteColor(int index) async {
    if (state == null) return;
    final newColors = List<PaletteColor>.from(state!.colors)..removeAt(index);
    final newState = state!.copyWith(colors: newColors);
    await _paletteRepository.updatePalette(newState);
    state = newState;
  }
}

/// A provider that returns a [PaletteListNotifier] which manages the list
/// of all palettes.
final paletteListProvider =
    StateNotifierProvider<PaletteListNotifier, List<Palette>>((ref) {
      return PaletteListNotifier(ref.watch(paletteRepositoryProvider));
    });

/// A notifier that manages the state of the list of all palettes.
class PaletteListNotifier extends StateNotifier<List<Palette>> {
  final PaletteRepository _paletteRepository;

  PaletteListNotifier(this._paletteRepository) : super([]) {
    _listenToPalettes();
  }

  void _listenToPalettes() {
    _paletteRepository.getPalettesListenable().addListener(_updateState);
    _updateState(); // Initial state
  }

  void _updateState() {
    final box = _paletteRepository.getPalettesListenable().value;
    final List<Palette> palettes = [];
    for (final key in box.keys) {
      final palette = box.get(key);
      if (palette != null) {
        // Manually assign the key to the palette object
        palette.key = key;
        palettes.add(palette);
      }
    }
    state = palettes;
  }

  /// Adds a new palette to the database.
  Future<void> addPalette(Palette palette) async {
    await _paletteRepository.addPalette(palette);
  }

  /// Deletes a palette from the database.
  Future<void> deletePalette(int key) async {
    await _paletteRepository.deletePalette(key);
  }

  @override
  void dispose() {
    _paletteRepository.getPalettesListenable().removeListener(_updateState);
    super.dispose();
  }
}
