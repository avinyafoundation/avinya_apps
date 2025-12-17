import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/app_routes/app_routes.dart';
import 'package:gallery/avinya/maintenance/lib/data.dart';
import 'package:gallery/avinya/maintenance/lib/screens/add_location_screen.dart';
import 'package:gallery/avinya/maintenance/lib/screens/kanban_screen.dart';
import 'package:gallery/avinya/maintenance/lib/screens/add_task_screen.dart';
import 'package:gallery/avinya/maintenance/lib/screens/maintenance_dashboard_screen.dart';
import 'package:gallery/avinya/maintenance/lib/screens/maintenance_tasks.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [SMSScaffold]
class SMSScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const SMSScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      pages: [
        if (currentRoute.pathTemplate
                .startsWith(AppRoutes.maintenanceDashboardRoute) &&
            (campusAppsPortalInstance.isFoundation ||
                campusAppsPortalInstance.isTeacher))
          const FadeTransitionPage<void>(
            key: ValueKey('maintenance_dashboard_Screen'),
            child: MaintenanceDashboardScreen(),
          )
        else if (currentRoute.pathTemplate
                .startsWith(AppRoutes.addLocationRoute) &&
            (campusAppsPortalInstance.isFoundation ||
                campusAppsPortalInstance.isTeacher))
          const FadeTransitionPage<void>(
            key: ValueKey('add_location_screen'),
            child: AddLocationScreen(),
          )
        else if (currentRoute.pathTemplate
                .startsWith(AppRoutes.kanbanBoardRoute) &&
            (campusAppsPortalInstance.isFoundation ||
                campusAppsPortalInstance.isTeacher))
          const FadeTransitionPage<void>(
            key: ValueKey('kanban_board_screen'),
            child: KanbanScreen(),
          )
        else if (currentRoute.pathTemplate
                .startsWith(AppRoutes.taskDetailsRoute) &&
            (campusAppsPortalInstance.isFoundation ||
                campusAppsPortalInstance.isTeacher))
          const FadeTransitionPage<void>(
            key: ValueKey('task_details_screen'),
            child: ReportScreen(),
          ) 
        else if (currentRoute.pathTemplate
                .startsWith(AppRoutes.addTaskRoute) &&
            (campusAppsPortalInstance.isFoundation ||
                campusAppsPortalInstance.isTeacher))
          const FadeTransitionPage<void>(
            key: ValueKey('add_task_screen'),
            child: AddTaskScreen(),
          )
        // else if (currentRoute.pathTemplate.startsWith(AppRoutes.alumniAdminRoute))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('alumni_admin'),
        //     child: AlumniAdminScreen(),
        // )
        // Avoid building a Navigator with an empty `pages` list when the
        // RouteState is set to an unexpected path, such as /signin.
        //
        // Since RouteStateScope is an InheritedNotifier, any change to the
        // route will result in a call to this build method, even though this
        // widget isn't built when those routes are active.
        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
