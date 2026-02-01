//import 'package:gallery/avinya/alumni/lib/data/organization_meta_data.dart';
//import 'package:gallery/avinya/alumni/lib/data/person.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../data/organization_meta_data.dart';
import 'dart:convert';

import '../data/person.dart';

//import 'package:gallery/config/app_config.dart';

class Name {
  String? name_en;
  String? name_si;
  String? name_ta;

  Name({
    this.name_en,
    this.name_si,
    this.name_ta,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      name_en: json['name_en'],
      name_si: json['name_si'],
      name_ta: json['name_ta'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (name_en != null) 'name_en': name_en,
        if (name_si != null) 'name_si': name_si,
        if (name_ta != null) 'name_ta': name_ta,
        // if (address != null) 'address': address!.toJson(),
        // if (employees != null) 'employees': List<dynamic>.from(employees!.map((x) => x.toJson())),
      };
}

class Organization {
  int? id;
  Name? name;
  String? description;
  var child_organizations = <Organization>[];
  var parent_organizations = <Organization>[];
  var people = <Person>[];
  var organization_metadata = <OrganizationMetaData>[];

  Organization({
    this.id,
    this.name,
    this.description,
    this.child_organizations = const [],
    this.parent_organizations = const [],
    this.people = const [],
    this.organization_metadata = const[],
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      description: json['description'],
      child_organizations: json['child_organizations'] != null
          ? List<Organization>.from(
              json['child_organizations'].map((x) => Organization.fromJson(x)))
          : [],
      parent_organizations: json['parent_organizations'] != null
          ? List<Organization>.from(
              json['parent_organizations'].map((x) => Organization.fromJson(x)))
          : [],
      people: json['people'] != null
          ? List<Person>.from(json['people'].map((x) => Person.fromJson(x)))
          : [],
      organization_metadata: json['organization_metadata'] != null
          ? List<OrganizationMetaData>.from(
           json['organization_metadata'].map((x) => OrganizationMetaData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        // if (name != null) 'name': name,
        // if (name != null) 'name': Name!.toJson(),
        if (name != null) 'name': name!.toJson(),
        if (description != null) 'description': description,
        'child_organizations':
            List<dynamic>.from(child_organizations.map((x) => x.toJson())),
        'parent_organizations':
            List<dynamic>.from(parent_organizations.map((x) => x.toJson())),
        'people': List<dynamic>.from(people.map((x) => x.toJson())),
        'organization_metadata':List<dynamic>.from(organization_metadata.map((x) => x.toJson()))
        // if (employees != null) 'employees': List<dynamic>.from(employees!.map((x) => x.toJson())),
      };


}
Future<List<Organization>> fetchOrganizationsByAvinyaTypeAndStatus(
    int? avinya_type, int? active) async {
  Map<String, String> queryParams = {};

  if (avinya_type != null) queryParams['avinya_type'] = avinya_type.toString();
  if (active != null) queryParams['active'] = active.toString();

  final response = await http.get(
    Uri.parse(
            '${AppConfig.campusAttendanceBffApiUrl}/organizations_by_avinya_type_and_status')
        .replace(queryParameters: queryParams),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();

    List<Organization> organization = await resultsJson
        .map<Organization>((json) => Organization.fromJson(json))
        .toList();
    return organization;
  } else {
    throw Exception('Failed to load organizations');
  }
}


