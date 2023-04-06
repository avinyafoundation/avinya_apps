// import 'package:ShoolManagementSystem/src/screens/assets.dart';
// import 'package:ShoolManagementSystem/src/screens/resource_allocations.dart';
import 'package:flutter/material.dart';
import 'package:consumable/screens/resource_allocations.dart';
import 'package:consumable/screens/bulk_attendance_marker.dart';
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
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.pathTemplate.startsWith('/consumables') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('Consumable details screen'),
            child: ResourceAllocationsScreen(),
          )
        else if (currentRoute.pathTemplate
            .startsWith('/consumable_feedback_breakfast'))
          const FadeTransitionPage<void>(
            key: ValueKey('Consumable breakfast details screen'),
            child: BulkAttendanceMarkerScreen(),
          )
        else if (currentRoute.pathTemplate
            .startsWith('/consumable_feedback_lunch'))
          const FadeTransitionPage<void>(
            key: ValueKey('Consumable lunch details screen'),
            child: BulkAttendanceMarkerScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/create_menu'))
          const FadeTransitionPage<void>(
            key: ValueKey('Create Menu screen'),
            child: BulkAttendanceMarkerScreen(),
          )

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
