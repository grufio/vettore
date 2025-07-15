import 'package:hive/hive.dart';

part 'color_component_model.g.dart';

@HiveType(typeId: 6)
class ColorComponent {
  @HiveField(0)
  String name;

  @HiveField(1)
  double percentage;

  ColorComponent({required this.name, required this.percentage});
}
