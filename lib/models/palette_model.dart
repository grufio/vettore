import 'package:hive/hive.dart';
import 'package:vettore/models/palette_color.dart';

part 'palette_model.g.dart';

@HiveType(typeId: 1)
class Palette {
  @HiveField(0)
  late String name;

  @HiveField(1)
  List<PaletteColor> colors = [];

  @HiveField(2)
  double sizeInMl = 60.0;

  @HiveField(3)
  double factor = 1.5;

  Palette();

  // Copy constructor
  Palette.from(Palette other) {
    name = other.name;
    colors = List<PaletteColor>.from(
      other.colors.map((c) => PaletteColor.from(c)),
    );
    sizeInMl = other.sizeInMl;
    factor = other.factor;
  }

  Palette copyWith({
    String? name,
    List<PaletteColor>? colors,
    double? sizeInMl,
    double? factor,
  }) {
    return Palette.from(this)
      ..name = name ?? this.name
      ..colors = colors ?? this.colors.map((c) => PaletteColor.from(c)).toList()
      ..sizeInMl = sizeInMl ?? this.sizeInMl
      ..factor = factor ?? this.factor;
  }
}
