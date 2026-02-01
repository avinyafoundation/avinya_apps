import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';

class JobCategory {
  int? id;
  String? name;
  String? description;

  JobCategory(
      {this.id,
      this.name,
      this.description,
      });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
        id: json['id'],
        name: json['name'],
        description: json['description']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (description != null) 'description': description
      };
}
Future<List<JobCategory>> fetchJobCategories() async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusAlumniBffApiUrl}/job_categories'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<JobCategory> jobCategories = await resultsJson
        .map<JobCategory>((json) => JobCategory.fromJson(json))
        .toList();
    return jobCategories;
  } else {
    throw Exception('Failed to get Job Categories');
  }
}
