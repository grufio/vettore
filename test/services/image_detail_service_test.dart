import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/services/image_detail_service.dart';

void main() {
  group('ImageDetailService', () {
    final svc = const ImageDetailService();

    test('toPhysPx converts using dpi and unit', () {
      // 1 inch at 96 dpi => 96 px
      expect(svc.toPhysPx(1.0, 'in', 96), closeTo(96.0, 1e-9));
      // 25.4 mm at 96 dpi => 96 px
      expect(svc.toPhysPx(25.4, 'mm', 96), closeTo(96.0, 1e-9));
    });

    test('computeTargetPhys respects linked aspect and untouched side', () {
      // Current: 200x100 px, linked
      final resW = svc.computeTargetPhys(
        typedW: 50.0,
        wUnit: 'px',
        typedH: null,
        hUnit: 'px',
        dpi: 96,
        curPhysW: 200.0,
        curPhysH: 100.0,
        linked: true,
      );
      // width set to 50 => height should scale to 25 keeping aspect 0.5
      expect(resW.$1, closeTo(50.0, 1e-9));
      expect(resW.$2, closeTo(25.0, 1e-9));

      // When height typed and linked, width scales
      final resH = svc.computeTargetPhys(
        typedW: null,
        wUnit: 'px',
        typedH: 30.0,
        hUnit: 'px',
        dpi: 96,
        curPhysW: 200.0,
        curPhysH: 100.0,
        linked: true,
      );
      expect(resH.$1, closeTo(60.0, 1e-9)); // 30 * (200/100)
      expect(resH.$2, closeTo(30.0, 1e-9));

      // Unlinked: typed side changes only; other remains
      final resUn = svc.computeTargetPhys(
        typedW: 80.0,
        wUnit: 'px',
        typedH: null,
        hUnit: 'px',
        dpi: 96,
        curPhysW: 200.0,
        curPhysH: 100.0,
        linked: false,
      );
      expect(resUn.$1, closeTo(80.0, 1e-9));
      expect(resUn.$2, closeTo(100.0, 1e-9));
    });

    test('rasterFromPhys rounds to integer pixels', () {
      final r = svc.rasterFromPhys(120.4, 199.6);
      expect(r.$1, 120);
      expect(r.$2, 200);
    });
  });
}
