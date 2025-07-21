import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';

final vendorColorStreamProvider = StreamProvider<List<VendorColor>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.vendorColors)).watch();
});
