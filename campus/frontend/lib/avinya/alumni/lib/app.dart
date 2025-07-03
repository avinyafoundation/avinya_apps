import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/alumni/lib/app_routes/app_routes.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class AlumniSystem extends StatefulWidget {
  const AlumniSystem({super.key});

  @override
  State<AlumniSystem> createState() => _AlumniSystemState();
}

class _AlumniSystemState extends State<AlumniSystem> {
  final _auth = CampusAppsPortalAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [AppRoutes.alumniDashboardRoute, 
                     AppRoutes.alumniAdminRoute,
                     AppRoutes.createJobPostRoute,
                     AppRoutes.jobPostListRoute],
      guard: _guard,
      // initialRoute: '/signin',
      initialRoute: AppRoutes.alumniDashboardRoute,
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
                  backgroundColor: Colors.blueGrey[700],
                  //width: 270.0,
                ),
                appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey[400]),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Colors.blueGrey[400],
                ),
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();

    final alumniDashboardReportRoute = ParsedRoute(
        AppRoutes.alumniDashboardRoute, AppRoutes.alumniDashboardRoute, {}, {});

    final alumniAdminRoute =
        ParsedRoute(AppRoutes.alumniAdminRoute, AppRoutes.alumniAdminRoute, {}, {});

    final createJobPostRoute =
        ParsedRoute(AppRoutes.createJobPostRoute, AppRoutes.createJobPostRoute, {}, {});
    
    final jobPostListRoute = ParsedRoute(
        AppRoutes.jobPostListRoute, AppRoutes.jobPostListRoute, {}, {});

    if (signedIn && from == alumniDashboardReportRoute) {
      return alumniDashboardReportRoute;
    } else if (signedIn && from == alumniAdminRoute) {
      return alumniAdminRoute;
    } else if (signedIn && from == createJobPostRoute){
      return createJobPostRoute;
    } else if (signedIn && from == jobPostListRoute){
      return jobPostListRoute;
    }
    // } else if (signedIn && from == signInRoute) {
    //   ParsedRoute('/enrollment_dashboard', '/enrollment_dashboard', {}, {});
    // }

    log("_guard signed in2 $signedIn");
    // } else if (signedIn && jwt_sub != null) {
    //   return resourceAllocationRoute;
    // }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      _routeState.go(AppRoutes.alumniDashboardRoute);
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
