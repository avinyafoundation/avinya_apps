import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class ApplicationStatus {
  int? id;
  int? application_id;
  String? status;
  String? updated;
  bool? is_terminal;

  ApplicationStatus({
    this.id,
    this.application_id,
    this.status,
    this.updated,
    this.is_terminal,
  });

  factory ApplicationStatus.fromJson(Map<String, dynamic> json) {
    return ApplicationStatus(
      id: json['id'],
      application_id: json['application_id'],
      status: json['status'],
      updated: json['updated'],
      is_terminal: json['is_terminal'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (application_id != null) 'application_id': application_id,
        if (status != null) 'status': status,
        if (updated != null) 'updated': updated,
        if (is_terminal != null) 'is_terminal': is_terminal,
      };
}

class Application {
  int? id;
  int? person_id;
  int? vacancy_id;
  String? application_date;
  var statuses = <ApplicationStatus>[];

  Application({
    this.id,
    this.person_id,
    this.vacancy_id,
    this.application_date,
    this.statuses = const [],
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      person_id: json['person_id'],
      vacancy_id: json['vacancy_id'],
      application_date: json['application_date'],
      statuses: json['statuses']
          .map<ApplicationStatus>(
              (status_json) => ApplicationStatus.fromJson(status_json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (vacancy_id != null) 'vacancy_id': vacancy_id,
        if (application_date != null) 'application_date': application_date,
        //'statuses': [statuses.map((e) => e.toJson()).toList()],
      };
}

Future<List<Application>> fetchApplications() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/application'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Application> applicantConsents = await resultsJson
        .map<Application>((json) => Application.fromJson(json))
        .toList();
    return applicantConsents;
  } else {
    throw Exception('Failed to load Application');
  }
}

Future<Application> fetchApplication(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/application/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    //var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Application application = Application.fromJson(json.decode(response.body));
    return application;
  } else {
    throw Exception('Failed to load Application');
  }
}

Future<Application> createApplication(Application applicantConsent) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/application'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(applicantConsent.toJson()),
  );
  if (response.statusCode == 200) {
    Application createdApplication =
        Application.fromJson(json.decode(response.body));
    return createdApplication;
  } else {
    throw Exception('Failed to create Application.');
  }
}

Future<http.Response> updateApplication(Application applicantConsent) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/application'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(applicantConsent.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Application.');
  }
}

Future<http.Response> deleteApplication(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/application/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Application.');
  }
}
