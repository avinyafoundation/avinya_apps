// import 'package:ShoolManagementSystem/src/screens/assets.dart';
// import 'package:ShoolManagementSystem/src/screens/resource_allocations.dart';
import 'package:flutter/material.dart';
import 'package:asset_admin/screens/empty_screen.dart';
import 'package:gallery/avinya/asset_admin/lib/screens/asset_dashboard_screen.dart';
import 'package:gallery/avinya/asset_admin/lib/screens/consumable_dashboard_screen.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/resource_allocation_report.dart';

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
       if (currentRoute.pathTemplate.startsWith('/resource_allocation_report'))
          const FadeTransitionPage<void>(
            key: ValueKey('resource_allocation_report'),
            child: ResourceAllocationReport(),
          )
       else if (currentRoute.pathTemplate.startsWith('/asset_dashboard'))
          const FadeTransitionPage<void>(
            key: ValueKey('activites'),
            child: AssetDashboardScreen(),
          )
       else if (currentRoute.pathTemplate.startsWith('/consumable_dashboard'))
          const FadeTransitionPage<void>(
            key: ValueKey('activites'),
            child: ConsumableDashboardScreen(),
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
