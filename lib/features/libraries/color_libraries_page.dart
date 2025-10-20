import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/libraries/color_library_detail_page.dart';

class ColorLibrariesPage extends ConsumerWidget {
  const ColorLibrariesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Libraries'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Schmincke Norma Pro'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ColorLibraryDetailPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
