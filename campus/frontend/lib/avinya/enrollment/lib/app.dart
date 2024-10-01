import 'dart:developer';

//import 'package:ShoolManagementSystem/src/data/campus_config_system.dart';
//import 'package:ShoolManagementSystem/src/data/resource_allocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/src/material_localizations.dart';
import 'package:oktoast/oktoast.dart';

//import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class EnrollmentSystem extends StatefulWidget {
  const EnrollmentSystem({super.key});

  @override
  State<EnrollmentSystem> createState() => _EnrollmentSystemState();
}

class _EnrollmentSystemState extends State<EnrollmentSystem> {
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
        '/enrollment_dashboard',
        '/students',
        '/#access_token',
      ],
      guard: _guard,
      // initialRoute: '/signin',
      initialRoute: '/enrollment_dashboard',
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
                MonthYearPickerLocalizations.delegate,
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
                  backgroundColor: Colors.tealAccent[700],
                  //width: 270.0,
                ),
                appBarTheme:
                    AppBarTheme(backgroundColor: Colors.tealAccent[400]),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Colors.tealAccent[400],
                ),
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();
    // String? jwt_sub = campusConfigSystemInstance.getJWTSub();

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    final enrollmentDashboardReportRoute =
        ParsedRoute('/enrollment_dashboard', '/enrollment_dashboard', {}, {});

    final studentsRoute = ParsedRoute('/students', '/students', {}, {});

    // // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");

    if (signedIn && from == enrollmentDashboardReportRoute) {
      return enrollmentDashboardReportRoute;
    } else if (signedIn && from == studentsRoute) {
      return studentsRoute;
    } else if (signedIn && from == signInRoute) {
      ParsedRoute('/enrollment_dashboard', '/enrollment_dashboard', {}, {});
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
      // _routeState.go('/signin');
      _routeState.go('/enrollment_dashboard');
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
