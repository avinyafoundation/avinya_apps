import 'dart:developer';

import 'package:ShoolManagementSystem/src/data/campus_config_system.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import 'avinya_type.dart';
import 'evaluation_criteria.dart';

class Vacancy {
  int? id;
  String? name;
  String? description;
  int? organization_id;
  int? avinya_type_id;
  int? evaluation_cycle_id;
  int? head_count;
  AvinyaType? avinya_type;
  var evaluation_criteria = <EvaluationCriteria>[];

  Vacancy({
    this.id,
    this.name,
    this.description,
    this.organization_id,
    this.avinya_type_id,
    this.evaluation_cycle_id,
    this.head_count,
    this.avinya_type,
    this.evaluation_criteria = const [],
  });

  factory Vacancy.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return Vacancy(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      organization_id: json['organization_id'],
      avinya_type_id: json['avinya_type_id'],
      evaluation_cycle_id: json['evaluation_cycle_id'],
      head_count: json['head_count'],
      avinya_type: AvinyaType.fromJson(json['avinya_type']),
      evaluation_criteria: json['evaluation_criteria']
          .map<EvaluationCriteria>(
              (evalc_json) => EvaluationCriteria.fromJson(evalc_json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (organization_id != null) 'organization_id': organization_id,
        if (avinya_type_id != null) 'avinya_type_id': avinya_type_id,
        if (evaluation_cycle_id != null)
          'evaluation_cycle_id': evaluation_cycle_id,
        if (head_count != null) 'head_count': head_count,
        if (avinya_type != null) 'avinya_type': avinya_type,
        'evaluation_criteria': [evaluation_criteria],

        //if(evaluation_criteria != null) 'evaluation_criteria': evaluation_criteria,
      };
}

Future<List<Vacancy>> fetchVacancies() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl +
        '/student_vacancies/' +
        campusConfigSystemInstance.getSchoolName()),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    print(response.body);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    List<Vacancy> vacancys = await resultsJson
        .map<Vacancy>((json) => Vacancy.fromJson(json))
        .toList();
    return vacancys;
  } else {
    throw Exception('Failed to load Vacancy');
  }
}
