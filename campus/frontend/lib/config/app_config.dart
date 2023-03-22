import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static String apiUrl = '';
  static String campusAttendanceBffApiUrl = '';
  static String campusProfileBffApiUrl = '';
  static String campusAttendanceBffApiKey = '';
  static String choreoSTSEndpoint = "";
  static String choreoSTSClientID = "";
  static String asgardeoTokenEndpoint = "";
  static String asgardeoClientId = "";
  static var apiTokens = null;
  static String applicationName = 'Avinya Campus Apps';
  static String applicationVersion = '1.0.0';
  static String mainCampusActivity = 'school-day';
  static String campusPctiNotesBffApiUrl = '';

  static String campusPctiFeedbackBffApiUrl = '';

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
    campusProfileBffApiUrl = json['campusProfileBffApiUrl'];
    campusPctiNotesBffApiUrl = json['campusPctiNotesBffApiUrl'];
    campusPctiNotesBffApiUrl = json['campusPctiNotesBffApiUrl'];
    campusPctiFeedbackBffApiUrl = json['campusPctiFeedbackBffApiUrl'];
    choreoSTSClientID = json['choreo_sts_client_id'];
    asgardeoClientId = json['asgardeo_client_id'];
    choreoSTSEndpoint = json['choreo_sts_endpoint'];
    asgardeoTokenEndpoint = json['asgardeo_token_endpoint'];

    // convert our JSON into an instance of our AppConfig class
    return AppConfig();
  }

  String getApiUrl() {
    return apiUrl;
  }
}
