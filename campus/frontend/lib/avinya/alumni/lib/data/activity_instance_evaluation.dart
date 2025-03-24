import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gallery/config/app_config.dart';

class ActivityInstanceEvaluation {
  int? id;
  int? activity_instance_id;
  int? evaluator_id;
  String? feedback;
  int? rating;

  ActivityInstanceEvaluation(
      {this.id,
      this.activity_instance_id,
      this.evaluator_id,
      this.feedback,
      this.rating});

  factory ActivityInstanceEvaluation.fromJson(Map<String, dynamic> json) {
    return ActivityInstanceEvaluation(
        id: json['id'],
        activity_instance_id: json['activity_instance_id'],
        evaluator_id: json['evaluator_id'],
        feedback: json['feedback'],
        rating: json['rating']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_instance_id != null)
          'activity_instance_id': activity_instance_id,
        if (evaluator_id != null) 'evaluator_id': evaluator_id,
        if (feedback != null) 'feedback': feedback,
        if (rating != null) 'rating': rating
      };
}

Future<ActivityInstanceEvaluation> createActivityInstanceEvaluation(
    ActivityInstanceEvaluation activityInstanceEvaluation) async {
  final response = await http.post(
    Uri.parse(
        '${AppConfig.campusAlumniBffApiUrl}/create_activity_instance_evaluation'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(activityInstanceEvaluation.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityInstanceEvaluation.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create activity evaluation.');
  }
}
