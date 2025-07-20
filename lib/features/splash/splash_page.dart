import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/projects/project_overview_page.dart';
import 'package:vettore/main.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(initializationProvider);

    return initialization.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text(
            'Error during initialization: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (_) => const ProjectOverviewPage(),
    );
  }
}
