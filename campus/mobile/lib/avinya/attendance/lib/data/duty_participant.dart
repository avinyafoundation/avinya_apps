


import 'package:http/http.dart' as http;

import 'dart:developer';

import 'package:mobile/data/person.dart';

import 'activity.dart';

import 'package:mobile/config/app_config.dart';

import 'dart:convert';

class DutyParticipant{

  int? id;
  int? activity_id;
  Activity? activity;
  int? person_id;
  Person? person;
  String? role;
  String? created;

  DutyParticipant({
    this.id,
    this.activity_id,
    this.activity,
    this.person_id,
    this.person,
    this.role,
    this.created,
  });

  factory DutyParticipant.fromJson(Map<String,dynamic>  json){
   log(json.toString());

   Activity? activityObj;
   Person? personObj;

   if(json['activity'] != null){
      activityObj = Activity.fromJson(json['activity']);
   }

   if(json['person'] != null){
      personObj = Person.fromJson(json['person']);
   }

   return DutyParticipant(
     id: json['id'],
     activity_id: json['activity_id'],
     activity: activityObj,
     person_id: json['person_id'],
     person: personObj,
     role: json['role'],
     created: json['created'],
   );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_id != null) 'activity_id': activity_id,
        if (activity != null) 'activity': activity,
        if (person_id != null) 'person_id': person_id,
        if (person != null) 'person': person,
        if (role != null) 'role':  role,
        if (created !=null) 'created':created,

      };

}

Future<List<DutyParticipant>> fetchDutyParticipants(int organization_id) async{

  final response = await http.get(
     Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/duty_participants/$organization_id'),
     headers:<String,String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
     },
  );

   if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<DutyParticipant> fetchDutyForParticipants = await resultsJson
        .map<DutyParticipant>((json) => DutyParticipant.fromJson(json))
        .toList();
    return fetchDutyForParticipants;
  } else {
    throw Exception('Failed to load duty participants for organization ID $organization_id');
  }
}


Future<DutyParticipant> createDutyForParticipant(DutyParticipant dutyParticipant) async{

  final response = await http.post(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/duty_for_participant'),
    headers:  <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(dutyParticipant.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return DutyParticipant.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create duty for participant.');
  }
} 

Future<int> deleteDutyForParticipant(int id) async {
  final response = await http.delete(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/duty_for_participant/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return int.parse(response.body);
  } else {
    throw Exception('Failed to delete Duty For Participant.');
  }
}
