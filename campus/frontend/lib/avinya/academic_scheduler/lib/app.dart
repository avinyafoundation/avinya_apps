import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/src/material_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class AcademicSchedulerSystem extends StatefulWidget {
  const AcademicSchedulerSystem({super.key});

  @override
  State<AcademicSchedulerSystem> createState() => _AcademicSchedulerSystemState();
}

class _AcademicSchedulerSystemState extends State<AcademicSchedulerSystem> {
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
        '/academic_scheduler_dashboard',
        '/#access_token',
      ],
      guard: _guard,
      // initialRoute: '/signin',
      initialRoute: '/academic_scheduler_dashboard',
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

    final enrollmentDashboardReportRoute =
        ParsedRoute('/academic_scheduler_dashboard', '/academic_scheduler_dashboard', {}, {});

    if (signedIn && from == enrollmentDashboardReportRoute) {
      return enrollmentDashboardReportRoute;
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
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    if (!signedIn) {
      // _routeState.go('/signin');
      _routeState.go('/academic_scheduler_dashboard');
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
