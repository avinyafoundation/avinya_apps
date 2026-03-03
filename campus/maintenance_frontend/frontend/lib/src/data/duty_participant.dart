

import 'dart:developer';

import '../data/person.dart';

import 'activity.dart';


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