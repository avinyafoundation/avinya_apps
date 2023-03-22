import 'dart:developer';

import 'package:pcti_notes_admin/data/campus_config_system.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class CampusPctiSystem extends StatefulWidget {
  const CampusPctiSystem({super.key});

  @override
  State<CampusPctiSystem> createState() => _CampusPctiSystemState();
}

class _CampusPctiSystemState extends State<CampusPctiSystem> {
  final _auth = SMSAuth();
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
        '/#access_token',
        '/admin/pcti_activities',
        '/admin/pcti_activities/popular',
        '/admin/pcti_activities/:id',
        '/admin/pcti_activities_substitute/:id',
        '/admin/pcti/substitute',
        '/admin/pcti/substitute/popular',
      ],
      guard: _guard,
      initialRoute: '/admin/pcti_activities',
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

    // final pctiNotesRoute =
    //     ParsedRoute('/pcti_notes', '/pcti_notes', {}, {});

    final pctiActivitiesRoute =
        ParsedRoute('/admin/pcti_activities', '/admin/pcti_activities', {}, {});

    final pctiActivitiesSubstituteRoute =
        ParsedRoute('/admin/pcti/substitute', '/admin/pcti/substitute', {}, {});

    // final pctiActivityInstancesRoute =
    //   ParsedRoute('/pcti_activity_instances', '/pcti_activity_instances', {}, {});

    // // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");

    if (signedIn && from == pctiActivitiesRoute) {
      return pctiActivitiesRoute;
    }
    // else if (signedIn && from == pctiNotesRoute) {
    //   return pctiNotesRoute;
    // } else if (signedIn && from == pctiActivityInstancesRoute) {
    //   return pctiActivityInstancesRoute;
    // }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == pctiActivitiesSubstituteRoute) {
      return ParsedRoute(
          '/admin/pcti/substitute', '/admin/pcti/substitute', {}, {});
      // return pctiActivitiesSubstituteRoute;
    } else if (signedIn && from == signInRoute) {
      return ParsedRoute(
          '/admin/pcti_activities', '/admin/pcti_activities', {}, {});
    }

    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go('/admin/pcti_activities');
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
