import 'dart:typed_data';
import 'package:image/image.dart' as img;

class DecodedDimensions {
  final int? width;
  final int? height;
  const DecodedDimensions(this.width, this.height);
}

class UniqueColorsResult {
  final int count;
  final int? width;
  final int? height;
  const UniqueColorsResult({required this.count, this.width, this.height});
}

// Top-level functions for compute()
DecodedDimensions decodeDimensions(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  return DecodedDimensions(decoded?.width, decoded?.height);
}

UniqueColorsResult decodeUniqueColors(Uint8List bytes) {
  int uniqueColorCount = 0;
  int? w;
  int? h;
  final decoded = img.decodeImage(bytes);
  if (decoded != null) {
    w = decoded.width;
    h = decoded.height;
    final colors = <int>{};
    for (final p in decoded) {
      colors.add(
          img.rgbaToUint32(p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt()));
    }
    uniqueColorCount = colors.length;
  }
  return UniqueColorsResult(count: uniqueColorCount, width: w, height: h);
}
