import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/features/projects/project_overview_page.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/initialization_service.dart';
import 'package:vettore/features/splash/splash_page.dart';
import 'package:vettore/providers/application_providers.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  final initializationService = InitializationService();
  await initializationService.initialize();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
