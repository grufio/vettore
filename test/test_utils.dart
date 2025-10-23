import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pumps a minimal ProviderScope + Directionality shell and executes [run]
/// with the [WidgetRef] after first frame.
Future<void> pumpWithRef(
  WidgetTester tester, {
  List<Override> overrides = const [],
  required Future<void> Function(WidgetRef ref) run,
}) async {
  final completer = Completer<void>();
  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: _Runner(refRun: (ref) async {
      await run(ref);
      completer.complete();
    }),
  ));
  await completer.future;
  await tester.pumpAndSettle();
}

class _Runner extends ConsumerWidget {
  const _Runner({required this.refRun});
  final Future<void> Function(WidgetRef ref) refRun;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refRun(ref);
    });
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.shrink(),
    );
  }
}

/// Simple fake image detail service to be reused in tests when only
/// method-call verification is needed.
class CallsTracker {
  bool persistCalled = false;
  bool resizeCalled = false;
  void reset() {
    persistCalled = false;
    resizeCalled = false;
  }
}

