import 'dart:developer';

// import 'package:ShoolManagementSystem/src/screens/avinya_type_details.dart';
// import 'package:ShoolManagementSystem/src/screens/asset_details.dart';
// import 'package:ShoolManagementSystem/src/screens/resource_allocation_details.dart';
// import 'package:asset/screens/activity_details.dart';
// import 'package:asset/screens/avinya_type_details.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/enrollment/lib/screens/sign_in.dart';
// import 'package:gallery/avinya/asset_admin/lib/screens/resource_allocation_details.dart';

//import '../auth.dart';

import '../data.dart';
import '../routing.dart';
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
  final _assetDetailsKey = const ValueKey('Asset details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = SMSAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    if (pathTemplate == '/#access_token') {
      log('Navigator $routeState.route.parameters.toString()');
      log('Navigator $routeState.route.queryParameters.toString()');
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /avinya_types tab in SMSScaffold.
        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/enrollment_dashboard');
                }
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: SMSScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a book
          // or an author
          // if (selectedResourceAllocation != null)
          //   MaterialPage<void>(
          //     key: _assetDetailsKey,
          //     child: ResourceAllocationDetailsScreen(
          //       resourceAllocation: selectedResourceAllocation,
          //     ),
          //   )

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
