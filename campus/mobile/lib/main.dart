// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/auth.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/gallery_options.dart';
import 'package:mobile/pages/backdrop.dart';
import 'package:mobile/pages/splash.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/themes/gallery_theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:sizer/sizer.dart';
import 'package:url_strategy/url_strategy.dart';

import 'config/app_config.dart';

void main() async {
  // Use package:url_strategy until this pull request is released:
  // https://github.com/flutter/flutter/pull/77103

  // Use to setHashUrlStrategy() to use "/#/" in the address bar (default). Use
  // setPathUrlStrategy() to use the path. You may need to configure your web
  // server to redirect all paths to index.html.
  //
  // On mobile platforms, both functions are no-ops.
  setHashUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  String? currentEnvironment = Constants.currentEnvironment;

  if (currentEnvironment == 'prod') {
    // get variables from prod environment config.json
    await AppConfig.forEnvironment('prod');
    AppConfig.choreoSTSClientID = Constants.choreoSTSClientID;
    AppConfig.asgardeoClientId = Constants.asgardeoClientId;
  } else if (currentEnvironment == 'stag') {
    // get variables from stag environment config.json
    await AppConfig.forEnvironment('stag');
    AppConfig.choreoSTSClientID = Constants.choreoSTSClientID;
    AppConfig.asgardeoClientId = Constants.asgardeoClientId;
  } else if (currentEnvironment == 'dev-cloud') {
    // get variables from dev-cloud environment config.json
    await AppConfig.forEnvironment('dev-cloud');
    AppConfig.choreoSTSClientID = Constants.choreoSTSClientID;
    AppConfig.asgardeoClientId = Constants.asgardeoClientId;
  } else {
    await AppConfig.forEnvironment('dev');
  }

  String _clientId = AppConfig.asgardeoClientId;
  final String _issuerUrl = AppConfig.asgardeoTokenEndpoint;
  final String _redirectUrl = AppConfig.redirectURL;
  final String _discoveryUrl = AppConfig.asgardeoDiscoveryURL;

  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'groups',
    'address',
    'phone'
  ];

  await authenticate(
      Uri.parse(_issuerUrl), _clientId, _scopes, _redirectUrl, _discoveryUrl);

  // google_fonts.GoogleFonts.config.allowRuntimeFetching = false;
  GalleryApp galleryApp = GalleryApp();
  campusAppsPortalInstance.setAuth(galleryApp._auth);
  bool signedIn = await campusAppsPortalInstance.getSignedIn();
  log('signedIn 1: $signedIn! ');

  signedIn = await galleryApp._auth.getSignedIn();
  campusAppsPortalInstance.setSignedIn(signedIn);
  runApp(GalleryApp());
}

/// Environment variables and shared app constants.
abstract class Constants {
  static const String currentEnvironment = String.fromEnvironment(
    'ENV',
    defaultValue: '',
  );

  static const String choreoSTSClientID = String.fromEnvironment(
    'choreo_sts_client_id',
    defaultValue: '',
  );

  static const String asgardeoClientId = String.fromEnvironment(
    'asgardeo_client_id',
    defaultValue: '',
  );
}

Future<void> authenticate(Uri uri, String clientId, List<String> scopes,
    String redirectURL, String discoveryUrl) async {
  const FlutterAppAuth flutterAppAuth = FlutterAppAuth();

  try {
    final AuthorizationTokenResponse? result =
        await flutterAppAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectURL,
        discoveryUrl: discoveryUrl,
        promptValues: ['login'],
        scopes: scopes,
      ),
    );

    print('Access token bla bla bla: ${result?.accessToken}');
    String accessToken = result?.accessToken ?? '';
    String refreshToken = result?.refreshToken ?? '';
    String idToken = result?.idToken ?? '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('id_token', idToken);

    // final _auth = CampusAppsPortalAuth();
    // final signedIn = await _auth.getSignedIn();

    // setState(() {
    //   _isUserLoggedIn = true;
    //   _idToken = result?.idToken;
    //   _accessToken = result?.accessToken;
    //   _pageIndex = 2;
    // });
  } catch (e, s) {
    print('Error while login to the system: $e - stack: $s');
    // setState(() {
    //   _isUserLoggedIn = false;
    // });
  }
}

class GalleryApp extends StatefulWidget {
  // GalleryApp({super.key});
  GalleryApp({
    super.key,
    this.initialRoute,
    this.isTestMode = false,
  });
  late final String? initialRoute;
  late final bool isTestMode;
  final _auth = CampusAppsPortalAuth();

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _GalleryAppState extends State<GalleryApp> {
  late final String loginRoute = '/signin';
  get isTestMode => false;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return ModelBinding(
          initialModel: GalleryOptions(
            themeMode: ThemeMode.system,
            textScaleFactor: systemTextScaleFactorOption,
            customTextDirection: CustomTextDirection.localeBased,
            locale: null,
            timeDilation: timeDilation,
            platform: defaultTargetPlatform,
            isTestMode: isTestMode,
          ),
          child: Builder(
            builder: (context) {
              final options = GalleryOptions.of(context);
              return MaterialApp(
                  restorationScopeId: 'rootGallery',
                  title: 'Avinya Academy',
                  debugShowCheckedModeBanner: false,
                  navigatorObservers: [routeObserver],
                  themeMode: options.themeMode,
                  theme: GalleryThemeData.lightThemeData.copyWith(
                    platform: options.platform,
                  ),
                  darkTheme: GalleryThemeData.darkThemeData.copyWith(
                    platform: options.platform,
                  ),
                  initialRoute: loginRoute,
                  locale: options.locale,
                  localeListResolutionCallback: (locales, supportedLocales) {
                    deviceLocale = locales?.first;
                    return basicLocaleListResolution(locales, supportedLocales);
                  },
                  onGenerateRoute: (settings) {
                    return RouteConfiguration.onGenerateRoute(settings);
                  },
                  onUnknownRoute: (RouteSettings settings) {
                    return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (BuildContext context) =>
                          Scaffold(body: Center(child: Text('Not Found'))),
                    );
                  });
            },
          ),
        );
      },
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: SplashPage(
        child: Backdrop(),
      ),
    );
  }
}
