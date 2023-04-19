// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/pages/backdrop.dart';
import 'package:gallery/pages/splash.dart';
import 'package:gallery/routes.dart';
import 'package:gallery/themes/gallery_theme_data.dart';
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

  // Define environment constants
  const bool kProductionMode = bool.fromEnvironment('dart.vm.product');
  const bool kStagingMode = bool.fromEnvironment('dart.vm.staging');
  const bool kDevelopmentMode = bool.fromEnvironment('dart.vm.development');

  Future<void> initializeAppConfig() async {
    if (kProductionMode) {
      // get variables from prod environment config.json
      await AppConfig.forEnvironment('prod');
      AppConfig.choreoSTSClientID = await String.fromEnvironment(
          'choreo_sts_client_id',
          defaultValue: 'undefined');
    } else if (kStagingMode) {
      // get variables from stag environment config.json
      await AppConfig.forEnvironment('stag');
      AppConfig.choreoSTSClientID = await String.fromEnvironment(
          'choreo_sts_client_id',
          defaultValue: 'undefined');
    } else if (kDevelopmentMode) {
      // get variables from dev-cloud environment config.json
      await AppConfig.forEnvironment('dev-cloud');
      AppConfig.choreoSTSClientID = await String.fromEnvironment(
          'choreo_sts_client_id',
          defaultValue: 'undefined');
    } else {
      // get variables from dev environment config.json
      await AppConfig.forEnvironment('dev');
    }
  }

  // Call initializeAppConfig() before using AppConfig variables
  await initializeAppConfig();

  // google_fonts.GoogleFonts.config.allowRuntimeFetching = false;
  GalleryApp galleryApp = GalleryApp();
  campusAppsPortalInstance.setAuth(galleryApp._auth);
  bool signedIn = await campusAppsPortalInstance.getSignedIn();
  log('signedIn 1: $signedIn! ');

  signedIn = await galleryApp._auth.getSignedIn();
  campusAppsPortalInstance.setSignedIn(signedIn);
  runApp(GalleryApp());
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
                  localizationsDelegates: const [
                    ...GalleryLocalizations.localizationsDelegates,
                    LocaleNamesLocalizationsDelegate()
                  ],
                  initialRoute: loginRoute,
                  supportedLocales: GalleryLocalizations.supportedLocales,
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
