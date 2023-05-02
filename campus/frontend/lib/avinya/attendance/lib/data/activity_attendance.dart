import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gallery/config/app_config.dart';

class ActivityAttendance {
  int? id;
  int? activity_instance_id;
  int? person_id;
  String? created;
  String? updated;
  String? sign_in_time;
  String? sign_out_time;
  String? in_marked_by;
  String? out_marked_by;
  bool? selected = false;

  ActivityAttendance({
    this.id,
    this.activity_instance_id,
    this.person_id,
    this.created,
    this.updated,
    this.sign_in_time,
    this.sign_out_time,
    this.in_marked_by,
    this.out_marked_by,
  });

  factory ActivityAttendance.fromJson(Map<String, dynamic> json) {
    return ActivityAttendance(
      id: json['id'],
      activity_instance_id: json['activity_instance_id'],
      person_id: json['person_id'],
      created: json['created'],
      updated: json['updated'],
      sign_in_time: json['sign_in_time'],
      sign_out_time: json['sign_out_time'],
      in_marked_by: json['in_marked_by'],
      out_marked_by: json['out_marked_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_instance_id != null)
          'activity_instance_id': activity_instance_id,
        if (person_id != null) 'person_id': person_id,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        if (sign_in_time != null) 'sign_in_time': sign_in_time,
        if (sign_out_time != null) 'sign_out_time': sign_out_time,
        if (in_marked_by != null) 'in_marked_by': in_marked_by,
        if (out_marked_by != null) 'out_marked_by': out_marked_by,
      };
}

Future<ActivityAttendance> createActivityAttendance(
    ActivityAttendance activityAttendance) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/activity_attendance'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(activityAttendance.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityAttendance.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create Activity Participant Attendance.');
  }
}

Future<int> deleteActivityAttendance(int id) async {
  final response = await http.delete(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/activity_attendance/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return int.parse(response.body);
  } else {
    throw Exception('Failed to create Activity Participant Attendance.');
  }
}

Future<List<ActivityAttendance>> getClassActivityAttendanceToday(
    int organization_id, int activity_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/class_attendance_today/$organization_id/$activity_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityAttendance> activityAttendances = await resultsJson
        .map<ActivityAttendance>((json) => ActivityAttendance.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance for calss org ID $organization_id and activity $activity_id for today.');
  }
}

Future<List<ActivityAttendance>> getPersonActivityAttendanceToday(
    int person_id, int activity_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/person_attendance_today/$person_id/$activity_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityAttendance> activityAttendances = await resultsJson
        .map<ActivityAttendance>((json) => ActivityAttendance.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance for calss person ID $person_id and activity $activity_id for today.');
  }
}

Future<List<ActivityAttendance>> getPersonActivityAttendanceReport(
    int person_id, int activity_id, int result_limit) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/person_attendance_report/$person_id/$activity_id/$result_limit'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityAttendance> activityAttendances = await resultsJson
        .map<ActivityAttendance>((json) => ActivityAttendance.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance report for person ID $person_id and activity $activity_id for result limit.$result_limit');
  }
}

Future<List<ActivityAttendance>> getClassActivityAttendanceReport(
    int organization_id, int activity_id, int result_limit) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/class_attendance_report/$organization_id/$activity_id/$result_limit'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityAttendance> activityAttendances = await resultsJson
        .map<ActivityAttendance>((json) => ActivityAttendance.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance report for organization ID $organization_id and activity $activity_id for result limit.$result_limit');
  }
}
