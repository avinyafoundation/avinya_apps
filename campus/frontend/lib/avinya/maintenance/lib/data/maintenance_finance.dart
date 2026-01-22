//import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gallery/config/app_config.dart';

import '../data/material_cost.dart';
import 'package:http/http.dart' as http;


class MaintenanceFinance {

  int? id;
  int? activityInstanceId;
  double? estimatedCost;
  double? totalCost;
  double? labourCost;
  FinanceStatus? status;
  String? rejectionReason;
  String? reviewedBy;
  String? reviewedDate;
  List<MaterialCost>? materialCosts;

  MaintenanceFinance({
    this.id,
    this.activityInstanceId,
    this.estimatedCost,
    this.totalCost,
    this.labourCost,
    this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedDate,
    this.materialCosts,
  });


  //Create MaintenanceFinance instance from JSON
  factory MaintenanceFinance.fromJson(Map<String, dynamic> json){
    return MaintenanceFinance(
      id: json['id'],
      activityInstanceId: json['activity_instance_id'],
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      labourCost: (json['labour_cost'] as num?)?.toDouble(),
      status: getStatusFromString(json['status']),
      rejectionReason: json['rejection_reason'],
      reviewedBy: json['reviewed_by'],
      reviewedDate: json['reviewed_date'],
      materialCosts: json['material_costs'] != null
        ? (json['material_costs'] as List)
            .map((item) => MaterialCost.fromJson(item))
            .toList()
        : null,
    );
  }


  //Create MaintenanceFinance instance to JSON
  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(activityInstanceId != null) 'activity_instance_id': activityInstanceId,
    if(estimatedCost != null) 'estimated_cost': estimatedCost,
    if(totalCost != null) 'total_cost': totalCost,
    if(labourCost != null) 'labour_cost': labourCost,
    if(status != null) 'status': statusToString(status!),
    if(rejectionReason != null) 'rejection_reason': rejectionReason,
    if(reviewedBy != null) 'reviewed_by': reviewedBy,
    if(reviewedDate != null) 'reviewed_date': reviewedDate,
    if(materialCosts != null) 'material_costs': materialCosts!.map((mc) => mc.toJson()).toList(),
  };

}




//Update financial status 
Future<http.Response> updateTaskFinance(
    int organizationId, MaintenanceFinance financeUpdate) async {
  if (financeUpdate.id == null) {
    throw Exception('MaintenanceFinance ID is required for update');
  }

  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/tasks/finance/${financeUpdate.id}');

  Map<String, dynamic> body = {
    'status': statusToString(financeUpdate.status!),
    'reviewed_by': financeUpdate.reviewedBy,
  };

  if (financeUpdate.status == FinanceStatus.rejected) {
    body['rejection_reason'] = financeUpdate.rejectionReason;
  }

  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response;
  } else {
    throw Exception(
        'Failed to update task finance. Status code: ${response.statusCode}, Body: ${response.body}');
  }
}


//Finance status enum
enum FinanceStatus{
  pending,
  approved,
  rejected
}

//Convert string to status enum
FinanceStatus getStatusFromString(String statusString){
  switch(statusString.toLowerCase()){
    case 'pending':
      return FinanceStatus.pending;
    case 'approved':
      return FinanceStatus.approved;
    case 'rejected':
      return FinanceStatus.rejected;
    default:
      throw Exception('Unknown status: $statusString');
  }
}

//Concert status enum to string
String statusToString(FinanceStatus statusEnum){
  switch(statusEnum){
    case FinanceStatus.pending:
      return 'pending';
    case FinanceStatus.approved:
      return 'approved';
    case FinanceStatus.rejected:
      return 'rejected';
    // default:
    //   throw Exception('Unknown status: $statusEnum');
  }
}