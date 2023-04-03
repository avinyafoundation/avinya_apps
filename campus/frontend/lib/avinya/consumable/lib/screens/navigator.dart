import 'dart:developer';

// import 'package:ShoolManagementSystem/src/screens/avinya_type_details.dart';
// import 'package:ShoolManagementSystem/src/screens/asset_details.dart';
// import 'package:ShoolManagementSystem/src/screens/resource_allocation_details.dart';
// import 'package:asset/screens/activity_details.dart';
// import 'package:asset/screens/avinya_type_details.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:consumable/screens/resource_allocation_details.dart';
import 'package:gallery/auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class SMSNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SMSNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<SMSNavigator> createState() => _SMSNavigatorState();
}

class _SMSNavigatorState extends State<SMSNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');
  final _consumableDetailsKey = const ValueKey('Consumable details screen');
  final _consumableBreakfastDetailsKey =
      const ValueKey('Consumable breakfast details screen');
  final _consumableLunchDetailsKey =
      const ValueKey('Consumable lunch details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = SMSAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    // Asset? selectedAsset;
    // if (pathTemplate == '/asset/:id') {
    //   selectedAsset = campusConfigSystemInstance.assets?.firstWhereOrNull(
    //       (at) => at.id.toString() == routeState.route.parameters['id']);
    // }

    ResourceAllocation? selectedResourceAllocation;
    // if (pathTemplate == '/consumable/:id') {
    //   selectedResourceAllocation =
    //       campusConfigSystemInstance.resourceAllocations?.firstWhereOrNull(
    //           (at) => at.id.toString() == routeState.route.parameters['id']);
    // }

    if (pathTemplate == '/#access_token') {
      log('Navigator $routeState.route.parameters.toString()');
      log('Navigator $routeState.route.queryParameters.toString()');
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /avinya_types tab in SMSScaffold.

        if (route.settings is Page &&
            (route.settings as Page).key == _consumableDetailsKey) {
          routeState.go('/consumables');
        }
        if (route.settings is Page &&
            (route.settings as Page).key == _consumableBreakfastDetailsKey) {
          routeState.go('/consumable_feedback_breakfast');
        }
        if (route.settings is Page &&
            (route.settings as Page).key == _consumableLunchDetailsKey) {
          routeState.go('/consumable_feedback_lunch');
        }

        return route.didPop(result);
      },
      pages: [
        // if (routeState.route.pathTemplate == '/apply')
        //   // Display the sign in screen.
        //   FadeTransitionPage<void>(
        //     key: _applyKey,
        //     child: ApplyScreen(
        //         ),
        //   )
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/consumable_feedback_breakfast');
                }
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const SMSScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a book
          // or an author
          if (selectedResourceAllocation != null)
            MaterialPage<void>(
              key: _consumableDetailsKey,
              child: ResourceAllocationDetailsScreen(
                resourceAllocation: selectedResourceAllocation,
              ),
            )

          // else if (selectedEmployee != null)
          //   MaterialPage<void>(
          //     key: _employeeDetailsKey,
          //     child: EmployeeDetailsScreen(
          //       employee: selectedEmployee,
          //     ),
          //   )
        ],
      ],
    );
  }
}
