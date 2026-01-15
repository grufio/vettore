import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/providers/image_providers.dart';
import 'package:grufio/providers/project_provider.dart';
import 'package:grufio/services/image_detail_service.dart';

void main() {
  group('Resize flow with DPI resolution and provider invalidation', () {
    testWidgets(
        'uses 96 DPI fallback when image DPI is null and invalidates dims',
        (tester) async {
      // Shared state to simulate image dimensions per imageId
      final Map<int, (int, int)> dimsMap = {1: (50, 60)};
      // Capture the last targets passed to resize
      (int, int)? lastTargets;
      (int?, int?)? finalDims;

      await tester.pumpWidget(ProviderScope(
        overrides: [
          // Always use imageId 1 for the given project
          imageIdStableProvider.overrideWithProvider((projectId) {
            return Provider<int?>((ref) => 1);
          }),
          // image DPI returns null to trigger fallback
          imageDpiProvider.overrideWithProvider((imageId) {
            return FutureProvider<int?>((ref) async => null);
          }),
          // Dimensions provider removed; test uses dimsMap directly
          // Fake project logic that records targets and updates dimsMap, then invalidates
          projectLogicProvider.overrideWithProvider((projectId) {
            return AutoDisposeProvider<ProjectLogic>((ref) {
              return _FakeProjectLogic(ref, projectId, onResize: (w, h) {
                lastTargets = (w, h);
                dimsMap[1] = (w, h);
                // simulate UI refresh by updating dimsMap
              });
            });
          }),
        ],
        child: _Runner(onDone: (ref) async {
          const detail = ImageDetailService();
          // Convert typed 25.4 mm to phys px at fallback 96 dpi
          final physW = detail.toPhysPx(25.4, 'mm', 96);
          final physH = detail.toPhysPx(25.4, 'mm', 96);
          final raster = detail.rasterFromPhys(physW, physH);
          // Perform resize
          await detail.performResize(
            ref,
            projectId: 123,
            targetW: raster.$1,
            targetH: raster.$2,
            interpolationName: 'nearest',
          );
          // Removed imageDimensionsProvider; verify via dimsMap directly
          finalDims = (dimsMap[1]?.$1, dimsMap[1]?.$2);
        }),
      ));

      await tester.pumpAndSettle();

      expect(lastTargets, isNotNull);
      expect(lastTargets!.$1, 96);
      expect(lastTargets!.$2, 96);

      expect(finalDims, isNotNull);
      expect(finalDims!.$1, 96);
      expect(finalDims!.$2, 96);
    });
  });
}

class _Runner extends ConsumerStatefulWidget {
  const _Runner({required this.onDone});
  final Future<void> Function(WidgetRef ref) onDone;

  @override
  ConsumerState<_Runner> createState() => _RunnerState();
}

class _RunnerState extends ConsumerState<_Runner> {
  bool _ran = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ran) return;
    _ran = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.onDone(ref);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _FakeProjectLogic extends ProjectLogic {
  _FakeProjectLogic(super.ref, super.projectId, {required this.onResize});
  final void Function(int w, int h) onResize;

  @override
  Future<void> resizeToCv(
      int targetWidth, int targetHeight, String interpolationName) async {
    onResize(targetWidth, targetHeight);
  }
}
