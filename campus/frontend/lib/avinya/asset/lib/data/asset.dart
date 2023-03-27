import 'package:ShoolManagementSystem/src/data/avinya_type.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Asset {
  int? id;
  String? name;
  String? manufacturer;
  String? model;
  String? serialNumber;
  String? registrationNumber;
  String? description;
  // int? avinya_type_id;
  AvinyaType? avinya_type_id;

  Asset({
    this.id,
    this.name,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.registrationNumber,
    this.description,
    this.avinya_type_id,
    // this.avinyaTypeId,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      serialNumber: json['serial_number'],
      registrationNumber: json['registration_number'],
      description: json['description'],
      // avinya_type_id: json['avinya_type_id'],
      avinya_type_id: json['avinya_type_id'] != null
          ? AvinyaType.fromJson(json['id'])
          : null,
    );
  }

  get avinya_type => null;

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "manufacturer": manufacturer == null ? null : manufacturer,
        "model": model == null ? null : model,
        "serial_number": serialNumber == null ? null : serialNumber,
        "registration_number":
            registrationNumber == null ? null : registrationNumber,
        "description": description == null ? null : description,
        "avinya_type_id": avinya_type_id == null ? null : avinya_type_id,
        // "avinya_type_id": avinyaTypeId == null ? null : avinyaTypeId,
      };
}

Future<List<Asset>> fetchAssets() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/assets'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Asset> assets =
        await resultsJson.map<Asset>((json) => Asset.fromJson(json)).toList();
    return assets;
  } else {
    throw Exception('Failed to load Assets');
  }
}

Future<Asset> fetchAsset(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/asset?assetId=$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Asset asset = await resultsJson.map<Asset>((json) => Asset.fromJson(json));
    return asset;
  } else {
    throw Exception('Failed to load Asset');
  }
}

Future<http.Response> createAsset(Asset asset) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/asset'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(asset.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Asset.');
  }
}

Future<http.Response> updateAsset(Asset asset) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/asset'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(asset.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Asset.');
  }
}

Future<http.Response> deleteAsset(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/asset?assetId=$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Asset.');
  }
}
