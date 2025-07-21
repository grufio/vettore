import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';

final vendorColorsProvider =
    FutureProvider.autoDispose<List<VendorColorWithVariants>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.allVendorColorsWithVariants;
});
