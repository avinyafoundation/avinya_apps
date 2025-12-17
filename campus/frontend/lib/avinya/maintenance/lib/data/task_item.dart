import 'dart:convert';
import 'package:appflowy_board/appflowy_board.dart';
import '../data/dummy_data.dart';
import '../data/academy_location.dart';

class TaskItem extends AppFlowyGroupItem {
  final String itemId;
  final String title;
  final String? description;
  final AcademyLocation location;
  final DateTime deadline;
  final String statusText;
  final bool isOverdue;
  final String status;

  TaskItem({
    required this.itemId,
    required this.title,
    this.description,
    required this.location,
    required this.deadline,
    required this.statusText,
    required this.isOverdue,
    required this.status,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      itemId: json['id'],
      title: json['title'],
      description: json['description'],
      location: AcademyLocation.fromJson(json['location']),
      deadline: DateTime.parse(json['deadline']),
      statusText: json['statusText'],
      isOverdue: json['isOverdue'] ?? false,
      status: json['status'] ?? 'Pending',
    );
  }

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
