import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class ActivityAttendance {
  int? id;
  int? activity_instance_id;
  int? person_id;
  String? created;
  String? updated;
  String? sign_in_time;
  String? sign_out_time;

  ActivityAttendance({
    this.id,
    this.activity_instance_id,
    this.person_id,
    this.created,
    this.updated,
    this.sign_in_time,
    this.sign_out_time,
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
      };
}

Future<ActivityAttendance> createActivityAttendance(
    ActivityAttendance activityAttendance) async {
  log(activityAttendance.toString());
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/activity_attendance'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(activityAttendance.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityAttendance.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create Activity Participant Attendance.');
  }
}
