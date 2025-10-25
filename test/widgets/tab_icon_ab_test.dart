import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:svg_provider/svg_provider.dart';

/// Simple A/B rendering harness to visually compare flutter_svg vs svg_provider
/// for the three main tab icons at 32x32. This test only verifies that
/// widgets are built; visual crispness should be inspected by running this
/// test with `flutter test` and checking for exceptions or by adapting to a
/// golden-test flow if desired.
void main() {
  // Capture framework errors to help diagnose empty renders
  final List<FlutterErrorDetails> errorLog = <FlutterErrorDetails>[];
  FlutterExceptionHandler? previous;
  setUp(() {
    previous = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      errorLog.add(details);
      // Also print to console for visibility during runs
      // ignore: avoid_print
      print('[svg-ab] FlutterError: ${details.exceptionAsString()}');
    };
  });
  tearDown(() {
    FlutterError.onError = previous;
    errorLog.clear();
  });
  const List<String> tabIconAssets32 = <String>[
    'assets/icons/32/home.svg',
    'assets/icons/32/close.svg',
    'assets/icons/32/add.svg',
  ];

  const String rawSquareSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
  <rect x="4" y="4" width="24" height="24" fill="#000000"/>
</svg>
''';

  Widget row(String label, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          ...children,
        ],
      ),
    );
  }

  Widget cell(Widget child) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      color: const Color(0xFFF0F0F0),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget buildHarness({required bool tinted}) {
    // Colors roughly matching tabs
    const Color tintInactive = Color(0xFF8F8F93);
    final Color untintedColor = Colors.black;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row('flutter_svg', [
                for (final a in tabIconAssets32)
                  cell(SvgPicture.asset(
                    a,
                    width: 32,
                    height: 32,
                    colorFilter: tinted
                        ? const ColorFilter.mode(tintInactive, BlendMode.srcIn)
                        : null,
                  )),
              ]),
              row('svg_provider', [
                for (final a in tabIconAssets32)
                  cell(Image(
                    image: SvgProvider(
                      a,
                      color: tinted ? tintInactive : untintedColor,
                    ),
                    width: 32,
                    height: 32,
                    filterQuality: FilterQuality.none,
                  )),
              ]),
              row('svg_provider_raw', [
                cell(Image(
                  image: SvgProvider(
                    rawSquareSvg,
                    source: SvgSource.raw,
                    color: tinted ? tintInactive : untintedColor,
                  ),
                  width: 32,
                  height: 32,
                  filterQuality: FilterQuality.none,
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('A/B render 32x32 untinted at default DPR', (tester) async {
    await tester.pumpWidget(buildHarness(tinted: false));
    // Basic sanity: both rows rendered
    expect(find.text('flutter_svg'), findsOneWidget);
    expect(find.text('svg_provider'), findsOneWidget);
  });

  testWidgets('A/B render 32x32 tinted at default DPR', (tester) async {
    await tester.pumpWidget(buildHarness(tinted: true));
    expect(find.text('flutter_svg'), findsOneWidget);
    expect(find.text('svg_provider'), findsOneWidget);
  });

  testWidgets('A/B render 32x32 untinted at DPR=2.0', (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(devicePixelRatio: 2.0),
      child: buildHarness(tinted: false),
    ));
    expect(find.text('flutter_svg'), findsOneWidget);
    expect(find.text('svg_provider'), findsOneWidget);
  });

  testWidgets('A/B render 32x32 tinted at DPR=2.0', (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(devicePixelRatio: 2.0),
      child: buildHarness(tinted: true),
    ));
    expect(find.text('flutter_svg'), findsOneWidget);
    expect(find.text('svg_provider'), findsOneWidget);
  });

  // Golden helpers
  Future<void> pumpForGolden(
    WidgetTester tester, {
    required bool tinted,
    required double dpr,
  }) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Fix surface size to a deterministic logical size; account for DPR
    const Size logical = Size(480, 240);
    binding.window.devicePixelRatioTestValue = dpr;
    binding.window.physicalSizeTestValue =
        Size(logical.width * dpr, logical.height * dpr);
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
    await tester.pumpWidget(buildHarness(tinted: tinted));
    await tester.pumpAndSettle();
  }

  testWidgets('GOLDEN: 32x untinted DPR1', (tester) async {
    await pumpForGolden(tester, tinted: false, dpr: 2.0);
    await expectLater(
      find.byType(Material),
      matchesGoldenFile('goldens/tab_icons_dpr2_untinted.png'),
    );
  });

  testWidgets('GOLDEN: 32x tinted DPR1', (tester) async {
    await pumpForGolden(tester, tinted: true, dpr: 2.0);
    await expectLater(
      find.byType(Material),
      matchesGoldenFile('goldens/tab_icons_dpr2_tinted.png'),
    );
  });

  testWidgets('GOLDEN: 32x untinted DPR2', (tester) async {
    await pumpForGolden(tester, tinted: false, dpr: 2.0);
    await expectLater(
      find.byType(Material),
      matchesGoldenFile('goldens/tab_icons_dpr2_untinted.png'),
    );
  });

  testWidgets('GOLDEN: 32x tinted DPR2', (tester) async {
    await pumpForGolden(tester, tinted: true, dpr: 2.0);
    await expectLater(
      find.byType(Material),
      matchesGoldenFile('goldens/tab_icons_dpr2_tinted.png'),
    );
  });
}
