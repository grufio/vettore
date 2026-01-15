import 'dart:typed_data';

/// No-op stub repository replacing the previous Postgres-backed implementation.
class ImageRepositoryPg {
  ImageRepositoryPg();

  Future<int> insertBase({
    required Uint8List origSrc,
    required int origBytes,
    int? origWidth,
    int? origHeight,
    required String mimeType,
  }) async {
    return 0;
  }

  Future<void> setDpiAndPhys(
      int id, int dpi, double? physW, double? physH) async {}

  Future<void> setConverted(int id, Uint8List convSrc) async {}

  Future<Uint8List?> getBestBytes(int id) async {
    return null;
  }

  Future<int?> getDpi(int id) async {
    return null;
  }

  Future<(double?, double?)> getPhys(int id) async {
    return (null, null);
  }
}
