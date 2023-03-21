import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static String apiUrl = 'http://localhost:8080';
  static String campusAttendanceBffApiUrl = 'http://localhost:6060';
  static String campusProfileBffApiUrl =
      'https://3a907137-52a3-4196-9e0d-22d054ea5789-dev.e1-us-east-azure.choreoapis.dev/fieg/profile-bff/1.0.0';
  static String campusAttendanceBffApiKey = '';
  static String choreoSTSEndpoint = "https://sts.choreo.dev/oauth2/token";
  static String choreoSTSClientID = "x23_1tY7kAUtLUH9il9I3YwyrJca";
  static String asgardeoTokenEndpoint =
      "https://api.asgardeo.io/t/avinyatest/oauth2/token";
  static String asgardeoClientId = "pJ2gM2o6yXN4f60FypEYWWERrAoa";
  static var apiTokens = null;
  static String applicationName = 'Avinya Academy Campus - Config Portal';
  static String applicationVersion = '0.1.0';
  static String mainCampusActivity = 'school-day';

  //AppConfig({required this.apiUrl});

  static Future<AppConfig> forEnvironment(String env) async {
    // load the json file
    String contents = "{}";
    try {
      contents = await rootBundle.loadString(
        'assets/config/$env.json',
      );
    } catch (e) {
      print(e);
    }

    // decode our json
    final json = jsonDecode(contents);
    campusAttendanceBffApiUrl = json['campusAttendanceBffApiUrl'];

    // convert our JSON into an instance of our AppConfig class
    return AppConfig();
  }

  String getApiUrl() {
    return apiUrl;
  }
}
