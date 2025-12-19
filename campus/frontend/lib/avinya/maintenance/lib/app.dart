import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/maintenance/lib/app_routes/app_routes.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//import 'auth.dart';
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
        AppRoutes.maintenanceDashboardRoute,
        AppRoutes.addLocationRoute,
        AppRoutes.kanbanBoardRoute,
        AppRoutes.taskDetailsRoute,
        AppRoutes.addTaskRoute,
        AppRoutes.financeApprovalsRoute,
      ],
      guard: _guard,
      // initialRoute: '/signin',
      initialRoute: AppRoutes.maintenanceDashboardRoute,
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
          child: OKToast(
            child: MaterialApp.router(
              localizationsDelegates: [
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
              ],
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
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();

    final maintenanceDashboardRoute = ParsedRoute(
        AppRoutes.maintenanceDashboardRoute,
        AppRoutes.maintenanceDashboardRoute, {}, {});

    final addLocationRoute = ParsedRoute(
        AppRoutes.addLocationRoute, AppRoutes.addLocationRoute, {}, {});

    final kanbanBoardRoute = ParsedRoute(
        AppRoutes.kanbanBoardRoute, AppRoutes.kanbanBoardRoute, {}, {});

    final taskDetailsRoute = ParsedRoute(
        AppRoutes.taskDetailsRoute, AppRoutes.taskDetailsRoute, {}, {});    

    final addTaskRoute = ParsedRoute(
        AppRoutes.addTaskRoute, AppRoutes.addTaskRoute, {}, {});

    final financeApprovalsRoute = ParsedRoute(
        AppRoutes.financeApprovalsRoute, AppRoutes.financeApprovalsRoute, {}, {});    

    if (signedIn && from == maintenanceDashboardRoute) {
      return maintenanceDashboardRoute;
    } else if (signedIn && from == addLocationRoute) {
      return addLocationRoute;
    } else if (signedIn && from == kanbanBoardRoute) {
      return kanbanBoardRoute;
    }
    else if (signedIn && from == taskDetailsRoute) {
      return taskDetailsRoute;
    } else if (signedIn && from == addTaskRoute) {
      return addTaskRoute;
    }
    else if (signedIn && from == financeApprovalsRoute) {
      return financeApprovalsRoute;
    }
    // else if (signedIn && from == studentsRoute) {
    //   return studentsRoute;
    // } else if (signedIn && from == signInRoute) {
    //   ParsedRoute('/enrollment_dashboard', '/enrollment_dashboard', {}, {});
    // }

    log("_guard signed in2 $signedIn");
    // } else if (signedIn && jwt_sub != null) {
    //   return resourceAllocationRoute;
    // }
    return ParsedRoute('/signin', '/signin', {}, {});
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      // _routeState.go('/signin');
      _routeState.go(AppRoutes.maintenanceDashboardRoute);
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
