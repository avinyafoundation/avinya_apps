import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Supplier {
  int? id;
  String? name;
  int? phone;
  String? email;
  String? description;

  Supplier({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.description,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        phone: json["phone"] == null ? null : json["phone"],
        email: json["email"] == null ? null : json["email"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "phone": phone == null ? null : phone,
        "email": email == null ? null : email,
        "description": description == null ? null : description,
      };
}

Future<List<Supplier>> fetchSuppliers() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/suppliers'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Supplier> suppliers = await resultsJson
        .map<Supplier>((json) => Supplier.fromJson(json))
        .toList();
    return suppliers;
  } else {
    throw Exception('Failed to load Suppliers');
  }
}

Future<Supplier> fetchSupplier(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplier/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Supplier supplier =
        await resultsJson.map<Supplier>((json) => Supplier.fromJson(json));
    return supplier;
  } else {
    throw Exception('Failed to load Supplier');
  }
}

Future<http.Response> createSupplier(Supplier supplier) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplier'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(supplier.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Supplier.');
  }
}

Future<http.Response> updateSupplier(Supplier supplier) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplier'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(supplier.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Supplier.');
  }
}

Future<http.Response> deleteSupplier(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplier/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Supplier.');
  }
}
