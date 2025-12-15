import 'dart:convert';

import 'package:gallery/config/app_config.dart';

import '../data/maintenance_task.dart';
import 'package:http/http.dart' as http;

class Group {

  int? id;
  String? groupName;
  List<MaintenanceTask>? maintenanceTasks;

  Group({
    this.id,
    this.groupName,
    this.maintenanceTasks,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      groupName: json['groupName'],
      maintenanceTasks: json['maintenanceTasks'] != null
          ? (json['maintenanceTasks'] as List)
              .map((item) => MaintenanceTask.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id != null) 'id': id,
      if(groupName != null) 'groupName': groupName,
      if(maintenanceTasks != null)
        'maintenanceTasks':
            maintenanceTasks!.map((mt) => mt.toJson()).toList(),
    };
  }
}



//Get list of Groups
Future<List<Group>> getTasksByStatus({
  required int organizationId,
  List<int>? personIds,
  String? fromDate,
  String? toDate,
  String? taskStatus,
  String? taskType,
  int? location,
}) async {
  final queryParameters = <String, String>{};

  if (personIds != null && personIds.isNotEmpty) {
    queryParameters['personId'] = personIds.join(',');
  }
  if (fromDate != null) queryParameters['fromDate'] = fromDate;
  if (toDate != null) queryParameters['toDate'] = toDate;
  if (taskStatus != null) queryParameters['taskStatus'] = taskStatus;
  if (taskType != null) queryParameters['taskType'] = taskType;
  if (location != null) queryParameters['location'] = location.toString();

  final uri = Uri.https(
    AppConfig.campusMaintenanceBffApiUrl, 
    '/organizations/$organizationId/getTasksByStatus', 
    queryParameters,
  );

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final groups = (data['groups'] as List)
        .map((groupJson) => Group.fromJson(groupJson))
        .toList();
    return groups;
  } else {
    throw Exception(
        'Failed to fetch tasks by status. Status code: ${response.statusCode}');
  }
}