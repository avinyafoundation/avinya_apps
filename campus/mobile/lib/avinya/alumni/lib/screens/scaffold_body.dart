// import 'package:ShoolManagementSystem/src/screens/assets.dart';
// import 'package:ShoolManagementSystem/src/screens/resource_allocations.dart';
import 'package:flutter/material.dart';
import 'package:mobile/avinya/alumni/lib/app_routes/app_routes.dart';
import 'package:mobile/avinya/alumni/lib/screens/bottom_navigation/home/screens/my_alumni_dashboard.dart';


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
        if (currentRoute.pathTemplate.startsWith(AppRoutes.alumniHome)  ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('alumni_home_Screen'),
            child: MyAlumniDashboardScreen(),
          )
        // else if (currentRoute.pathTemplate.startsWith(AppRoutes.alumniAdmin))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('alumni_admin'),
        //     child: AlumniAdminScreen(),
        //   )
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
