import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/projects/project_overview_page.dart';
import 'package:vettore/services/initialization_service.dart';

// Create a provider for the InitializationService
final initializationProvider = FutureProvider<void>((ref) async {
  final service = InitializationService();
  await service.initialize();
});

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the provider's state
    ref.listen<AsyncValue<void>>(initializationProvider, (previous, next) {
      next.when(
        data: (_) {
          // On success, navigate to the main page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        error: (e, s) {
          // On error, show a SnackBar
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Initialization failed: $e')));
        },
        loading: () {
          // The UI will show the loading indicator
        },
      );
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing application...'),
          ],
        ),
      ),
    );
  }
}
