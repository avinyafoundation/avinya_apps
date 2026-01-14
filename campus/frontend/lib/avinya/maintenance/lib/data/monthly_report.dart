import 'dart:convert';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;

class MonthlyReport {

  int? totalTasks;
  int? completedTasks;
  int? inProgressTasks;
  int? pendingTasks;
  double? totalCost;
  int? totalUpcomingTasks;
  double? nextMonthlyEstimatedCost;

  MonthlyReport({
    this.totalTasks,
    this.completedTasks,
    this.inProgressTasks,
    this.pendingTasks,
    this.totalCost,
    this.totalUpcomingTasks,
    this.nextMonthlyEstimatedCost,
  });


  //Create MonthlyReport instance from JSON
  factory MonthlyReport.fromJson(Map<String, dynamic> json){
    return MonthlyReport(
      totalTasks: json['totalTasks'],
      completedTasks: json['completedTasks'],
      inProgressTasks: json['inProgressTasks'],
      pendingTasks: json['pendingTasks'],
      totalCost: (json['totalCosts'] as num).toDouble(),
      totalUpcomingTasks: json['totalUpcomingTasks'],
      nextMonthlyEstimatedCost:
          (json['nextMonthlyEstimatedCost'] as num).toDouble(),
    );
  }


  //Create MonthlyReport instance to JSON
  Map<String, dynamic> toJson() => {
    if(totalTasks != null) 'totalTasks': totalTasks,
    if(completedTasks != null) 'completedTasks': completedTasks,
    if(inProgressTasks != null) 'inProgressTasks': inProgressTasks,
    if(pendingTasks != null) 'pendingTasks': pendingTasks,
    if(totalCost != null) 'totalCost': totalCost,
    if(totalUpcomingTasks != null) 'totalUpcomingTasks': totalUpcomingTasks,
    if(nextMonthlyEstimatedCost != null) 'nextMonthlyEstimatedCost': nextMonthlyEstimatedCost
  };
}



//Get monthly report
Future<MonthlyReport> getMonthlyReport({
  required int organizationId,
  required int year,
  required int month,
}) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/reports/monthly/$year/$month');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final reportData = decoded['monthlyMaintenanceReport'];
    return MonthlyReport.fromJson(reportData);
  } else if (response.statusCode == 404) {
    throw Exception('No tasks found for this month.');
  } else {
    throw Exception(
        'Failed to fetch monthly report. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}

