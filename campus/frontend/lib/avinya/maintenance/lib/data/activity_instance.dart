import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/activity_participant.dart';
import '../data/maintenance_finance.dart';
import '../data/maintenance_task.dart';
//import 'package:gallery/config/app_config.dart';

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
  List<ActivityParticipant>? activityParticipants;
  MaintenanceFinance? financialInformation;
  MaintenanceTask? maintenanceTask;
  String? taskStatus;

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
    this.activityParticipants,
    this.financialInformation,
    this.maintenanceTask,
    this.taskStatus,
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
      activityParticipants: json['activityParticipants'] != null
          ? (json['activityParticipants'] as List)
              .map((item) => ActivityParticipant.fromJson(item))
              .toList()
          : null,
      financialInformation: json['financialInformation'] != null
          ? MaintenanceFinance.fromJson(json['financialInformation'])
          : null,
      maintenanceTask: json['maintenanceTask'] != null
          ? MaintenanceTask.fromJson(json['maintenanceTask'])
          : null,
      taskStatus: json['taskStatus'],
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
        if (activityParticipants != null)
          'activityParticipants':
              activityParticipants!.map((ap) => ap.toJson()).toList(),
        if (financialInformation != null)
          'financialInformation': financialInformation!.toJson(),
        if (maintenanceTask != null)
          'maintenanceTask': maintenanceTask!.toJson(),
        if (taskStatus != null) 'taskStatus': taskStatus,
      };
}

Future<List<ActivityInstance>> fetchActivityInstance(int activityID) async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/activity_instances_today/$activityID'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
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



//Get activity instances
Future<List<ActivityInstance>> getOrganizationTasks({
  required int organizationId,
  List<int>? personId,
  String? fromDate,
  String? toDate,
  String? taskStatus,
  String? financialStatus,
  String? taskType,
  int? location,
  int? limit,
  int? offset,
  bool includeFinance = false,
}) async {
  // Build query parameters
  Map<String, String> queryParams = {
    if (personId != null && personId.isNotEmpty) 'personId': personId.join(','),
    if (fromDate != null) 'fromDate': fromDate,
    if (toDate != null) 'toDate': toDate,
    if (taskStatus != null) 'taskStatus': taskStatus,
    if (financialStatus != null) 'financialStatus': financialStatus,
    if (taskType != null) 'taskType': taskType,
    if (location != null) 'location': location.toString(),
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
    'includeFinance': includeFinance.toString(),
  };

  // Construct URL
  final uri = Uri.https(
    AppConfig.campusMaintenanceBffApiUrl, 
    '/organizations/$organizationId/tasks', 
    queryParams,
  );

  // Send GET request
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // Handle response
  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityInstance> activityInstances = resultsJson
        .map<ActivityInstance>((json) => ActivityInstance.fromJson(json))
        .toList();
    return activityInstances;
  } else {
    throw Exception(
      'Failed to fetch tasks. Status code: ${response.statusCode}, Body: ${response.body}'
    );
  }
}





//Fetch task details based on month and year
Future<List<ActivityInstance>> getMonthlyTasksByStatus({
  required int organizationId,
  required int year,
  required int month,
  String? taskStatus,
  int? limit,
  int? offset,
}) async {
  final queryParams = {
    if (taskStatus != null) 'taskStatus': taskStatus,
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
  };

  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/reports/monthly/$year/$month/task')
      .replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityInstance> activityInstances = resultsJson
        .map<ActivityInstance>((json) => ActivityInstance.fromJson(json))
        .toList();
    return activityInstances;
  } else {
    throw Exception(
      'Failed to fetch tasks. Status code: ${response.statusCode}, Body: ${response.body}'
    );
  }
}




//Get overdue tasks
Future<List<ActivityInstance>> fetchOverdueActivityInstance(int organizationId) async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/tasks/$organizationId/overdue'),
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