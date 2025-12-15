import 'dart:convert';

import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;

class MonthlyReport {

  int? totalTasks;
  int? completedTasks;
  int? inProgressTasks;
  int? pendingTasks;
  double? totalCost;


  MonthlyReport({
    this.totalTasks,
    this.completedTasks,
    this.inProgressTasks,
    this.pendingTasks,
    this.totalCost,
  });


  //Create MonthlyReport instance from JSON
  factory MonthlyReport.fromJson(Map<String, dynamic> json){
    return MonthlyReport(
      totalTasks: json['totalTasks'],
      completedTasks: json['completedTasks'],
      inProgressTasks: json['inProgressTasks'],
      pendingTasks: json['pendingTasks'],
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }


  //Create MonthlyReport instance to JSON
  Map<String, dynamic> toJson() => {
    if(totalTasks != null) 'totalTasks': totalTasks,
    if(completedTasks != null) 'completedTasks': completedTasks,
    if(inProgressTasks != null) 'inProgressTasks': inProgressTasks,
    if(pendingTasks != null) 'pendingTasks': pendingTasks,
    if(totalCost != null) 'totalCost': totalCost,
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
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    return MonthlyReport.fromJson(jsonData);
  } else if (response.statusCode == 404) {
    throw Exception('No tasks found for this month.');
  } else {
    throw Exception(
        'Failed to fetch monthly report. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}