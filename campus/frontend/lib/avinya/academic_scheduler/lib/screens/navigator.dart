import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/enrollment/lib/screens/sign_in.dart';
import '../data.dart';
import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

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
  final _scaffoldKey = const ValueKey('App scaffold');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
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
        if (routeState.route.pathTemplate == '/academic_scheduler_dashboard')
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: SMSScaffold(),
          ),
      ],
    );
  }
}
