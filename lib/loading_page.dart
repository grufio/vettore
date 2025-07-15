import 'package:flutter/material.dart';
import 'package:vettore/data/color_seeder.dart';
import 'package:vettore/data/recipe_seeder.dart';
import 'package:vettore/project_overview_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('[LoadingPage] Initializing...');
      await ColorSeeder.seedColors();
      await RecipeSeeder.seedRecipes();
      debugPrint('[LoadingPage] Initialization COMPLETE.');
      // When seeding is done, navigate to the main page
      if (mounted) {
        debugPrint('[LoadingPage] Navigating to HomePage...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e, s) {
      // Handle or show error if seeding fails
      debugPrint('!!!!!!!! FAILED TO INITIALIZE AND SEED DATA !!!!!!!!');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $s');
      debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing data...'),
          ],
        ),
      ),
    );
  }
}
