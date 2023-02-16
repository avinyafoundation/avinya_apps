import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class ApplicantConsent {
  int? id;
  String? date_of_birth;
  String? created;
  int? avinya_type_id;
  bool? agree_terms_consent;
  bool? done_ol;
  int? application_id;
  int? ol_year;
  String? record_type;
  bool? information_correct_consent;
  int? phone;
  int? organization_id;
  String? name;
  int? distance_to_school;
  int? person_id;
  String? email;

  ApplicantConsent({
    this.id,
    this.date_of_birth,
    this.created,
    this.avinya_type_id,
    this.agree_terms_consent,
    this.done_ol,
    this.application_id,
    this.ol_year,
    this.record_type,
    this.information_correct_consent,
    this.phone,
    this.organization_id,
    this.name,
    this.distance_to_school,
    this.person_id,
    this.email,
  });

  factory ApplicantConsent.fromJson(Map<String, dynamic> json) {
    return ApplicantConsent(
      id: json['id'],
      date_of_birth: json['date_of_birth'],
      created: json['created'],
      avinya_type_id: json['avinya_type_id'],
      agree_terms_consent: json['agree_terms_consent'],
      done_ol: json['done_ol'],
      application_id: json['application_id'],
      ol_year: json['ol_year'],
      record_type: json['record_type'],
      information_correct_consent: json['information_correct_consent'],
      phone: json['phone'],
      organization_id: json['organization_id'],
      name: json['name'],
      distance_to_school: json['distance_to_school'],
      person_id: json['person_id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (date_of_birth != null) 'date_of_birth': date_of_birth,
        if (created != null) 'created': created,
        if (avinya_type_id != null) 'avinya_type_id': avinya_type_id,
        if (agree_terms_consent != null)
          'agree_terms_consent': agree_terms_consent,
        if (done_ol != null) 'done_ol': done_ol,
        if (application_id != null) 'application_id': application_id,
        if (ol_year != null) 'ol_year': ol_year,
        if (record_type != null) 'record_type': record_type,
        if (information_correct_consent != null)
          'information_correct_consent': information_correct_consent,
        if (phone != null) 'phone': phone,
        if (organization_id != null) 'organization_id': organization_id,
        if (name != null) 'name': name,
        if (distance_to_school != null)
          'distance_to_school': distance_to_school,
        if (person_id != null) 'person_id': person_id,
        if (email != null) 'email': email,
      };
}

Future<List<ApplicantConsent>> fetchApplicantConsents() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/applicant_consent'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      // 'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ApplicantConsent> applicantConsents = await resultsJson
        .map<ApplicantConsent>((json) => ApplicantConsent.fromJson(json))
        .toList();
    return applicantConsents;
  } else {
    throw Exception('Failed to load ApplicantConsent');
  }
}

Future<ApplicantConsent> fetchApplicantConsent(String id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/applicant_consent/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      // 'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    ApplicantConsent applicantConsent = await resultsJson
        .map<ApplicantConsent>((json) => ApplicantConsent.fromJson(json));
    return applicantConsent;
  } else {
    throw Exception('Failed to load ApplicantConsent');
  }
}

Future<http.Response> createApplicantConsent(
    ApplicantConsent applicantConsent) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/applicant_consent'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
    },
    body: jsonEncode(applicantConsent.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create ApplicantConsent.');
  }
}

Future<http.Response> updateApplicantConsent(
    ApplicantConsent applicantConsent) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/applicant_consent'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(applicantConsent.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update ApplicantConsent.');
  }
}

Future<http.Response> deleteApplicantConsent(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/applicant_consent/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete ApplicantConsent.');
  }
}
