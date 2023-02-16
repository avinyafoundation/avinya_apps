import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Prospect {
  int? id;
  String? created;
  bool? agree_terms_consent;
  bool? active;
  String? record_type;
  bool? receive_information_consent;
  int? phone;
  String? name;
  String? email;
  String? street_address;
  String? date_of_birth;
  bool? done_ol;
  int? ol_year;
  int? distance_to_school;

  Prospect({
    this.id,
    this.created,
    this.agree_terms_consent,
    this.active,
    this.record_type,
    this.receive_information_consent,
    this.phone,
    this.name,
    this.email,
    this.street_address,
    this.date_of_birth,
    this.done_ol,
    this.ol_year,
    this.distance_to_school,
  });

  factory Prospect.fromJson(Map<String, dynamic> json) {
    return Prospect(
      id: json['id'],
      created: json['created'],
      agree_terms_consent: json['agree_terms_consent'],
      active: json['active'],
      record_type: json['record_type'],
      receive_information_consent: json['receive_information_consent'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      street_address: json['street_address'],
      date_of_birth: json['date_of_birth'],
      done_ol: json['done_ol'],
      ol_year: json['ol_year'],
      distance_to_school: json['distance_to_school'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (created != null) 'created': created,
        if (agree_terms_consent != null)
          'agree_terms_consent': agree_terms_consent,
        if (active != null) 'active': active,
        if (record_type != null) 'record_type': record_type,
        if (receive_information_consent != null)
          'receive_information_consent': receive_information_consent,
        if (phone != null) 'phone': phone,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (street_address != null) 'street_address': street_address,
        if (date_of_birth != null) 'date_of_birth': date_of_birth,
        if (done_ol != null) 'done_ol': done_ol,
        if (ol_year != null) 'ol_year': ol_year,
        if (distance_to_school != null)
          'distance_to_school': distance_to_school,
      };
}

Future<http.Response> createProspect(Prospect prospect) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/prospect'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(prospect.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Prospect.');
  }
}
