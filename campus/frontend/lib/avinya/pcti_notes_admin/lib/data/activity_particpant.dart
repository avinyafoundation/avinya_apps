import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery/config/app_config.dart';

class ActivityParticipant {
  ActivityParticipant({
    this.endDate,
    this.activityInstanceId,
    this.role,
    this.notes,
    this.created,
    this.id,
    this.updated,
    this.startDate,
    this.person_id,
    this.organization,
  });

  dynamic endDate;
  int? activityInstanceId;
  dynamic role;
  dynamic notes;
  DateTime? created;
  dynamic id;
  DateTime? updated;
  dynamic startDate;
  int? person_id;
  dynamic organization;

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) =>
      ActivityParticipant(
        endDate: json["end_date"],
        activityInstanceId: json["activity_instance_id"],
        role: json["role"],
        notes: json["notes"],
        created: DateTime.parse(json["created"]),
        id: json["id"],
        updated: DateTime.parse(json["updated"]),
        startDate: json["start_date"],
        person_id: json["person_id"],
        organization: json["organization"],
      );

  Map<String, dynamic> toJson() => {
        if (endDate != null) "end_date": endDate,
        if (activityInstanceId != null)
          "activity_instance_id": activityInstanceId,
        if (role != null) "role": role,
        if (notes != null) "notes": notes,
        if (created != null) "created": created!.toIso8601String(),
        if (id != null) "id": id,
        if (updated != null) "updated": updated!.toIso8601String(),
        if (startDate != null) "start_date": startDate,
        if (person_id != null) "person_id": person_id,
        if (organization != null) "organization": organization,
      };
}

Future<http.Response> createActivityParticipant(
    ActivityParticipant activityParticipant) async {
  final http.Response response = await http.post(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/activity_participant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(activityParticipant.toJson()),
  );


  if (response.statusCode == 201) {
    return response;
  } else {
    throw Exception('Failed to create activity participant.');
  }
}
