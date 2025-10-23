import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/button_app.dart' show OutlinedActionButton;
import 'package:vettore/widgets/image_dimension_panel.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('DPI change does not enable Resize; editing does',
      (tester) async {
    final widthTC = TextEditingController(text: '120.00');
    final heightTC = TextEditingController(text: '80.00');
    final wVC = UnitValueController();
    final hVC = UnitValueController();

    await tester.pumpWidget(_wrap(ImageDimensionPanel(
      widthTextController: widthTC,
      heightTextController: heightTC,
      widthValueController: wVC,
      heightValueController: hVC,
      enabled: true,
      initialLinked: false,
      onLinkChanged: (_) {},
      initialWidthUnit: 'px',
      initialHeightUnit: 'px',
      onWidthUnitChanged: (_) {},
      onHeightUnitChanged: (_) {},
      currentDpi: 96,
      onDpiChanged: (_) {},
      interpolation: 'Bilinear',
      onInterpolationChanged: (_) {},
      onResizeTap: () {},
    )));

    OutlinedActionButton btn() =>
        tester.widget<OutlinedActionButton>(find.byType(OutlinedActionButton));

    expect(btn().enabled, isFalse); // baseline == current, disabled

    // Rebuild with DPI changed only → should remain disabled
    await tester.pumpWidget(_wrap(ImageDimensionPanel(
      widthTextController: widthTC,
      heightTextController: heightTC,
      widthValueController: wVC,
      heightValueController: hVC,
      enabled: true,
      initialLinked: false,
      onLinkChanged: (_) {},
      initialWidthUnit: 'px',
      initialHeightUnit: 'px',
      onWidthUnitChanged: (_) {},
      onHeightUnitChanged: (_) {},
      currentDpi: 144,
      onDpiChanged: (_) {},
      interpolation: 'Bilinear',
      onInterpolationChanged: (_) {},
      onResizeTap: () {},
    )));
    await tester.pump();
    expect(btn().enabled, isFalse);

    // Edit width text → should enable
    widthTC.text = '120.50';
    await tester.pump();
    expect(btn().enabled, isTrue);
  });
}
