import 'dart:convert';
import 'package:gallery/avinya/maintenance/lib/data/task_cost.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;

class MonthlyTaskCostReport {
  final int organizationId;
  final int year;
  final int month;
  final double totalActualCost;
  final double totalEstimatedCost;
  final List<TaskCost> tasks;

  MonthlyTaskCostReport({
    required this.organizationId,
    required this.year,
    required this.month,
    required this.totalActualCost,
    required this.totalEstimatedCost,
    required this.tasks,
  });

  factory MonthlyTaskCostReport.fromJson(Map<String, dynamic> json) {
    return MonthlyTaskCostReport(
      organizationId: json['organizationId'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      totalActualCost: (json['totalActualCost'] as num).toDouble(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((task) => TaskCost.fromJson(task as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'organizationId': organizationId,
        'year': year,
        'month': month,
        'totalActualCost': totalActualCost,
        'totalEstimatedCost': totalEstimatedCost,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };
}

// Get monthly task cost report
Future<MonthlyTaskCostReport> getMonthlyTaskCostReport({
  required int organizationId,
  required int year,
  required int month,
}) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/reports/monthly/$year/$month/costs');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,

    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final reportData = decoded['monthlyTaskCostReport'];
    return MonthlyTaskCostReport.fromJson(reportData);
  } else if (response.statusCode == 404) {
    throw Exception('No cost data found for this month.');
  } else {
    throw Exception(
        'Failed to fetch monthly task cost report. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}
