import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class AddressType {
  int? id;
  String? name;
  String? description;

  AddressType({
    this.id,
    this.name,
    this.description,
  });

  factory AddressType.fromJson(Map<String, dynamic> json) {
    return AddressType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      };
}

Future<List<AddressType>> fetchAddressTypes() async {
  final response =
      await http.get(Uri.parse(AppConfig.apiUrl + '/sms/util/addresstypes'));

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<AddressType> addressTypes = await resultsJson
        .map<AddressType>((json) => AddressType.fromJson(json))
        .toList();
    return addressTypes;
  } else {
    throw Exception('Failed to load AddressType');
  }
}

Future<AddressType> fetchAddressType(String id) async {
  final response = await http
      .get(Uri.parse(AppConfig.apiUrl + '/sms/util/addresstypes/$id'));

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    AddressType addressType = await resultsJson
        .map<AddressType>((json) => AddressType.fromJson(json));
    return addressType;
  } else {
    throw Exception('Failed to load AddressType');
  }
}

Future<http.Response> createAddressType(AddressType addressType) async {
  final response = await http.post(
    Uri.parse(AppConfig.apiUrl + '/sms/util/addresstypes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(addressType.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create AddressType.');
  }
}

Future<http.Response> updateAddressType(AddressType addressType) async {
  final response = await http.put(
    Uri.parse(AppConfig.apiUrl + '/sms/util/addresstypes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(addressType.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update AddressType.');
  }
}

Future<http.Response> deleteAddressType(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.apiUrl + '/sms/util/addresstypes/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete AddressType.');
  }
}
