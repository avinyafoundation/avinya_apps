import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Consumable {
  int? id;
  String? name;
  String? description;
  int? avinyaTypeId;
  String? manufacturer;
  String? model;
  String? serialNumber;

  Consumable({
    this.id,
    this.name,
    this.description,
    this.avinyaTypeId,
    this.manufacturer,
    this.model,
    this.serialNumber,
  });

  factory Consumable.fromJson(Map<String, dynamic> json) => Consumable(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        avinyaTypeId:
            json["avinya_type_id"] == null ? null : json["avinya_type_id"],
        manufacturer:
            json["manufacturer"] == null ? null : json["manufacturer"],
        model: json["model"] == null ? null : json["model"],
        serialNumber:
            json["serial_number"] == null ? null : json["serial_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "avinya_type_id": avinyaTypeId == null ? null : avinyaTypeId,
        "manufacturer": manufacturer == null ? null : manufacturer,
        "model": model == null ? null : model,
        "serial_number": serialNumber == null ? null : serialNumber,
      };
}

Future<List<Consumable>> fetchConsumables() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/consumables'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Consumable> consumables = await resultsJson
        .map<Consumable>((json) => Consumable.fromJson(json))
        .toList();
    return consumables;
  } else {
    throw Exception('Failed to load Consumables');
  }
}

Future<Consumable> fetchConsumable(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/consumable/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Consumable consumable =
        await resultsJson.map<Consumable>((json) => Consumable.fromJson(json));
    return consumable;
  } else {
    throw Exception('Failed to load Consumable');
  }
}

Future<http.Response> createConsumable(Consumable consumable) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/consumable'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(consumable.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Consumable.');
  }
}

Future<http.Response> updateConsumable(Consumable consumable) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/consumable'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(consumable.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Consumable.');
  }
}

Future<http.Response> deleteConsumable(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/consumable/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Consumable.');
  }
}
