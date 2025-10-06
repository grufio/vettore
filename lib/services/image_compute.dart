import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart' as exif;

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

String detectMimeType(Uint8List bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    return 'image/jpeg';
  }
  return 'application/octet-stream';
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

/// Best-effort DPI (resolution) detection.
/// - For PNG: reads pHYs chunk (pixels per meter) and converts to DPI.
/// - For JPEG: reads APP0 JFIF density (pixels per inch or per cm).
/// Returns null if not present.
Future<int?> decodeDpi(Uint8List bytes) async {
  // 1) Try EXIF first (JPEGs typically)
  try {
    final Map<String, exif.IfdTag> tags = await exif.readExifFromBytes(bytes);
    final dynamic xResVal = tags['XResolution']?.values;
    final String? unitPrintable = tags['ResolutionUnit']?.printable;
    if (xResVal != null && xResVal is List && xResVal.isNotEmpty) {
      final String s = xResVal.first.toString(); // e.g., 300/1
      int dpi = _parseRationalToInt(s);
      if (unitPrintable != null &&
          unitPrintable.toLowerCase().contains('centimeter')) {
        dpi = (dpi * 2.54).round();
      }
      if (dpi > 0) return dpi;
    }
  } catch (_) {
    // ignore
  }

  if (bytes.length < 12) return null;
  // PNG signature: 89 50 4E 47 0D 0A 1A 0A
  const pngSig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  bool isPng = true;
  for (int i = 0; i < pngSig.length; i++) {
    if (bytes[i] != pngSig[i]) {
      isPng = false;
      break;
    }
  }
  if (isPng) {
    int offset = 8; // after signature
    while (offset + 12 <= bytes.length) {
      // length (4), type (4), data (length), crc (4)
      int length = _u32(bytes, offset);
      int typeA = bytes[offset + 4];
      int typeB = bytes[offset + 5];
      int typeC = bytes[offset + 6];
      int typeD = bytes[offset + 7];
      // 'pHYs'
      if (typeA == 0x70 && typeB == 0x48 && typeC == 0x59 && typeD == 0x73) {
        if (length >= 9 && offset + 8 + 9 <= bytes.length) {
          final int ppux = _u32(bytes, offset + 8);
          // final int ppuy = _u32(bytes, offset + 12); // unused; prefer X density
          final int unit = bytes[offset + 16]; // 0=unknown, 1=meters
          if (unit == 1) {
            // pixels per meter to DPI
            final double dppix = ppux / 39.37007874015748; // inches per meter
            return dppix.round();
          }
        }
        break; // found pHYs or malformed; stop
      }
      // move to next chunk
      offset += 12 + length;
    }
    return null;
  }
  // 2) JPEG JFIF fallback: SOI 0xFFD8
  if (bytes.length >= 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    int offset = 2;
    while (offset + 4 <= bytes.length) {
      if (bytes[offset] != 0xFF) {
        offset++;
        continue;
      }
      int marker = bytes[offset + 1];
      offset += 2;
      if (marker == 0xD9 || marker == 0xDA) {
        break; // EOI or SOS
      }
      if (offset + 2 > bytes.length) break;
      int segmentLength = (bytes[offset] << 8) | bytes[offset + 1];
      if (segmentLength < 2 || offset + segmentLength > bytes.length) break;
      // APP0 JFIF
      if (marker == 0xE0 && segmentLength >= 16) {
        // Identifier 'JFIF\0'
        if (bytes[offset + 2] == 0x4A &&
            bytes[offset + 3] == 0x46 &&
            bytes[offset + 4] == 0x49 &&
            bytes[offset + 5] == 0x46 &&
            bytes[offset + 6] == 0x00) {
          // int units = bytes[offset + 7 + 2]; // unused; corrected parse below
        }
        // Safer parse with fixed positions per JFIF:
        // segment payload starts at offset+2
        final int payload = offset + 2;
        if (bytes.length >= payload + 14) {
          if (bytes[payload + 0] == 0x4A &&
              bytes[payload + 1] == 0x46 &&
              bytes[payload + 2] == 0x49 &&
              bytes[payload + 3] == 0x46 &&
              bytes[payload + 4] == 0x00) {
            final int units = bytes[payload + 7];
            final int xDensity = (bytes[payload + 8] << 8) | bytes[payload + 9];
            // final int yDensity = (bytes[payload +10] << 8) | bytes[payload +11];
            if (units == 1) {
              return xDensity; // pixels per inch
            } else if (units == 2) {
              return (xDensity * 2.54).round(); // pixels per cm -> dpi
            } else {
              // unknown units; do not trust density
              return null;
            }
          }
        }
      }
      offset += segmentLength;
    }
  }
  return null;
}

int _u32(Uint8List b, int off) {
  return (b[off] << 24) | (b[off + 1] << 16) | (b[off + 2] << 8) | b[off + 3];
}

// removed duplicate _parseRationalToInt

int _parseRationalToInt(String s) {
  if (s.contains('/')) {
    final parts = s.split('/');
    if (parts.length == 2) {
      final num? nume = num.tryParse(parts[0]);
      final num? den = num.tryParse(parts[1]);
      if (nume != null && den != null && den != 0) {
        return (nume / den).round();
      }
    }
  }
  return int.tryParse(s) ?? 0;
}
