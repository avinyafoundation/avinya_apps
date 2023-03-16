import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import '../data.dart';

Future<List<Activity>> fetchPctiParticipantActivities(int person_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiBffApiUrl +
        '/pcti_participant_activities?person_id=$person_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Activity> pctiActivities = await resultsJson
        .map<Activity>((json) => Activity.fromJson(json))
        .toList();
    return pctiActivities;
  } else {
    throw Exception('Failed to load PctiActivity');
  }
}

Future<List<Activity>> fetchPctiActivities() async {
  final response = await http.get(
      Uri.parse(AppConfig.campusPctiBffApiUrl + '/pcti_activities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
      });

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Activity> pctiActivities = await resultsJson
        .map<Activity>((json) => Activity.fromJson(json))
        .toList();
    return pctiActivities;
  } else {
    throw Exception('Failed to load PctiActivities');
  }
}

Future<List<Evaluation>> fetchPctiActivityNotes(int pcti_activity_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiBffApiUrl +
        '/pcti_activity_notes?pcti_activity_id=$pcti_activity_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Evaluation> pctiNotes = await resultsJson
        .map<Evaluation>((json) => Evaluation.fromJson(json))
        .toList();
    return pctiNotes;
  } else {
    throw Exception('Failed to load PctiNote');
  }
}

Future<List<ActivityInstance>> fetchPctiActivityInstancesToday(
    int activity_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiBffApiUrl +
        '/activity_instances_today?activity_id=$activity_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityInstance> pctiActivityInstances = await resultsJson
        .map<ActivityInstance>((json) => ActivityInstance.fromJson(json))
        .toList();
    return pctiActivityInstances;
  } else {
    throw Exception('Failed to load PctiActivity');
  }
}

Future<List<ActivityInstance>> fetchActivityInstancesFuture(
    int activity_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiBffApiUrl +
        '/activity_instances_future?activity_id=$activity_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityInstance> activityInstances = await resultsJson
        .map<ActivityInstance>((json) => ActivityInstance.fromJson(json))
        .toList();
    return activityInstances;
  } else {
    throw Exception('Failed to load PctiActivity');
  }
}

Future<List<Person>> fetchAvailableTeachers(int activity_instance_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiBffApiUrl +
        '/available_teachers?activity_instance_id=$activity_instance_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> availableTeachers =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return availableTeachers;
  } else {
    throw Exception('Failed to load available teachers');
  }
}

Future<http.Response> createPctiNote(Evaluation pctiNote) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusPctiBffApiUrl + '/pcti_notes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(pctiNote.toJson()),
  );
  if (response.statusCode == 201) {
    return response;
  } else {
    log(response.body);
    log(response.statusCode.toString());
    throw Exception('Failed to create PctiNote.');
  }
}






// Future<List<Evaluation>> fetchPctiActivity(String project_activity_name, String class_activity_name) async{
//   final response = await http.get(
//     Uri.parse(AppConfig.campusPctiBffApiUrl + '/pcti_activities/?project_activity_name=$project_activity_name&class_activity_name=$class_activity_name'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'accept': 'application/json',
//       'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//     },
//   );

//   if (response.statusCode == 200) {
//     var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//     List<Evaluation> pctiActivities = await resultsJson
//         .map<Evaluation>((json) => Evaluation.fromJson(json))
//         .toList();
//     return pctiActivities;
//   } else {
//     throw Exception('Failed to load PctiActivity');
//   }
// }






