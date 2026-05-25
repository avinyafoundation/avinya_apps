import 'package:flutter/material.dart';
import 'package:gallery/avinya/food_waste/lib/screens/manage_food_screen.dart';
import 'package:gallery/avinya/food_waste/lib/screens/log_history_screen.dart';
import 'package:gallery/avinya/food_waste/lib/screens/log_waste.dart';
import '../app_routes/app_routes.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';
import 'food_waste_dashboard_screen.dart';

/// Displays the contents of the body of [SMSScaffold]
class SMSScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const SMSScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    return Navigator(
      key: navigatorKey,
      pages: [
        if (currentRoute.pathTemplate
            .startsWith(AppRoutes.foodWastageDashboardRoute))
          const FadeTransitionPage<void>(
            key: ValueKey('food_waste_dashboard_screen'),
            child: FoodWasteDashboardScreen(),
          )
        else if (currentRoute.pathTemplate
            .startsWith(AppRoutes.addLogWasteRoute))
          const FadeTransitionPage<void>(
            key: ValueKey('add_log_waste_screen'),
            child: LogWasteScreen(),
          )
        else if (currentRoute.pathTemplate
            .startsWith(AppRoutes.logWasteHistoryRoute))
          const FadeTransitionPage<void>(
            key: ValueKey('log_waste_history_screen'),
            child: LogHistoryScreen(),
          )
        else if (currentRoute.pathTemplate
            .startsWith(AppRoutes.manageFoodItemsRoute))
          const FadeTransitionPage<void>(
            key: ValueKey('manage_food_items_screen'),
            child: ManageFoodScreen(),
          )
        // else
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('food_waste_dashboard_screen'),
        //     child: FoodWasteDashboardScreen(),
        //   )
      ],
    );
  }
}
