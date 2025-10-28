import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/tabs_providers.dart';

/// Navigator observer that keeps header tabs in sync with the current URL.
/// - Ensures a project tab exists and is selected when navigating to /project/:id
/// - Dedupes tabs by projectId
class TabsSyncRouterObserver extends NavigatorObserver {
  void _syncForRoute(Route<dynamic>? route) {
    final NavigatorState? nav = navigator;
    if (route == null || nav == null) return;
    final BuildContext ctx = nav.context;
    final container = ProviderScope.containerOf(ctx);
    final String? location =
        GoRouter.of(ctx).routeInformationProvider.value.location;
    if (location == null || location.isEmpty) return;
    final Uri uri = Uri.parse(location);
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'project') {
      if (uri.pathSegments.length >= 2) {
        final int? projectId = int.tryParse(uri.pathSegments[1]);
        if (projectId != null) {
          // Add/select immediately with a fallback label
          container.read(tabsServiceProvider).addOrSelectProjectTab(
                projectId: projectId,
                label: 'Untitled',
              );
          // Fetch title and update label asynchronously
          () async {
            try {
              final repo = container.read(projectRepositoryProvider);
              final DbProject p = await repo.getById(projectId);
              final String label = (p.title.isNotEmpty) ? p.title : 'Untitled';
              container
                  .read(tabsProvider.notifier)
                  .updateProjectTabLabel(projectId, label);
            } catch (_) {
              // ignore errors
            }
          }();
        }
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _syncForRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _syncForRoute(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _syncForRoute(previousRoute);
    super.didPop(route, previousRoute);
  }
}
