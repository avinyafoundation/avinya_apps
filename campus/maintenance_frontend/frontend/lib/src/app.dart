import 'package:flutter/material.dart';
import 'package:maintenance_management_system/src/app_routes/app_routes.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class MaintenanceManagementSystem extends StatefulWidget {
  const MaintenanceManagementSystem({super.key});

  @override
  State<MaintenanceManagementSystem> createState() =>
      _MaintenanceManagementSystemState();
}

class _MaintenanceManagementSystemState
    extends State<MaintenanceManagementSystem> {
  final _auth = SMSAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [AppRoutes.kanbanBoardRoute],
      guard: _guard,
      initialRoute: AppRoutes.kanbanBoardRoute,
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
              drawerTheme: DrawerThemeData(
                backgroundColor: Colors.lightBlueAccent[700],
                //width: 270.0,
              ),
              appBarTheme:
                  AppBarTheme(backgroundColor: Colors.lightBlueAccent[400]),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.lightBlueAccent[400],
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();

    final kanbanBoardRoute = ParsedRoute(
        AppRoutes.kanbanBoardRoute,
        AppRoutes.kanbanBoardRoute, {}, {});
    
    if (signedIn && from == kanbanBoardRoute) {
      return kanbanBoardRoute;
    }
    // } else if (!signedIn && from == subscribedThankyouRoute) {
    //   return subscribedThankyouRoute;

    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go(AppRoutes.kanbanBoardRoute);
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
