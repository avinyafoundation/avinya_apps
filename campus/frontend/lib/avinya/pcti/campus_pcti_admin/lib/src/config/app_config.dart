import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static String apiUrl = 'http://localhost:8080';
  static String campusPctiBffApiUrl = 'http://localhost:9091';
  static String campusConfigBffApiKey = '';
  static String choreoSTSEndpoint = "https://sts.choreo.dev/oauth2/token";
  static String choreoSTSClientID = "";
  static String asgardeoTokenEndpoint =
      "https://api.asgardeo.io/t/avinyafoundation/oauth2/token";
  static String asgardeoClientId = "";
  static var apiTokens = null;
  static String applicationName = 'Avinya Academy Campus - Config Portal';
  static String applicationVersion = '0.1.0';

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
    campusPctiBffApiUrl = json['campusPctiBffApiUrl'];

    // convert our JSON into an instance of our AppConfig class
    return AppConfig();
  }

  String getApiUrl() {
    return apiUrl;
  }
}
