import 'package:gallery/avinya/maintenance/lib/data.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/activity_participant.dart';
import '../data/maintenance_finance.dart';
import '../data/maintenance_task.dart';
//import 'package:gallery/config/app_config.dart';
import '../data/dummy_data.dart';

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
  String? overallTaskStatus;
  int? overdueDays;

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
    this.overallTaskStatus,
    this.overdueDays,
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
      activityParticipants: json['activity_participants'] != null
          ? (json['activity_participants'] as List)
              .map((item) => ActivityParticipant.fromJson(item))
              .toList()
          : null,
      financialInformation: json['finance'] != null
          ? MaintenanceFinance.fromJson(json['finance'])
          : null,
      maintenanceTask:
          json['task'] != null ? MaintenanceTask.fromJson(json['task']) : null,
      overallTaskStatus: json['overall_task_status'],
      overdueDays: json['overdue_days'],
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
          'activity_participants':
              activityParticipants!.map((ap) => ap.toJson()).toList(),
        if (financialInformation != null)
          'finance': financialInformation!.toJson(),
        if (maintenanceTask != null) 'task': maintenanceTask!.toJson(),
        if (overallTaskStatus != null) 'overall_task_status': overallTaskStatus,
        if (overdueDays != null) 'overdue_days': overdueDays,
      };
}

Future<List<ActivityInstance>> fetchActivityInstance(int activityID) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/activity_instances_today/$activityID'),
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
  String? overallTaskStatus,
  String? financialStatus,
  String? taskType,
  int? location,
  String? title,
  int? limit,
  int? offset,
  bool includeFinance = false,
}) async {
  // Build base URL
  final baseUrl =
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/tasks';

  // Build query parameters - handle multiple personId values
  final queryParams = <String, dynamic>{
    if (fromDate != null) 'fromDate': fromDate,
    if (toDate != null) 'toDate': toDate,
    if (overallTaskStatus != null) 'taskStatus': overallTaskStatus,
    if (financialStatus != null) 'financialStatus': financialStatus,
    if (taskType != null) 'taskType': taskType,
    if (location != null) 'location': location.toString(),
    if (title != null) 'title': title,
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
    'includeFinance': includeFinance.toString(),
  };

  // Build URI with query parameters
  var uri = Uri.parse(baseUrl);

  // Add regular query parameters
  if (queryParams.isNotEmpty) {
    uri = uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
  }

  // Add multiple personId parameters manually
  if (personId != null && personId.isNotEmpty) {
    final personIdParams = personId.map((id) => 'personId=$id').join('&');
    final separator = uri.hasQuery ? '&' : '?';
    uri = Uri.parse('$uri$separator$personIdParams');
  }

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
        'Failed to fetch tasks. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}

//Fetch task details based on month and year
Future<List<ActivityInstance>> getMonthlyTasksByStatus({
  required int organizationId,
  required int year,
  required int month,
  String? overallTaskStatus,
  int? limit,
  int? offset,
}) async {
  final queryParams = {
    if (overallTaskStatus != null) 'overallTaskStatus': overallTaskStatus,
    if (limit != null) 'limit': limit.toString(),
    if (offset != null) 'offset': offset.toString(),
  };

  final uri = Uri.parse(
          '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/reports/monthly/$year/$month/tasks')
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
        'Failed to fetch tasks. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}

//Get overdue tasks
Future<List<ActivityInstance>> fetchOverdueActivityInstance(
    int organizationId) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusMaintenanceBffApiUrl}/tasks/$organizationId/overdue'),
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

// MOCK APIs. Use these for testing UI without backend integration.

List<ActivityInstance> getMockPendingFinancialActivityInstancesData() {
  final Map<String, dynamic> decoded = jsonDecode(pendingFinancialTasksJson);
  final List<dynamic> tasks = decoded['tasks'];

  return tasks.map((taskItem) {
    final instance = taskItem['activityInstance'];
    return ActivityInstance.fromJson(instance);
  }).toList();
}

//Update activity instance
Future<ActivityInstance> updateActivityInstance(
    ActivityInstance activityInstance) async {
  final response = await http.put(
    Uri.parse(
        '${AppConfig.campusMaintenanceBffApiUrl}/organizations/2/tasks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(activityInstance.toJson()),
  );

  if (response.statusCode == 200) {
    return ActivityInstance.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update Activity Instance');
  }
}
