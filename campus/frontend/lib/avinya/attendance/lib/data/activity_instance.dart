import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery/config/app_config.dart';

class ActivityInstance {
  int? id;
  int? activity_id;
  String? name;
  String? description;
  String? notes;
  String? created;
  String? updated;
  String? record_type;
  String? start_time;
  String? end_time;
  int? daily_sequence;
  int? weekly_sequence;
  int? monthly_sequence;
  int? place_id;

  ActivityInstance({
    this.id,
    this.activity_id,
    this.name,
    this.description,
    this.notes,
    this.created,
    this.updated,
    this.record_type,
    this.start_time,
    this.end_time,
    this.daily_sequence,
    this.weekly_sequence,
    this.monthly_sequence,
    this.place_id,
  });

  factory ActivityInstance.fromJson(Map<String, dynamic> json) {
    return ActivityInstance(
      id: json['id'],
      activity_id: json['activity_id'],
      name: json['name'],
      description: json['description'],
      notes: json['notes'],
      created: json['created'],
      updated: json['updated'],
      record_type: json['record_type'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      daily_sequence: json['daily_sequence'],
      weekly_sequence: json['weekly_sequence'],
      monthly_sequence: json['monthly_sequence'],
      place_id: json['place_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_id != null) 'activity_id': activity_id,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        if (record_type != null) 'record_type': record_type,
        if (start_time != null) 'start_time': start_time,
        if (end_time != null) 'end_time': end_time,
        if (daily_sequence != null) 'daily_sequence': daily_sequence,
        if (weekly_sequence != null) 'weekly_sequence': weekly_sequence,
        if (monthly_sequence != null) 'monthly_sequence': monthly_sequence,
        if (place_id != null) 'place_id': place_id,
      };
}

Future<List<ActivityInstance>> fetchActivityInstance(int activityID) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/activity_instances_today/$activityID'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityInstance> activityInstances = await resultsJson
        .map<ActivityInstance>((json) => ActivityInstance.fromJson(json))
        .toList();
    return activityInstances;
  } else {
    throw Exception('Failed to load Activity');
  }
}
