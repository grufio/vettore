import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PageId { project, image, conversion, grid, output }

final currentPageProvider = StateProvider<PageId>((ref) => PageId.project);

// Holds the currently opened project id for detail pages.
final currentProjectIdProvider = StateProvider<int?>((ref) => null);

// Optional deep-link helpers (not wired to Navigator):
PageId? pageIdFromString(String s) {
  switch (s) {
    case 'project':
      return PageId.project;
    case 'image':
      return PageId.image;
    case 'conversion':
      return PageId.conversion;
    case 'grid':
      return PageId.grid;
    case 'output':
      return PageId.output;
    default:
      return null;
  }
}

String pageIdToString(PageId id) {
  switch (id) {
    case PageId.project:
      return 'project';
    case PageId.image:
      return 'image';
    case PageId.conversion:
      return 'conversion';
    case PageId.grid:
      return 'grid';
    case PageId.output:
      return 'output';
  }
}

/// Applies a simple app-specific deep link of the form
/// app://detail?page=project&projectId=123 (scheme ignored here)
void applyDeepLink(Uri uri, WidgetRef ref) {
  final pageParam = uri.queryParameters['page'];
  final projParam = uri.queryParameters['projectId'];
  final pid = projParam != null ? int.tryParse(projParam) : null;
  final page = pageParam != null ? pageIdFromString(pageParam) : null;
  if (pid != null) {
    ref.read(currentProjectIdProvider.notifier).state = pid;
  }
  if (page != null) {
    ref.read(currentPageProvider.notifier).state = page;
  }
}
