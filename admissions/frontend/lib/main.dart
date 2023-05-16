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
  //
  // On mobile platforms, both functions are no-ops.
  setHashUrlStrategy();
  // setPathUrlStrategy();

  setupWindow();

  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.forEnvironment('dev');
  AppConfig.choreoSTSClientID = await const String.fromEnvironment(
      'choreo_sts_client_id',
      defaultValue: 'undefined');
  AppConfig.asgardeoClientId = await const String.fromEnvironment(
      'asgardeo_client_id',
      defaultValue: 'undefined');

  log(AppConfig.admissionsApplicationBffApiUrl);
  log(AppConfig.choreoSTSClientID);
  log(AppConfig.asgardeoClientId);

  runApp(const AdmissionsManagementSystem());
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
