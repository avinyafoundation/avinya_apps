import 'dart:developer';

import 'package:campus_pcti_admin/data/activity_instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Activity {
  String? notes;
  List<Activity>? parent_activities;
  String? created;
  String? name;
  int? avinya_type_id;
  List<Activity>? child_activities;
  String? description;
  int? id;
  String? updated;
  List<ActivityInstance>? activity_instances;

  Activity({
    this.notes,
    this.parent_activities,
    this.created,
    this.name,
    this.avinya_type_id,
    this.child_activities,
    this.description,
    this.id,
    this.updated,
    this.activity_instances,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      notes: json['notes'],
      created: json['created'],
      updated: json['updated'],
      avinya_type_id: json['avinya_type_id'],
      parent_activities: json['parent_activities']
          ?.map<Activity>((activity_json) => Activity.fromJson(activity_json))
          ?.toList(),
      child_activities: json['child_activities']
          ?.map<Activity>((activity_json) => Activity.fromJson(activity_json))
          ?.toList(),
      activity_instances: json['activity_instances']
          ?.map<ActivityInstance>((activity_instance_json) =>
              ActivityInstance.fromJson(activity_instance_json))
          ?.toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        if (avinya_type_id != null) 'avinya_type_id': avinya_type_id,
        if (parent_activities != null)
          'parent_activities':
              parent_activities?.map((activity) => activity.toJson()).toList(),
        if (child_activities != null)
          'child_activities':
              child_activities?.map((activity) => activity.toJson()).toList(),
        if (activity_instances != null)
          'activity_instances': activity_instances
              ?.map((activity_instance) => activity_instance.toJson())
              .toList(),
      };
}

Future<List<Activity>> fetchActivitys() async {
  final response = await http
      .get(Uri.parse(AppConfig.campusPctiBffApiUrl + '/activity'));

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Activity> activitys = await resultsJson
        .map<Activity>((json) => Activity.fromJson(json))
        .toList();
    return activitys;
  } else {
    throw Exception('Failed to load Activity');
  }
}

Future<Activity> fetchActivity(String name) async {
  final response = await http
      .get(Uri.parse(AppConfig.campusPctiBffApiUrl + '/activity/$name'));

  if (response.statusCode == 200) {
    //var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    // Activity activity =
    //     await resultsJson.map<Activity>((json) => Activity.fromJson(json));
    log(response.body);
    Activity activity = Activity.fromJson(json.decode(response.body));
    return activity;
  } else {
    throw Exception('Failed to load Activity');
  }
}

Future<http.Response> createActivity(Activity activity) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusPctiBffApiUrl + '/activity'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(activity.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Activity.');
  }
}

Future<http.Response> updateActivity(Activity activity) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusPctiBffApiUrl + '/activity'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(activity.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Activity.');
  }
}

Future<http.Response> deleteActivity(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusPctiBffApiUrl + '/activity/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Activity.');
  }
}