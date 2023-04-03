import 'dart:developer';

//import 'package:ShoolManagementSystem/src/data/campus_config_system.dart';
//import 'package:ShoolManagementSystem/src/data/resource_allocation.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';

//import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class ConsumableSystem extends StatefulWidget {
  const ConsumableSystem({super.key});

  @override
  State<ConsumableSystem> createState() => _ConsumableSystemState();
}

class _ConsumableSystemState extends State<ConsumableSystem> {
  final _auth = CampusAppsPortalAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/consumables',
        '/consumable_feedback_breakfast',
        '/consumable_feedback_lunch',
        '/#access_token',
      ],
      guard: _guard,
      initialRoute: '/consumables',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => SMSNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: SMSAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
            // Revert back to pre-Flutter-2.5 transition behavior:
            // https://github.com/flutter/flutter/issues/82053
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();
    // String? jwt_sub = campusConfigSystemInstance.getJWTSub();

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    final consumableRoute = ParsedRoute('/consumables', '/consumables', {}, {});
    final consumableLunchRoute = ParsedRoute('/consumable_feedback_breakfast',
        'consumable_feedback_breakfast', {}, {});
    final consumableBreakfastRoute = ParsedRoute(
        'consumable_feedback_lunch', 'consumable_feedback_lunch', {}, {});

    // // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");

    if (signedIn && from == consumableRoute) {
      return consumableRoute;
    } else if (signedIn && from == consumableLunchRoute) {
      return consumableLunchRoute;
    } else if (signedIn && from == consumableBreakfastRoute) {
      return consumableBreakfastRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/consumables', '/consumables', {}, {});
    }
    log("_guard signed in2 $signedIn");
    // } else if (signedIn && jwt_sub != null) {
    //   return resourceAllocationRoute;
    // }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go('/consumables');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
