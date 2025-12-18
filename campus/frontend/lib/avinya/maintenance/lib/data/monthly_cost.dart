import 'dart:convert';

import 'package:gallery/avinya/maintenance/lib/data/dummy_data.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;

class MonthlyCost {
  int? month;
  double? actualCost;
  double? estimatedCost;

  MonthlyCost({
    this.month,
    this.actualCost,
    this.estimatedCost,
  });

  //Create MonthlyCost instance from JSON
  factory MonthlyCost.fromJson(Map<String, dynamic> json){
    return MonthlyCost(
      month: json['month'],
      actualCost: (json['actualCost'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
    );
  }


  //Create MonthlyCost instance to JSON
  Map<String, dynamic> toJson() => {
    if(month != null) 'month': month,
    if(actualCost != null) 'actualCost': actualCost,
    if(estimatedCost != null) 'estimatedCost': estimatedCost,
  };
}



//Fetch monthly cost summary
Future<List<MonthlyCost>> getMonthlyCostSummary({
  required int organizationId,
  required int year,
}) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/tasks/$organizationId/monthly-cost-summary/$year');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<MonthlyCost> monthlyCosts = await resultsJson
        .map<MonthlyCost>((json) => MonthlyCost.fromJson(json))
        .toList();
    return monthlyCosts;
  } else {
    throw Exception(
        'Failed to fetch monthly cost summary. Status code: ${response.statusCode}, body: ${response.body}');
  }
}

// MOCK APIs. Use these for testing UI without backend integration.
List<MonthlyCost> getMockMonthlyTaskCostSummary() {
  final Map<String, dynamic> decoded = jsonDecode(monthlyTaskCostSummaryJson);
  final List<dynamic> monthlyCostsJson = decoded['monthlyCosts'];

  return monthlyCostsJson.map((monthJson) {
    return MonthlyCost.fromJson(monthJson);
  }).toList();
}
