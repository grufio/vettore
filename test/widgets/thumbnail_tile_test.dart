import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';

// A 1x1 transparent PNG
final Uint8List kPng1x1 = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  group('ThumbnailTile', () {
    testWidgets(
        'uses a single ClipRRect and foreground border with same radius',
        (tester) async {
      const r = BorderRadius.all(Radius.circular(8));
      const w = 240.0;

      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(devicePixelRatio: 2.0),
          child: Center(
            child: SizedBox(
              width: w,
              height: 300,
              child: ThumbnailTile(
                borderRadius: r,
                borderWidth: 3.0,
                borderColor: Color(0xFF000000),
                lines: ['A', 'B', 'C'],
              ),
            ),
          ),
        ),
      ));

      // Exactly one ClipRRect
      final clips = find.byType(ClipRRect);
      expect(clips, findsOneWidget);
      final clip = tester.widget<ClipRRect>(clips);
      expect(clip.borderRadius, equals(r));

      // Container with foregroundDecoration border having same radius
      final containerFinder = find
          .descendant(
              of: find.byType(ThumbnailTile), matching: find.byType(Container))
          .first;
      final container = tester.widget<Container>(containerFinder);
      final foreground = container.foregroundDecoration as BoxDecoration?;
      expect(foreground, isNotNull);
      expect(foreground!.borderRadius, equals(r));
      expect(foreground.border, isNotNull);
    });

    testWidgets('Image.memory sets cacheWidth/Height from logical size and DPR',
        (tester) async {
      const logicalWidth = 200.0;
      const dpr = 2.0;
      // ThumbnailTile uses 4:3 area for the image; cache is based on this logical width
      final expectedCacheW = (logicalWidth * dpr).toInt();
      final expectedCacheH = ((logicalWidth * 0.75) * dpr).toInt();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: dpr),
          child: Center(
            child: SizedBox(
              width: logicalWidth,
              height: 300,
              child: ThumbnailTile(
                imageBytes: kPng1x1,
                lines: const ['A', 'B', 'C'],
              ),
            ),
          ),
        ),
      ));

      // Find the Image widget inside the AspectRatio
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      final provider = image.image;
      // Flutter wraps with ResizeImage when cacheWidth/Height are used
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.width, expectedCacheW);
      expect(resize.height, expectedCacheH);
    });
  });
}
