import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import '../data.dart';

Future<List<Activity>> fetchPctiParticipantActivities(int person_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl +
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

Future<List<Evaluation>> fetchPctiActivityNotes(int pcti_activity_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl +
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
    activity_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl +
        '/pcti_activity_instances_today?activity_id=$activity_id'),
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

Future<http.Response> createPctiNote(Evaluation pctiNote) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/pcti_notes'),
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
//     Uri.parse(AppConfig.campusConfigBffApiUrl + '/pcti_activities/?project_activity_name=$project_activity_name&class_activity_name=$class_activity_name'),
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






