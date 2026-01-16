import 'dart:convert';
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
      actualCost: (json['actual_cost'] as num).toDouble(),
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
    );
  }


  //Create MonthlyCost instance to JSON
  Map<String, dynamic> toJson() => {
    if(month != null) 'month': month,
    if(actualCost != null) 'actual_cost': actualCost,
    if(estimatedCost != null) 'estimated_cost': estimatedCost,
  };
}



//Fetch monthly cost summary
//Fetch monthly cost summary
Future<List<MonthlyCost>> getMonthlyCostSummary({
  required int organizationId,
  required int year,
}) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/tasks/$organizationId/monthlyCostSummary/$year');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final monthlyCostSummary = responseData['monthlyCostSummary'] as Map<String, dynamic>;
    final List<dynamic> monthlyCostsJson = monthlyCostSummary['monthly_costs'] as List<dynamic>;

    List<MonthlyCost> monthlyCosts = monthlyCostsJson
        .map<MonthlyCost>((json) => MonthlyCost.fromJson(json))
        .toList();
    return monthlyCosts;
  } else {
    throw Exception(
        'Failed to fetch monthly cost summary. Status code: ${response.statusCode}, body: ${response.body}');
  }
}
