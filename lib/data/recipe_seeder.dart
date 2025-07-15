import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vettore/color_component_model.dart';
import 'package:vettore/palette_color.dart';
import 'package:vettore/palette_model.dart';

class RecipeSeeder {
  static const String _recipeSeedCompleteKey = 'recipe_seed_v1_complete';

  static Future<void> seedRecipes() async {
    final settingsBox = Hive.box('settings');
    final isSeeded = settingsBox.get(
      _recipeSeedCompleteKey,
      defaultValue: false,
    );

    if (isSeeded) {
      return;
    }

    final palettesBox = Hive.box<Palette>('palettes');

    // Check if the master palette already exists to avoid duplicates on re-runs
    final masterPaletteExists = palettesBox.values.any(
      (p) => p.name == 'Master Recipes',
    );
    if (masterPaletteExists) {
      return;
    }

    final masterPalette = Palette()..name = 'Master Recipes';

    masterPalette.colors.addAll([
      _createRecipe1(),
      _createRecipe2(),
      _createRecipe3(),
      _createRecipe4(),
      _createRecipe5(),
      _createRecipe6(),
      _createRecipe7(),
      _createRecipe8(),
      _createRecipe9(),
      _createRecipe10(),
    ]);

    await palettesBox.add(masterPalette);
    await settingsBox.put(_recipeSeedCompleteKey, true);
  }

  static PaletteColor _createRecipe1() {
    return PaletteColor(
      title: '#1',
      status: 'DE 1: 1.9, DE 2: 1.9, DE 3: 2.1',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.98),
        ColorComponent(name: '352 Violet Dark', percentage: 0.02),
        ColorComponent(name: '236 Lemon Yellow', percentage: 0.00),
      ],
    );
  }

  static PaletteColor _createRecipe2() {
    return PaletteColor(
      title: '#2',
      status: 'DE 1: 1.9, DE 2: 1.7, DE 3: 1.8',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.94),
        ColorComponent(name: '410 Cobalt Blue Light', percentage: 0.06),
      ],
    );
  }

  static PaletteColor _createRecipe3() {
    return PaletteColor(
      title: '#3',
      status: 'DE 1: 1.7, DE 2: 1.1, DE 3: 1.9',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.92),
        ColorComponent(name: '410 Cobalt Blue Light', percentage: 0.08),
      ],
    );
  }

  static PaletteColor _createRecipe4() {
    return PaletteColor(
      title: '#4',
      status: 'DE 1: 1.7, DE 2: 1.1, DE 3: 1.9',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.92),
        ColorComponent(name: '410 Cobalt Blue Light', percentage: 0.08),
      ],
    );
  }

  static PaletteColor _createRecipe5() {
    return PaletteColor(
      title: '#5',
      status: 'DE 1: 1.6, DE 2: 0.5, DE 3: 1.6',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.89),
        ColorComponent(name: '410 Cobalt Blue Light', percentage: 0.11),
        ColorComponent(name: '300 Cadmium Orange', percentage: 0.00),
      ],
    );
  }

  static PaletteColor _createRecipe6() {
    return PaletteColor(
      title: '#6',
      status: 'DE 1: 1.4, DE 2: 0.1, DE 3: 0.0',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.86),
        ColorComponent(name: '410 Cobalt Blue Light', percentage: 0.13),
        ColorComponent(name: '300 Cadmium Orange', percentage: 0.01),
      ],
    );
  }

  static PaletteColor _createRecipe7() {
    return PaletteColor(
      title: '#7',
      status: 'DE 1: 2.0, DE 2: 0.0, DE 3: 0.0',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.81),
        ColorComponent(name: '710 Cold Grey', percentage: 0.19),
      ],
    );
  }

  static PaletteColor _createRecipe8() {
    return PaletteColor(
      title: '#8',
      status: 'DE 1: 1.9, DE 2: 0.0, DE 3: 0.5',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.76),
        ColorComponent(name: '710 Cold Grey', percentage: 0.24),
      ],
    );
  }

  static PaletteColor _createRecipe9() {
    return PaletteColor(
      title: '#9',
      status: 'DE 1: 1.8, DE 2: 0.0, DE 3: 0.0',
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.70),
        ColorComponent(name: '710 Cold Grey', percentage: 0.30),
      ],
    );
  }

  static PaletteColor _createRecipe10() {
    return PaletteColor(
      title: '#10',
      status: 'DE 1: 1.7', // Only one DE value provided
      color: Colors.grey.value,
      components: [
        ColorComponent(name: '114 Titanium White', percentage: 99.65),
        ColorComponent(name: '710 Cold Grey', percentage: 0.35),
      ],
    );
  }
}
