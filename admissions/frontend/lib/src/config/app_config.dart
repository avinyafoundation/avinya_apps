import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static String apiUrl = '';
  static String admissionsApplicationBffApiUrl = '';
  static String admissionsApplicationBffApiKey = '';
  static String choreoSTSEndpoint = "";
  static String choreoSTSClientID = "";
  static String asgardeoTokenEndpoint = "";
  static String asgardeoClientId = "";
  static var apiTokens = null;
  static String applicationName = 'Avinya Academy Student Admissions Portal';
  static String applicationVersion = '0.2.1';
  static String asgardeoLogoutUrl = '';

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
    admissionsApplicationBffApiUrl = json['admissionsApplicationBffApiUrl'];
    choreoSTSEndpoint = json['choreo_sts_endpoint'];
    asgardeoTokenEndpoint = json['asgardeo_token_endpoint'];
    asgardeoLogoutUrl = json['logout_url'];

    // convert our JSON into an instance of our AppConfig class
    return AppConfig();
  }

  String getApiUrl() {
    return apiUrl;
  }
}
