import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/main.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/repositories/palette_repository.dart';

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

class PaletteNotifier extends StateNotifier<Palette?> {
  final PaletteRepository _paletteRepository;

  PaletteNotifier(Palette? palette, this._paletteRepository) : super(palette);

  void updateDetails({
    required String name,
    required double size,
    required double factor,
  }) {
    if (state == null) return;
    state = state!
      ..name = name
      ..sizeInMl = size
      ..factor = factor;
    _paletteRepository.updatePalette(state!);
  }

  void addColor() {
    if (state == null) return;
    final newColor = PaletteColor(
      title: 'New Color',
      color: Colors.black.value,
    );
    state!.colors.add(newColor);
    _paletteRepository.updatePalette(state!);
    // We need to create a new instance of the state to trigger a rebuild
    state = Palette.from(state!);
  }

  void updateColor(int index, PaletteColor color) {
    if (state == null) return;
    state!.colors[index] = color;
    _paletteRepository.updatePalette(state!);
    state = Palette.from(state!);
  }

  void deleteColor(int index) {
    if (state == null) return;
    state!.colors.removeAt(index);
    _paletteRepository.updatePalette(state!);
    state = Palette.from(state!);
  }
}

final paletteListProvider =
    StateNotifierProvider<PaletteListNotifier, List<Palette>>((ref) {
      return PaletteListNotifier(ref.watch(paletteRepositoryProvider));
    });

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
    state = _paletteRepository.getPalettesListenable().value.values.toList();
  }

  Future<void> addPalette(Palette palette) async {
    await _paletteRepository.addPalette(palette);
  }

  Future<void> deletePalette(Palette palette) async {
    await _paletteRepository.deletePalette(palette);
  }

  @override
  void dispose() {
    _paletteRepository.getPalettesListenable().removeListener(_updateState);
    super.dispose();
  }
}
