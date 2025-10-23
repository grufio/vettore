// unused import removed
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/services/image_actions.dart';
import 'package:vettore/services/image_detail_service.dart';

void main() {
  testWidgets('resizeCommit persists phys and refreshes providers',
      (tester) async {
    bool calledPersist = false;
    bool calledResize = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        imageDetailServiceProvider.overrideWithValue(_FakeDetailService(
          onPersistPhys: (imageId, w, h) => calledPersist = true,
          onResize: (w, h) => calledResize = true,
        )),
      ],
      child: Consumer(builder: (context, ref, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final actions = ref.read(imageActionsProvider);
          await actions.resizeCommit(
            ref,
            projectId: 123,
            imageId: 1,
            interpName: 'nearest',
            curPhysW: 100,
            curPhysH: 50,
            typedW: 200,
            wUnit: 'px',
            typedH: 100,
            hUnit: 'px',
            dpi: 96,
            onPhysCommitted: (w, h) {},
          );
        });
        return const SizedBox.shrink();
      }),
    ));

    await tester.pumpAndSettle();
    expect(calledResize, isTrue);
    expect(calledPersist, isTrue);
  });
}

class _FakeDetailService implements ImageDetailService {
  _FakeDetailService({required this.onPersistPhys, required this.onResize});
  final void Function(int imageId, double w, double h) onPersistPhys;
  final void Function(int w, int h) onResize;

  @override
  (double, double) computeTargetPhys({
    required double? typedW,
    required String wUnit,
    required double? typedH,
    required String hUnit,
    required int dpi,
    required double curPhysW,
    required double curPhysH,
    required bool linked,
  }) =>
      (typedW ?? curPhysW, typedH ?? curPhysH);

  @override
  (int, int) rasterFromPhys(double physW, double physH) =>
      (physW.round(), physH.round());

  @override
  Future<void> performResize(WidgetRef ref,
      {required int projectId,
      required int targetW,
      required int targetH,
      required String interpolationName}) async {
    onResize(targetW, targetH);
  }

  @override
  Future<void> persistPhys(
      WidgetRef ref, int imageId, double physW, double physH) async {
    onPersistPhys(imageId, physW, physH);
  }

  // Unused in this test
  @override
  double toPhysPx(double value, String unit, int dpi) => value;
}

// unused observer removed
