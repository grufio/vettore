// ignore_for_file: always_use_package_imports
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/overview/app_overview.dart';
import 'app_project_detail.dart';
import 'models/grufio_tab_data.dart';
import 'providers/tabs_providers.dart';
import 'services/router_observer.dart';
import 'theme/app_theme_colors.dart';
import 'widgets/app_header_bar.dart';

/// Global GoRouter configuration using a ShellRoute to keep the AppHeaderBar
/// persistent while routing content underneath.
final GoRouter appRouter = GoRouter(
  observers: [TabsSyncRouterObserver()],
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ColoredBox(
          color: kWhite,
          child: Consumer(builder: (context, ref, _) {
            final List<GrufioTabData> tabs = ref.watch(tabsProvider);
            final int activeIndex = ref.watch(activeTabIndexProvider);
            void navigateToIndex(int index) {
              if (index <= 0) {
                context.go('/');
                return;
              }
              final GrufioTabData t = tabs[index];
              if (t.projectId != null) {
                context.go('/project/${t.projectId}');
              } else {
                context.go('/');
              }
            }

            return Column(
              children: [
                AppHeaderBar(
                  tabs: tabs,
                  activeIndex: activeIndex,
                  onTabSelected: (i) {
                    ref
                        .read(activeTabIndexProvider.notifier)
                        .set(i, tabs.length);
                    navigateToIndex(i);
                  },
                  onCloseTab: (i) {
                    ref.read(tabsServiceProvider).closeTab(i);
                    final int newIndex = ref.read(activeTabIndexProvider);
                    final List<GrufioTabData> newTabs = ref.read(tabsProvider);
                    if (newIndex < newTabs.length) {
                      navigateToIndex(newIndex);
                    } else {
                      context.go('/');
                    }
                  },
                ),
                Expanded(child: child),
              ],
            );
          }),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (BuildContext context, GoRouterState state) =>
              const AppOverviewPage(showHeader: false),
        ),
        GoRoute(
          path: '/project/:id',
          name: 'project',
          builder: (BuildContext context, GoRouterState state) {
            final String? idStr = state.pathParameters['id'];
            final int? projectId = idStr == null ? null : int.tryParse(idStr);
            // Tab synchronization is handled centrally by TabsSyncRouterObserver
            return AppProjectDetailPage(projectId: projectId);
          },
        ),
      ],
    ),
  ],
);
