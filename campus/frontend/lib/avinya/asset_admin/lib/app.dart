import 'dart:developer';

//import 'package:ShoolManagementSystem/src/data/campus_config_system.dart';
//import 'package:ShoolManagementSystem/src/data/resource_allocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gallery/auth.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/src/material_localizations.dart';
import 'package:oktoast/oktoast.dart';

//import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class AssetAdminSystem extends StatefulWidget {
  const AssetAdminSystem({super.key});

  @override
  State<AssetAdminSystem> createState() => _AssetAdminSystemState();
}

class _AssetAdminSystemState extends State<AssetAdminSystem> {
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
        '/resource_allocation_report',
        '/resource_allocations/:id',
        '/asset_dashboard',
        '/consumable_dashboard',
        '/stock_replenishment',
        '/stock_depletion',
        '/consumable_monthly_report',
        '/consumable_weekly_report',
        '/vehicle_fuel_consumption',
        '/vehicle_fuel_consumption_monthly_report',
        // '/assets/new',
        // '/assets/all',
        // '/assets/popular',
        // '/asset/:id',
        // '/asset/new',
        // '/asset/edit',
        '/#access_token',
      ],
      guard: _guard,
      // initialRoute: '/signin',
      initialRoute: '/consumable_dashboard',
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
                  backgroundColor: Colors.yellow[700],
                  //width: 270.0,
                ),
                appBarTheme: AppBarTheme(backgroundColor: Colors.yellow[700]),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Colors.yellow[700],
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

    final resourceAllocationReportRoute = ParsedRoute(
        '/resource_allocation_report', '/resource_allocation_report', {}, {});

    final assetDashboardReportRoute =
        ParsedRoute('/asset_dashboard', '/asset_dashboard', {}, {});

    final consumableDashboardReportRoute =
        ParsedRoute('/consumable_dashboard', '/consumable_dashboard', {}, {});

    final stockReplenishmentRoute =
        ParsedRoute('/stock_replenishment', '/stock_replenishment', {}, {});

    final stockDepletionRoute =
        ParsedRoute('/stock_depletion', '/stock_depletion', {}, {});

    final consumableMonthlyReportRoute = ParsedRoute(
        '/consumable_monthly_report', '/consumable_monthly_report', {}, {});

    final consumableWeeklyReportRoute = ParsedRoute(
        '/consumable_weekly_report', '/consumable_weekly_report', {}, {});
    
    final vehicleFuelConsumptionRoute = ParsedRoute(
        '/vehicle_fuel_consumption', '/vehicle_fuel_consumption', {}, {});
    
    final vehicleFuelConsumptionMonthlyReportRoute = ParsedRoute(
        '/vehicle_fuel_consumption_monthly_report', '/vehicle_fuel_consumption_monthly_report', {}, {});


    // // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");

    if (signedIn && from == resourceAllocationReportRoute) {
      return resourceAllocationReportRoute;
    } else if (signedIn && from == assetDashboardReportRoute) {
      return assetDashboardReportRoute;
    } else if (signedIn && from == consumableDashboardReportRoute) {
      return consumableDashboardReportRoute;
    } else if (signedIn && from == stockReplenishmentRoute) {
      return stockReplenishmentRoute;
    } else if (signedIn && from == stockDepletionRoute) {
      return stockDepletionRoute;
    } else if (signedIn && from == consumableMonthlyReportRoute) {
      return consumableMonthlyReportRoute;
    } else if (signedIn && from == consumableWeeklyReportRoute) {
      return consumableWeeklyReportRoute;
    } else if (signedIn && from == vehicleFuelConsumptionRoute) {
      return vehicleFuelConsumptionRoute;
    } else if (signedIn && from == vehicleFuelConsumptionMonthlyReportRoute) {
      return vehicleFuelConsumptionMonthlyReportRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/asset_dashboard', '/asset_dashboard', {}, {});
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
      _routeState.go('/consumable_dashboard');
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
