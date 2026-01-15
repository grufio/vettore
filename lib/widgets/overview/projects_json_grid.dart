import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
// ignore_for_file: always_use_package_imports
import 'package:grufio/widgets/thumbnail_tile.dart';
import '../../theme/app_theme_colors.dart';

class ProjectsJsonGrid extends StatelessWidget {
  const ProjectsJsonGrid({super.key});

  Future<List<Map<String, dynamic>>> _loadProjects() async {
    try {
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('data/projects.json');
      } catch (_) {
        jsonString = await File('data/projects.json').readAsString();
      }
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['projects'] is List) {
        return (decoded['projects'] as List)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      }
    } catch (_) {
      // Fall through to empty
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadProjects(),
      builder: (context, snapshot) {
        final List<Map<String, dynamic>> items =
            snapshot.data ?? const <Map<String, dynamic>>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading…'));
        }

        if (items.isEmpty) {
          return const Center(child: Text('No projects'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 4 / 3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> p = items[index];
            final String title = (p['title'] ?? '').toString();
            final String status = (p['status'] ?? '').toString();

            return ThumbnailTile(
              backgroundFill: kGrey10,
              imageAspectRatio: 4 / 3,
              lines: <String>[
                title.isEmpty ? 'Untitled' : title,
                status,
                '',
              ],
            );
          },
        );
      },
    );
  }
}
