import 'dart:developer';

//import 'package:ShoolManagementSystem/src/data/address.dart';
import 'package:gallery/avinya/asset/lib/data/address.dart';
import 'package:gallery/avinya/attendance/lib/data.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainOrganization {
  int? id;
  String? description;
  String? notes;
  String? address;
  AvinyaType? avinya_type;
  Name? name;

  MainOrganization({
    this.id,
    this.description,
    this.notes,
    this.address,
    this.avinya_type,
    this.name,
  });

  factory MainOrganization.fromJson(Map<String, dynamic> json) {
    return MainOrganization(
      id: json['id'],
      description: json['description'],
      notes: json['notes'],
      address: json['address'],
      avinya_type: json['avinya_type'] != null
          ? AvinyaType.fromJson(json['avinya_type'])
          : null,
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (address != null) 'address': address,
        if (avinya_type != null) 'avinya_type': avinya_type!.toJson(),
        if (name != null) 'name': name!.toJson(),
      };
}

class AvinyaType {
  int? id;
  String? name;

  AvinyaType({this.id, this.name});

  factory AvinyaType.fromJson(Map<String, dynamic> json) {
    return AvinyaType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

class Name {
  String? nameEn;

  Name({this.nameEn});

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      nameEn: json['name_en'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (nameEn != null) 'name_en': nameEn,
      };
}

class Person {
  int? id;
  String? record_type;
  String? preferred_name;
  String? full_name;
  String? notes;
  String? date_of_birth;
  String? sex;
  int? avinya_type_id;
  String? passport_no;
  int? permanent_address_id;
  String? digital_id;
  int? mailing_address_id;
  String? nic_no;
  String? id_no;
  int? phone;
  int? organization_id;
  String? asgardeo_id;
  String? jwt_sub_id;
  String? jwt_email;
  String? email;
  Address? permanent_address;
  Address? mailing_address;
  MainOrganization? organization;

  Person(
      {this.id,
      this.record_type,
      this.preferred_name,
      this.full_name,
      this.notes,
      this.date_of_birth,
      this.sex,
      this.avinya_type_id,
      this.passport_no,
      this.permanent_address_id,
      this.digital_id,
      this.mailing_address_id,
      this.nic_no,
      this.id_no,
      this.phone,
      this.organization_id,
      this.asgardeo_id,
      this.jwt_sub_id,
      this.jwt_email,
      this.email,
      this.permanent_address,
      this.mailing_address,
      this.organization});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      record_type: json['record_type'],
      preferred_name: json['preferred_name'],
      full_name: json['full_name'],
      notes: json['notes'],
      date_of_birth: json['date_of_birth'],
      sex: json['sex'],
      avinya_type_id: json['avinya_type_id'],
      passport_no: json['passport_no'],
      permanent_address_id: json['permanent_address_id'],
      digital_id: json['digital_id'],
      mailing_address_id: json['mailing_address_id'],
      nic_no: json['nic_no'],
      id_no: json['id_no'],
      phone: json['phone'],
      organization_id: json['organization_id'],
      asgardeo_id: json['asgardeo_id'],
      jwt_sub_id: json['jwt_sub_id'],
      jwt_email: json['jwt_email'],
      email: json['email'],
      permanent_address: Address.fromJson(
          json['permanent_address'] != null ? json['permanent_address'] : {}),
      mailing_address: Address.fromJson(
          json['mailing_address'] != null ? json['mailing_address'] : {}),
      organization: json['organization'] != null
          ? MainOrganization.fromJson(json['organization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (record_type != null) 'record_type': record_type,
        if (preferred_name != null) 'preferred_name': preferred_name,
        if (full_name != null) 'full_name': full_name,
        if (notes != null) 'notes': notes,
        if (date_of_birth != null) 'date_of_birth': date_of_birth,
        if (sex != null) 'sex': sex,
        if (avinya_type_id != null) 'avinya_type_id': avinya_type_id,
        if (passport_no != null) 'passport_no': passport_no,
        if (permanent_address_id != null)
          'permanent_address_id': permanent_address_id,
        if (digital_id != null) 'digital_id': digital_id,
        if (mailing_address_id != null)
          'mailing_address_id': mailing_address_id,
        if (nic_no != null) 'nic_no': nic_no,
        if (id_no != null) 'id_no': id_no,
        if (phone != null) 'phone': phone,
        if (organization_id != null) 'organization_id': organization_id,
        if (asgardeo_id != null) 'asgardeo_id': asgardeo_id,
        if (jwt_sub_id != null) 'jwt_sub_id': jwt_sub_id,
        if (jwt_email != null) 'jwt_email': jwt_email,
        if (email != null) 'email': email,
        if (permanent_address != null)
          'permanent_address': permanent_address!.toJson(),
        if (mailing_address != null)
          'mailing_address': mailing_address!.toJson(),
        if (organization != null) 'organization': organization!.toJson(),
      };
}

// Future<List<Person>> fetchPersons() async {
//   final response = await http.get(
//     Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'accept': 'application/json',
//       'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
//     },
//   );

//   if (response.statusCode == 200) {
//     var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//     List<Person> persons =
//         await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
//     return persons;
//   } else {
//     throw Exception('Failed to load Person');
//   }
// }

Future<List<Person>> fetchPersons(
    int organization_id, int avinya_type_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusEnrollmentsBffApiUrl}/persons/$organization_id/$avinya_type_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> activityAttendances =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return activityAttendances;
  } else {
    throw Exception('Failed to get Daily Attendances Summary Data');
  }
}

Future<Person> fetchPerson(String jwt_sub_id) async {
  final response = await http.get(
    Uri.parse(
        AppConfig.campusAssetsBffApiUrl + '/student_applicant/$jwt_sub_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> createPerson(Person person) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updatePerson(Person person) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deletePerson(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Person.');
  }
}