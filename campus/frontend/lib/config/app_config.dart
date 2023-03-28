import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static String apiUrl = '';
  static String campusAttendanceBffApiUrl = '';
  static String campusProfileBffApiUrl = '';
  static String campusAttendanceBffApiKey = '';
  static String campusProfileBffApiKey = '';
  static String campusPctiNotesBffApiKey = '';
  static String campusPctiFeedbackBffApiKey = '';
  static String campusAssetsBffApiKey = '';
  static String choreoSTSEndpoint = "";
  static String choreoSTSClientID = "x23_1tY7kAUtLUH9il9I3YwyrJca";
  static String asgardeoTokenEndpoint = "";
  static String asgardeoClientId = "pJ2gM2o6yXN4f60FypEYWWERrAoa";
  static var apiTokens = null;
  static String applicationName = 'Avinya Campus Apps';
  static String applicationVersion = '1.0.0';
  static String mainCampusActivity = 'school-day';
  static String campusPctiNotesBffApiUrl = '';
  static String campusAssetsBffApiUrl = '';

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
    campusAssetsBffApiUrl = json['campusAssetsBffApiUrl'];
    choreoSTSEndpoint = json['choreo_sts_endpoint'];
    asgardeoTokenEndpoint = json['asgardeo_token_endpoint'];

    // convert our JSON into an instance of our AppConfig class
    return AppConfig();
  }

  String getApiUrl() {
    return apiUrl;
  }
}
