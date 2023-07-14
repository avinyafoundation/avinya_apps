import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_size/window_size.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';

Future<void> main() async {
  // Use package:url_strategy until this pull request is released:
  // https://github.com/flutter/flutter/pull/77103

  // Use to setHashUrlStrategy() to use "/#/" in the address bar (default). Use
  // setPathUrlStrategy() to use the path. You may need to configure your web
  // server to redirect all paths to index.html.
  // On mobile platforms, both functions are no-ops.
  setHashUrlStrategy();
  // setPathUrlStrategy();

  setupWindow();

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

  log(AppConfig.admissionsApplicationBffApiUrl);
  log(AppConfig.choreoSTSClientID);
  log(AppConfig.asgardeoClientId);

  runApp(const AdmissionsManagementSystem());
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

const double windowWidth = 480;
const double windowHeight = 854;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Admissions Application Management System');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}
