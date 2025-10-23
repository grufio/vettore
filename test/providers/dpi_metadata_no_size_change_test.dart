import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/providers/image_providers.dart';

void main() {
  testWidgets('DPI metadata change does not alter phys pixels', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        imagePhysPixelsProvider.overrideWithProvider((imageId) {
          return FutureProvider<(double?, double?)>((ref) async {
            return (200.0, 100.0);
          });
        }),
        imageDpiProvider.overrideWithProvider((imageId) {
          return FutureProvider<int?>((ref) async => 96);
        }),
      ],
      child: Consumer(builder: (context, ref, _) {
        return const SizedBox.shrink();
      }),
    ));

    const imageId = 1;
    final initial =
        await ProviderScope.containerOf(tester.element(find.byType(SizedBox)))
            .read(imagePhysPixelsProvider(imageId).future);
    expect(initial.$1, 200.0);
    expect(initial.$2, 100.0);

    // Rebuild with new DPI override
    await tester.pumpWidget(ProviderScope(
      overrides: [
        imagePhysPixelsProvider.overrideWithProvider((imageId) {
          return FutureProvider<(double?, double?)>((ref) async {
            return (200.0, 100.0);
          });
        }),
        imageDpiProvider.overrideWithProvider((imageId) {
          return FutureProvider<int?>((ref) async => 192);
        }),
      ],
      child: Consumer(builder: (context, ref, _) {
        return const SizedBox.shrink();
      }),
    ));

    final after =
        await ProviderScope.containerOf(tester.element(find.byType(SizedBox)))
            .read(imagePhysPixelsProvider(imageId).future);
    expect(after.$1, 200.0);
    expect(after.$2, 100.0);
  });
}
