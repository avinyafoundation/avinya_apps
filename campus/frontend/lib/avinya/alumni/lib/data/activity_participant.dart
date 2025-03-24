import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gallery/config/app_config.dart';

class ActivityParticipant {
  int? id;
  int? activity_instance_id;
  int? person_id;
  int? organization_id;
  bool? active;
  int? is_attending;

  ActivityParticipant(
      {this.id,
      this.activity_instance_id,
      this.person_id,
      this.organization_id,
      this.active,
      this.is_attending});

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) {
    return ActivityParticipant(
        id: json['id'],
        activity_instance_id: json['activity_instance_id'],
        person_id: json['person_id'],
        organization_id: json['organization_id'],
        active: json['active'],
        is_attending: json['is_attending']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_instance_id != null)
          'activity_instance_id': activity_instance_id,
        if (person_id != null) 'person_id': person_id,
        if (organization_id != null) 'organization_id': organization_id,
        if (active != null) 'active': active,
        if (is_attending != null) 'is_attending': is_attending
      };
}

Future<ActivityParticipant> createActivityParticipant(
    ActivityParticipant activityParticipant) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusAlumniBffApiUrl}/create_activity_participant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(activityParticipant.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityParticipant.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create activity participant.');
  }
}
