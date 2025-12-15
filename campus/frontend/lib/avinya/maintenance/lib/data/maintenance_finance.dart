//import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gallery/config/app_config.dart';

import '../data/material_cost.dart';
import 'package:http/http.dart' as http;


class MaintenanceFinance {

  int? id;
  int? activityInstanceId;
  double? estimatedCost;
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
      activityInstanceId: json['activityInstanceId'],
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      labourCost: (json['labourCost'] as num?)?.toDouble(),
      status: getStatusFromString(json['status']),
      rejectionReason: json['rejectionReason'],
      reviewedBy: json['reviewedBy'],
      reviewedDate: json['reviewedDate'],
      materialCosts: json['materialCosts'] != null
        ? (json['materialCosts'] as List)
            .map((item) => MaterialCost.fromJson(item))
            .toList()
        : null,
    );
  }


  //Create MaintenanceFinance instance to JSON
  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(activityInstanceId != null) 'activityInstanceId': activityInstanceId,
    if(estimatedCost != null) 'estimatedCost': estimatedCost,
    if(labourCost != null) 'labourCost': labourCost,
    if(status != null) 'status': statusToString(status!),
    if(rejectionReason != null) 'rejectionReason': rejectionReason,
    if(reviewedBy != null) 'reviewedBy': reviewedBy,
    if(reviewedDate != null) 'reviewedDate': reviewedDate,
    if(materialCosts != null) 'materialCosts': materialCosts!.map((mc) => mc.toJson()).toList(),
  };

}




//Update financial status 
Future<http.Response> updateTaskFinance(
    int organizationId, MaintenanceFinance financeUpdate) async {
  final response = await http.patch(
    Uri.parse('${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/tasks/finance'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(financeUpdate.toJson()),
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