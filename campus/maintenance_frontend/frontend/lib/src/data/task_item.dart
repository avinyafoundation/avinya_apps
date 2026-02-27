import 'dart:convert';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:appflowy_board/appflowy_board.dart';
import '../data/academy_location.dart';
import '../services/translation_service.dart';

class TaskItem extends AppFlowyGroupItem {
  final String itemId;
  final String title;
  final String? description;
  final AcademyLocation location;
  final DateTime endDate;
  final String statusText;
  final int overdueDays;

  TaskItem({
    required this.itemId,
    required this.title,
    this.description,
    required this.location,
    required this.endDate,
    required this.statusText,
    required this.overdueDays,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    // The task details are nested inside a 'task' object
    final taskData = json['task'] as Map<String, dynamic>;
    return TaskItem(
      itemId: json['id'].toString(),
      title: taskData['title'] ?? '',
      description: taskData['description'],
      location: AcademyLocation.fromJson(taskData['location']),
      endDate: DateTime.parse(json['end_time']),
      statusText: json['statusText'] ?? '',
      overdueDays: json['overdue_days'] ?? 0,
    );
  }

  bool get isOverdue => overdueDays > 0;

  @override
  String get id => itemId;
}

Future<List<AppFlowyGroupData>> getBoardData({
  int? organizationId,
  int? personId,
  String? fromDate,
  String? toDate,
  String? taskType,
  int? location,
}) async {
  final String baseUrl =
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/${organizationId ?? 2}/getTasksByStatus';
  final Map<String, String> queryParams = {};
  if (personId != null) queryParams['personId'] = personId.toString();
  if (fromDate != null) queryParams['fromDate'] = fromDate;
  if (toDate != null) queryParams['toDate'] = toDate;
  if (taskType != null) queryParams['taskType'] = taskType;
  if (location != null) queryParams['location'] = location.toString();

  final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'accept': 'application/json',
    'api-key': AppConfig.maintenanceAppBffApiKey,
  };

  try {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> groups = jsonDecode(response.body);

      // Collect all texts for batch translation
      final List<String> textsToTranslate = [];
      for (var group in groups) {
        if (group['tasks'] != null) {
          for (var task in group['tasks']) {
            if (task['title'] != null) textsToTranslate.add(task['title']);
            if (task['description'] != null)
              textsToTranslate.add(task['description']);
          }
        }
      }

      // Pre-fetch translations in one batch
      if (textsToTranslate.isNotEmpty) {
        await GeminiTranslator.translateBatch(textsToTranslate);
      }

      // Map the JSON to AppFlowy Objects
      return groups.map((group) {
        return AppFlowyGroupData(
          id: group['groupId'],
          name: group['groupName'],
          items: List<AppFlowyGroupItem>.from(
              (group['tasks'] as List).map((taskJson) {
            return TaskItem.fromJson(taskJson);
          })),
        );
      }).toList();
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<void> updateTaskStatus(
    int activityInstanceId, int personId, String status) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/tasks/activity_instances/$activityInstanceId/participants/$personId');
  final response = await http.patch(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'api-key': AppConfig.maintenanceAppBffApiKey,
    },
    body: jsonEncode({
      'person_id': personId,
      'activity_instance_id': activityInstanceId,
      'participant_task_status': status,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update task status: ${response.body}');
  }
}

Future<List<dynamic>> getOrganizationTasks(int organizationId) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/tasks');
  
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'api-key': AppConfig.maintenanceAppBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception('Failed to load organization tasks: ${response.statusCode}');
  }
}

/// Fetches tasks filtered by status ("Pending" or "InProgress").
Future<List<dynamic>> getOrganizationTasksByStatus(
    int organizationId, String status,
    {DateTime? toDate, int? limit}) async {
  // prepare query parameters; include status and optional toDate/limit
  final Map<String, String> queryParams = {'taskStatus': status};
  if (toDate != null) {
    queryParams['toDate'] = toDate.toIso8601String();
  }
  if (limit != null) {
    queryParams['limit'] = limit.toString();
  }
  final uri = Uri.parse(
          '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/tasks')
      .replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'api-key': AppConfig.maintenanceAppBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception(
        'Failed to load organization tasks by status ($status): ${response.statusCode}');
  }
}

Future<List<dynamic>> getOverdueTasks(int organizationId) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/tasks/$organizationId/overdue');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'api-key': AppConfig.maintenanceAppBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception('Failed to load overdue tasks: ${response.statusCode}');
  }
}
