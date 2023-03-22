import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class AvinyaType {
  int? id;
  bool? active;
  String? global_type;
  String? name;
  String? foundation_type;
  String? focus;
  int? level;
  String? description;

  AvinyaType({
    this.id,
    this.active,
    this.global_type,
    this.name,
    this.foundation_type,
    this.focus,
    this.level,
    this.description,
  });

  factory AvinyaType.fromJson(Map<String, dynamic> json) {
    return AvinyaType(
      id: json['id'],
      active: json['active'],
      global_type: json['global_type'],
      name: json['name'],
      foundation_type: json['foundation_type'],
      focus: json['focus'],
      level: json['level'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (active != null) 'active': active,
        if (global_type != null) 'global_type': global_type,
        if (name != null) 'name': name,
        if (foundation_type != null) 'foundation_type': foundation_type,
        if (focus != null) 'focus': focus,
        if (level != null) 'level': level,
        if (description != null) 'description': description,
      };
}

Future<List<AvinyaType>> fetchAvinyaTypes() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinya_types'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<AvinyaType> avinyaTypes = await resultsJson
        .map<AvinyaType>((json) => AvinyaType.fromJson(json))
        .toList();
    return avinyaTypes;
  } else {
    throw Exception('Failed to load AvinyaType');
  }
}

Future<AvinyaType> fetchAvinyaType(String id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinya_types/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    AvinyaType avinyaType =
        await resultsJson.map<AvinyaType>((json) => AvinyaType.fromJson(json));
    return avinyaType;
  } else {
    throw Exception('Failed to load AvinyaType');
  }
}

Future<http.Response> createAvinyaType(AvinyaType avinyaType) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinya_types'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(avinyaType.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create AvinyaType.');
  }
}

Future<http.Response> updateAvinyaType(AvinyaType avinyaType) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinya_types'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(avinyaType.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update AvinyaType.');
  }
}

Future<http.Response> deleteAvinyaType(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinya_types/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete AvinyaType.');
  }
}
