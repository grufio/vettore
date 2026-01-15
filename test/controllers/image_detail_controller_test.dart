import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/services/image_detail_controller.dart';

void main() {
  group('ImageDetailController linking', () {
    test('linked controllers scale partner by aspect', () {
      final ctrl = ImageDetailController();
      // Seed width/height in pixels
      ctrl.widthVC.setValuePx(200);
      ctrl.heightVC.setValuePx(100);

      // Link height to width with known aspect (height = width * 0.5)
      ctrl.widthVC.linkWith(ctrl.heightVC, partnerOverThis: 0.5);

      // Changing width should scale height
      ctrl.widthVC.setValuePx(300);
      expect(ctrl.heightVC.valuePx, closeTo(150, 1e-9));

      // Unlink and ensure no further propagation
      ctrl.widthVC.setLinked(false);
      ctrl.widthVC.setValuePx(220);
      expect(ctrl.heightVC.valuePx, closeTo(150, 1e-9));
    });

    test('applyRemotePx sets aspect as height/width on widthVC', () {
      final ctrl = ImageDetailController();
      ctrl.applyRemotePx(widthPx: 400, heightPx: 100);
      // partnerOverThisAspect is set on the width controller
      expect(ctrl.widthVC.partnerOverThisAspect, closeTo(0.25, 1e-9));
    });
  });

  group('ImageDetailController DPI and display behavior', () {
    test('setUiDpi updates dpi but preserves pixel value', () {
      final ctrl = ImageDetailController();
      // Work in centimeters for display, but pixels are the source of truth
      ctrl.widthVC.setUnit('cm');
      // 2.54 cm at 96 dpi equals 96 px (1 inch)
      ctrl.widthVC.setValueFromUnit(2.54, isUserInput: true);
      final pxBefore = ctrl.widthVC.valuePx;
      expect(pxBefore, isNotNull);

      // Change DPI to 192; pixels must remain the same
      ctrl.setUiDpi(192);
      final pxAfter = ctrl.widthVC.valuePx;
      expect(pxAfter, equals(pxBefore));

      // Echo stability keeps last typed value for the same unit within epsilon
      final cmDisplay = ctrl.widthVC.getDisplayValueInUnit(overrideUnit: 'cm');
      expect(cmDisplay, isNotNull);
      expect(cmDisplay, equals(2.54));
    });

    test('echo stability: px unit rounds to nearest int on user input', () {
      final ctrl = ImageDetailController();
      ctrl.widthVC.setUnit('px');
      ctrl.widthVC.setValueFromUnit(200.4, isUserInput: true);
      // Display should prefer rounded echo for px
      final disp = ctrl.widthVC.getDisplayValueInUnit();
      expect(disp, equals(200));
      // Underlying pixels store full precision from conversion path
      expect(ctrl.widthVC.valuePx, isNotNull);
    });
  });
}
