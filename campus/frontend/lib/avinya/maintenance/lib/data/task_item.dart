import 'dart:convert';
import 'package:appflowy_board/appflowy_board.dart';
import '../data/dummy_data.dart';
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

Future<List<AppFlowyGroupData>> getBoardData() async {
  // Decode the String
  final Map<String, dynamic> decodedJson = jsonDecode(kanbanBoardResponse);
  final List<dynamic> groups = decodedJson['groups'];

  // Map the JSON to AppFlowy Objects
  return groups.map((group) {
    return AppFlowyGroupData(
      id: group['groupId'],
      name: group['groupName'],
      items:
          List<AppFlowyGroupItem>.from((group['tasks'] as List).map((taskJson) {
        return TaskItem.fromJson(taskJson);
      })),
    );
  }).toList();
}
