import 'package:hive/hive.dart';

part 'vendor_color_model.g.dart';

@HiveType(typeId: 5)
class VendorColor extends HiveObject {
  @HiveField(0)
  late String articleNumber;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int size;
}
