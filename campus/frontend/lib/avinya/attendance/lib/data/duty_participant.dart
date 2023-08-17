


import 'package:http/http.dart' as http;

import 'dart:developer';

import 'package:gallery/data/person.dart';

import 'activity.dart';

import 'package:gallery/config/app_config.dart';

import 'dart:convert';

class DutyParticipant{

  int? id;
  int? activity_id;
  Activity? activity;
  int? person_id;
  Person? person;
  String? role;
  String? start_date;
  String? end_date;
  String? created;

  DutyParticipant({
    this.id,
    this.activity_id,
    this.activity,
    this.person_id,
    this.person,
    this.role,
    this.start_date,
    this.end_date,
    this.created,
  });

  factory DutyParticipant.fromJson(Map<String,dynamic>  json){
   log(json.toString());
   return DutyParticipant(
     id: json['id'],
     activity_id: json['activity_id'],
     activity: Activity.fromJson(json['activity']),
     person_id: json['person_id'],
     person: Person.fromJson(json['person']),
     role: json['role'],
     start_date: json['start_date'],
     end_date: json['end_date'],
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
        if (start_date != null) 'start_date': start_date,
        if (end_date != null) 'end_date': end_date,
        if (created !=null) 'created':created,

      };

}

Future<List<DutyParticipant>> fetchDutyParticipants() async{

  final response = await http.get(
     Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/duty_participants'),
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
    throw Exception('Failed to load duty participants');
  }
}


Future<http.Response> createDutyForParticipant(DutyParticipant dutyParticipant) async{

  final response = await http.post(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/duty_for_participant'),
    headers:  <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(dutyParticipant.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create duty for participant.');
  }
} 