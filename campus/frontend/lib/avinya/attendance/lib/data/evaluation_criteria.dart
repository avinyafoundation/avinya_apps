import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import 'evaluation_criteria_answer_option.dart';

class EvaluationCriteria {
  int? id;
  String? prompt;
  String? description;
  String? expected_answer;
  String? evalualtion_type;
  String? difficulty;
  int? rating_out_of;
  var answer_options = <EvaluationCriteriaAnswerOption>[];

  EvaluationCriteria({
    this.id,
    this.prompt,
    this.description,
    this.expected_answer,
    this.evalualtion_type,
    this.difficulty,
    this.rating_out_of,
    this.answer_options = const [],
  });

  factory EvaluationCriteria.fromJson(Map<String, dynamic> json) {
    return EvaluationCriteria(
      id: json['id'],
      prompt: json['prompt'],
      description: json['description'],
      expected_answer: json['expected_answer'],
      evalualtion_type: json['evalualtion_type'],
      difficulty: json['difficulty'],
      rating_out_of: json['rating_out_of'],
      answer_options: json['answer_options']
          .map<EvaluationCriteriaAnswerOption>(
              (ao_json) => EvaluationCriteriaAnswerOption.fromJson(ao_json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (prompt != null) 'prompt': prompt,
        if (description != null) 'description': description,
        if (expected_answer != null) 'expected_answer': expected_answer,
        if (evalualtion_type != null) 'evalualtion_type': evalualtion_type,
        if (difficulty != null) 'difficulty': difficulty,
        if (rating_out_of != null) 'rating_out_of': rating_out_of,
        'answer_options': [answer_options],
        //if (answer_options != null) 'answer_options': answer_options,
      };
}

Future<List<EvaluationCriteria>> fetchEvaluationCriterias() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/student_vacancies/evaluation_criterias'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<EvaluationCriteria> evaluationCriterias = await resultsJson
        .map<EvaluationCriteria>((json) => EvaluationCriteria.fromJson(json))
        .toList();
    return evaluationCriterias;
  } else {
    throw Exception('Failed to load EvaluationCriteria');
  }
}

Future<EvaluationCriteria> fetchEvaluationCriteria(String id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria/evaluation_criterias/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    EvaluationCriteria evaluationCriteria = await resultsJson
        .map<EvaluationCriteria>((json) => EvaluationCriteria.fromJson(json));
    return evaluationCriteria;
  } else {
    throw Exception('Failed to load EvaluationCriteria');
  }
}

Future<http.Response> createEvaluationCriteria(
    EvaluationCriteria evaluationCriteria) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria/evaluation_criterias'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(evaluationCriteria.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create EvaluationCriteria.');
  }
}

Future<http.Response> updateEvaluationCriteria(
    EvaluationCriteria evaluationCriteria) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria/evaluation_criterias'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(evaluationCriteria.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update EvaluationCriteria.');
  }
}

Future<http.Response> deleteEvaluationCriteria(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria/evaluation_criterias/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete EvaluationCriteria.');
  }
}
