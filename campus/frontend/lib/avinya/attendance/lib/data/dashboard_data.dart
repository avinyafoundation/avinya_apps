import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/screens/dashboard/constants.dart';
import 'package:http/http.dart' as http;
import 'package:gallery/config/app_config.dart';
import 'dart:convert';

class DashboardData {
  final String? svgSrc, title, totalStudents;
  final int? numOfFiles;
  final double? percentage;
  final Color? color;

  DashboardData({
    this.svgSrc,
    this.title,
    this.totalStudents,
    this.numOfFiles,
    this.percentage,
    this.color,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['attendance_dashboard_data']; // Access the nested data

    return DashboardData(
      svgSrc: data['svgSrc'],
      title: data['title'],
      totalStudents: data['totalStudents'], // Update key here
      numOfFiles: data['numOfFiles'],
      color: _parseColor(data['color']),
      percentage: data['percentage'],
    );
  }
  static Color? _parseColor(String? colorString) {
    if (colorString == null) {
      return null;
    }

    final hexColorRegExp = RegExp(r'^#?([0-9a-fA-F]{6})$');
    if (!hexColorRegExp.hasMatch(colorString)) {
      // Invalid hex color code, handle accordingly
      print("Invalid hex color code: $colorString");
      return null; // or return a default color, like Colors.grey
    }

    try {
      // Assuming colorString is a hex color representation
      return Color(int.parse(colorString.replaceAll("#", ""), radix: 16));
    } catch (e) {
      // Handle the exception, e.g., return a default color or null
      print("Error parsing color: $e");
      return null; // or return a default color, like Colors.grey
    }
  }
}

Future<List<DashboardData>> getDashboardCardDataByDate(
    String from_date, String to_date, int? organization_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/attendance_dashboard_card_data/$from_date/$to_date/$organization_id/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<DashboardData> cardData = await resultsJson
        .map<DashboardData>((json) => DashboardData.fromJson(json))
        .toList();
    return cardData;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance for calss org ID $organization_id');
  }
}

Future<List<DashboardData>> getDashboardCardDataByParentOrg(
    String from_date, String to_date, int? parent_organization_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/attendance_dashboard_card_data_by_parent_org/$from_date/$to_date/$parent_organization_id/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<DashboardData> cardData = await resultsJson
        .map<DashboardData>((json) => DashboardData.fromJson(json))
        .toList();
    print(cardData.length);

    return cardData;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance for calss org ID $parent_organization_id');
  }
}

// Future<List<DashboardData>> getDashboardCardDataByParentOrg(
//     String from_date, String to_date, int? parent_organization_id) async {
//   final response = await http.get(
//     Uri.parse(
//         '${AppConfig.campusAttendanceBffApiUrl}/attendance_dashboard_card_data_by_parent_org/$from_date/$to_date/$parent_organization_id/'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'accept': 'application/json',
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//     },
//   );
  
//   if (response.statusCode > 199 && response.statusCode < 300) {
//     var jsonResponse = json.decode(response.body);
    
//     if (jsonResponse['attendance_dashboard_data'] != null) {
//       var resultsJson = jsonResponse['attendance_dashboard_data'].cast<Map<String, dynamic>>();
//       List<DashboardData> cardData = await resultsJson
//           .map<DashboardData>((json) => DashboardData.fromJson(json))
//           .toList();
//       return cardData;
//     } else {
//       // If the response data is null, return the default cardData list
//       return List<DashboardData>.from(cardData);
//     }
//   } else {
//     throw Exception(
//         'Failed to get Activity Participant Attendance for class org ID $parent_organization_id');
//   }
// }

