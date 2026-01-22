import 'dart:convert';

import 'package:gallery/config/app_config.dart';

import '../data/academy_location.dart';
import '../data/maintenance_finance.dart';
import 'package:http/http.dart' as http;

class MaintenanceTask {

  int? id;
  String? title;
  String? description;
  MaintenanceType? type;
  MaintenanceFrequency? frequency;
  AcademyLocation? location;
  int? locationId;
  List<int>? personId;
  String? startDate;
  int? exceptionDeadline;
  int? hasFinancialInfo;
  String? modifiedBy;
  int? isActive;
  MaintenanceFinance? financialInformation;
  String? deadline;
  String? statusText;
  int? isOverdue;


  MaintenanceTask({
    this.id,
    this.title,
    this.description,
    this.type,
    this.frequency,
    this.location,
    this.locationId,
    this.personId,
    this.startDate,
    this.exceptionDeadline,
    this.hasFinancialInfo,
    this.modifiedBy,
    this.isActive,
    this.financialInformation,
    this.deadline,
    this.statusText,
    this.isOverdue,
  });


  //Create MaintenanceTask instance from JSON
  factory MaintenanceTask.fromJson(Map<String, dynamic> json){
    return MaintenanceTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['task_type'] != null ? getMaintenanceTypeFromString(json['task_type']) : null,
      frequency: json['frequency'] != null ? getMaintenanceFrequencyFromString(json['frequency']) : null,
      location: json['location'] != null ? AcademyLocation.fromJson(json['location']) : null,
      locationId: json['location_id'],
      personId: json['person_id_list'] != null
        ? List<int>.from(json['person_id_list'])
        : null,
      startDate: json['start_date'],
      exceptionDeadline: json['exception_deadline'],
      hasFinancialInfo: json['has_financial_info'],
      modifiedBy: json['modified_by'],
      isActive: json['isActive'],
      financialInformation: json['finance'] != null
        ? MaintenanceFinance.fromJson(json['finance'])
        : null,
      deadline: json['deadline'],
      statusText: json['statusText'],
      isOverdue: json['isOverdue'],
    );
  }


  //Create MaintenanceTask instance to JSON
  Map<String, dynamic> toJson() => {
    if(id != null) 'id': id,
    if(title != null) 'title': title,
    if(description != null) 'description': description,
    if(type != null) 'task_type': maintenanceTypeToString(type!),
    if(frequency != null) 'frequency': maintenanceFrequencyToString(frequency!),
    if(location != null) 'location': location!.toJson(),
    if(locationId != null) 'location_id': locationId,
    if(personId != null) 'person_id_list': personId,
    if(startDate != null) 'start_date': startDate,
    if(exceptionDeadline != null) 'exception_deadline': exceptionDeadline,
    if(hasFinancialInfo != null) 'has_financial_info': hasFinancialInfo,
    if(modifiedBy != null) 'modified_by': modifiedBy,
    if(isActive != null) 'isActive': isActive,
    if(financialInformation != null) 'finance': financialInformation!.toJson(),
    if(deadline != null) 'deadline': deadline,
    if(statusText != null) 'statusText': statusText,
    if(isOverdue != null) 'isOverdue': isOverdue,
  };

}






//Save task details
Future<http.Response> saveMaintenanceTask(MaintenanceTask task) async {
  
  final response = await http.post(
    Uri.parse(AppConfig.campusMaintenanceBffApiUrl + '/organizations/2/tasks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(task.toJson()),
  );

  if(response.statusCode == 200 || response.statusCode == 201){
    return response;
  }
  else{
    throw Exception('Failed to save maintenance task. Status code: ${response.statusCode}');
  }
}




//Update task details
Future<http.Response> updateMaintenanceTask(int taskId, MaintenanceTask task) async {
  final reponse = await http.put(
    Uri.parse('${AppConfig.campusMaintenanceBffApiUrl}/tasks/$taskId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(task.toJson()),
  );
  if(reponse.statusCode == 200){
    return reponse;
  }
  else{
    throw Exception('Failed to update maintenance task. Status code: ${reponse.statusCode}');
  }
}



//Soft delete task
Future<http.Response> deactivateMaintenanceTask(
    int taskId, String modifiedBy) async {
  final uri = Uri.parse(
      '${AppConfig.campusMaintenanceBffApiUrl}/tasks/$taskId?modifiedBy=$modifiedBy');

  final body = {
    "id": taskId,
    "isDeleted": true
  };

  final response = await http.patch(
    Uri.parse('${AppConfig.campusMaintenanceBffApiUrl}/tasks/$taskId/delete'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception(
        'Failed to delete maintenance task. Status code: ${response.statusCode}');
  }
}


//enum for maintenance type
enum MaintenanceType {
  oneTime,
  recurring,
}

//Convert MaintenanceType to String
String maintenanceTypeToString(MaintenanceType type) {
  switch (type) {
    case MaintenanceType.oneTime:
      return 'oneTime';
    case MaintenanceType.recurring:
      return 'recurring';
  }
}

//Get MaintenanceType from String
MaintenanceType getMaintenanceTypeFromString(String typeString) {
  switch (typeString.toLowerCase()) {
    case 'onetime':
      return MaintenanceType.oneTime;
    case 'recurring':
      return MaintenanceType.recurring;
    default:
      throw Exception('Unknown maintenance type: $typeString');
  }
}



//enum for maintenance frequency
enum MaintenanceFrequency {
  daily,
  weekly,
  biWeekly,
  monthly,
  quarterly,
  yearly,
  annually,
}


//Convert MaintenanceFrequency to String
String maintenanceFrequencyToString(MaintenanceFrequency frequency) {
  switch (frequency) {
    case MaintenanceFrequency.daily:
      return 'daily';
    case MaintenanceFrequency.weekly:
      return 'weekly';
    case MaintenanceFrequency.biWeekly:
      return 'biWeekly';
    case MaintenanceFrequency.monthly:
      return 'monthly';
    case MaintenanceFrequency.quarterly:
      return 'quarterly';
    case MaintenanceFrequency.yearly:
      return 'yearly';
    case MaintenanceFrequency.annually:
      return 'annually';
  }
}

//Get MaintenanceFrequency from String
MaintenanceFrequency getMaintenanceFrequencyFromString(String frequencyString) {
  switch (frequencyString.toLowerCase()) {
    case 'daily':
      return MaintenanceFrequency.daily;
    case 'weekly':
      return MaintenanceFrequency.weekly;
    case 'biweekly':
      return MaintenanceFrequency.biWeekly;
    case 'monthly':
      return MaintenanceFrequency.monthly;
    case 'quarterly':
      return MaintenanceFrequency.quarterly;
    case 'yearly':
      return MaintenanceFrequency.yearly;
    case 'annually':
      return MaintenanceFrequency.annually;
    default:
      throw Exception('Unknown maintenance frequency: $frequencyString');
  }
}