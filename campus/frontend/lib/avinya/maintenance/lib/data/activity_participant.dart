import 'dart:convert';

import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../data/person.dart';
//import 'package:gallery/config/app_config.dart';

class ActivityParticipant {
  int? id;
  //int? activity_instance_id;
  // int? person_id;
  Person? person;
  int? organization_id;
  String? start_time;
  String? end_time;
  ProgressStatus? status;
  bool? active;
  int? is_attending;

  ActivityParticipant(
      {this.id,
      //this.activity_instance_id,
      this.person,
      this.organization_id,
      this.start_time,
      this.end_time,
      this.status,
      this.active,
      this.is_attending});

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) {
    return ActivityParticipant(
        id: json['id'],
        //activity_instance_id: json['activity_instance_id'],
        person: Person.fromJson(json['person']),
        organization_id: json['organization_id'],
        start_time: json['start_time'],
        end_time: json['end_time'],
        status: getProgressStatusFromString(json['status']),
        active: json['active'],
        is_attending: json['is_attending']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        // if (activity_instance_id != null)
        //   'activity_instance_id': activity_instance_id,
        if (person != null) 'person': person!.toJson(),
        if (organization_id != null) 'organization_id': organization_id,
        if (start_time != null) 'start_time': start_time,
        if (end_time != null) 'end_time': end_time,
        if (status != null) 'status': progressStatusToString(status!),
        if (active != null) 'active': active,
        if (is_attending != null) 'is_attending': is_attending
      };


  //Create update toJson method for update progress
  Map<String, dynamic> toUpdateJson() => {
    if (id != null) "id": id,
    if (status != null) "status": progressStatusToString(status!),
    if (start_time != null) "startDate": start_time,
    if (end_time != null) "endDate": end_time,
  };
}

Future<ActivityParticipant> createActivityParticipant(
    ActivityParticipant activityParticipant) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusAlumniBffApiUrl}/create_activity_participant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusAlumniBffApiUrl}',
    },
    body: jsonEncode(activityParticipant.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityParticipant.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create activity participant.');
  }
}



//Update activity participant progress
Future<http.Response> updateActivityParticipantProgress(int activityParticipantId, ActivityParticipant activityParticipant) async {
  final response = await http.patch(
    Uri.parse('${AppConfig.campusMaintenanceBffApiUrl}/tasks/participants/$activityParticipantId/progress'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusMaintenanceBffApiUrl}',
    },
    body: jsonEncode(activityParticipant.toUpdateJson()),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response;
  } else {
    throw Exception('Failed to update activity participant progress. Status code: ${response.statusCode}');
  }
}

//Create status enum
enum ProgressStatus{
  pending,
  inProgress,
  completed,
}

//Convert status enum to string
String progressStatusToString(ProgressStatus status){
  switch(status){
    case ProgressStatus.pending:
      return 'pending';
    case ProgressStatus.inProgress:
      return 'inProgress';
    case ProgressStatus.completed:
      return 'completed';
    // default:
    //   throw Exception('Unknown status: $status');
  }
}


//Convert string to status enum
ProgressStatus getProgressStatusFromString(String statusString){
  switch(statusString.toLowerCase()){
    case 'pending':
      return ProgressStatus.pending;
    case 'inprogress':
      return ProgressStatus.inProgress;
    case 'completed':
      return ProgressStatus.completed;
    default:
      throw Exception('Unknown status: $statusString');
  }
}