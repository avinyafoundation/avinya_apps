import 'dart:developer';

import 'package:ShoolManagementSystem/src/data/admission_system.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class AdmissionsManagementSystem extends StatefulWidget {
  const AdmissionsManagementSystem({super.key});

  @override
  State<AdmissionsManagementSystem> createState() =>
      _AdmissionsManagementSystemState();
}

class _AdmissionsManagementSystemState
    extends State<AdmissionsManagementSystem> {
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
        '/subscribe',
        '/subscribed_thankyou',
        '/preconditions',
        '/signin',
        '/apply',
        '/tests/logical',
        '/application',
        '/authors',
        '/settings',
        '/books/new',
        '/books/all',
        '/books/popular',
        '/book/:bookId',
        '/author/:authorId',
        '/employees/new',
        '/employees/all',
        '/employees/popular',
        '/employee/:employeeId',
        '/address_types/new',
        '/address_types/all',
        '/address_types/popular',
        '/address_type/:id',
        '/address_type/new',
        '/address_type/edit',
        '/#access_token',
      ],
      guard: _guard,
      initialRoute: '/subscribe',
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
    String? jwt_sub = admissionSystemInstance.getJWTSub();
    final applyRoute = ParsedRoute('/apply', '/apply', {}, {});
    final subscribeRoute = ParsedRoute('/subscribe', '/subscribe', {}, {});
    final subscribedThankyouRoute =
        ParsedRoute('/subscribed_thankyou', '/subscribed_thankyou', {}, {});

    final preconditionsRoute =
        ParsedRoute('/preconditions', '/preconditions', {}, {});
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    final testsRoute = ParsedRoute('/tests/logical', '/tests/logical', {}, {});

    final applicationRoute =
        ParsedRoute('/application', '/application', {}, {});

    // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");
    if (!signedIn && from == subscribeRoute) {
      return subscribeRoute;
    } else if (!signedIn && from == subscribedThankyouRoute) {
      return subscribedThankyouRoute;
    } else if (!signedIn && from == preconditionsRoute && jwt_sub == null) {
      return preconditionsRoute;
    } else if (!signedIn && from != signInRoute) {
      // Go to /signin if the user is not signed in
      return signInRoute;
    } else if (signedIn && from == applyRoute) {
      return applyRoute;
    } else if (signedIn && from == testsRoute) {
      return testsRoute;
    } else if (signedIn && from == applicationRoute) {
      return applicationRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/application', '/application', {}, {});
    } else if (signedIn && jwt_sub != null) {
      return applyRoute;
    }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go('/subscribe');
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
