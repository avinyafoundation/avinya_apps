import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class EvaluationCriteriaAnswerOption {
  int? id;
  int? evaluation_criteria_id;
  String? answer;
  bool? expected_answer;

  EvaluationCriteriaAnswerOption({
    this.id,
    this.evaluation_criteria_id,
    this.answer,
    this.expected_answer,
  });

  factory EvaluationCriteriaAnswerOption.fromJson(Map<String, dynamic> json) {
    return EvaluationCriteriaAnswerOption(
      id: json['id'],
      evaluation_criteria_id: json['evaluation_criteria_id'],
      answer: json['answer'],
      expected_answer: json['expected_answer'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (evaluation_criteria_id != null)
          'evaluation_criteria_id': evaluation_criteria_id,
        if (answer != null) 'answer': answer,
        if (expected_answer != null) 'expected_answer': expected_answer,
      };
}

Future<List<EvaluationCriteriaAnswerOption>>
    fetchEvaluationCriteriaAnswerOptions() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria_answer_option/evaluation_criteria_answer_options'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<EvaluationCriteriaAnswerOption> evaluationCriteriaAnswerOptions =
        await resultsJson
            .map<EvaluationCriteriaAnswerOption>(
                (json) => EvaluationCriteriaAnswerOption.fromJson(json))
            .toList();
    return evaluationCriteriaAnswerOptions;
  } else {
    throw Exception('Failed to load EvaluationCriteriaAnswerOption');
  }
}

Future<EvaluationCriteriaAnswerOption> fetchEvaluationCriteriaAnswerOption(
    String id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria_answer_option/evaluation_criteria_answer_options/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    EvaluationCriteriaAnswerOption evaluationCriteriaAnswerOption =
        await resultsJson.map<EvaluationCriteriaAnswerOption>(
            (json) => EvaluationCriteriaAnswerOption.fromJson(json));
    return evaluationCriteriaAnswerOption;
  } else {
    throw Exception('Failed to load EvaluationCriteriaAnswerOption');
  }
}

Future<http.Response> createEvaluationCriteriaAnswerOption(
    EvaluationCriteriaAnswerOption evaluationCriteriaAnswerOption) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria_answer_option/evaluation_criteria_answer_options'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(evaluationCriteriaAnswerOption.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create EvaluationCriteriaAnswerOption.');
  }
}

Future<http.Response> updateEvaluationCriteriaAnswerOption(
    EvaluationCriteriaAnswerOption evaluationCriteriaAnswerOption) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria_answer_option/evaluation_criteria_answer_options'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(evaluationCriteriaAnswerOption.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update EvaluationCriteriaAnswerOption.');
  }
}

Future<http.Response> deleteEvaluationCriteriaAnswerOption(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl +
        '/evaluation_criteria_answer_option/evaluation_criteria_answer_options/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete EvaluationCriteriaAnswerOption.');
  }
}
