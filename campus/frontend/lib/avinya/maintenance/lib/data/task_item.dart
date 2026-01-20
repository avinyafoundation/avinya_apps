import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appflowy_board/appflowy_board.dart';
import '../data/academy_location.dart';

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
      title: _unescapeUnicode(taskData['title'] ?? '' as String?),
      description: _unescapeUnicode(taskData['description'] as String?),
      location: AcademyLocation.fromJson(taskData['location']),
      endDate: DateTime.parse(json['end_time']),
      statusText: json['statusText'] ?? '',
      overdueDays: json['overdue_days'] ?? 0,
    );
  }

  static String _unescapeUnicode(String? input) {
    if (input == null || !input.contains(r'\u')) return input ?? '';
    try {
      // jsonDecode will interpret \uXXXX escapes when fed a quoted JSON string
      final safe = input.replaceAll('"', r'\"');
      return jsonDecode('"$safe"') as String;
    } catch (_) {
      return input;
    }
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
      'http://localhost:9097/organizations/${organizationId ?? 2}/getSinhalaTasks';
  final Map<String, String> queryParams = {};
  if (personId != null) queryParams['personId'] = personId.toString();
  if (fromDate != null) queryParams['fromDate'] = fromDate;
  if (toDate != null) queryParams['toDate'] = toDate;
  if (taskType != null) queryParams['taskType'] = taskType;
  if (location != null) queryParams['location'] = location.toString();

  final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
  const Map<String, String> headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> groups = jsonDecode(response.body);

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
