import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Supply {
  int? id;
  int? asset_id;
  int? consumable_id;
  int? supplier_id;
  int? person_id;
  String? order_date;
  String? delivery_date;
  String? order_id;
  int? order_amount;

  Supply({
    this.id,
    this.asset_id,
    this.consumable_id,
    this.supplier_id,
    this.person_id,
    this.order_date,
    this.delivery_date,
    this.order_id,
    this.order_amount,
  });

  factory Supply.fromJson(Map<String, dynamic> json) => Supply(
        id: json["id"] == null ? null : json["id"],
        asset_id: json["asset_id"] == null ? null : json["asset_id"],
        consumable_id:
            json["consumable_id"] == null ? null : json["consumable_id"],
        supplier_id: json["supplier_id"] == null ? null : json["supplier_id"],
        person_id: json["person_id"] == null ? null : json["person_id"],
        order_date: json["order_date"] == null ? null : json["order_date"],
        delivery_date:
            json["delivery_date"] == null ? null : json["delivery_date"],
        order_id: json["order_id"] == null ? null : json["order_id"],
        order_amount:
            json["order_amount"] == null ? null : json["order_amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "asset_id": asset_id == null ? null : asset_id,
        "consumable_id": consumable_id == null ? null : consumable_id,
        "supplier_id": supplier_id == null ? null : supplier_id,
        "person_id": person_id == null ? null : person_id,
        "order_date": order_date == null ? null : order_date,
        "delivery_date": delivery_date == null ? null : delivery_date,
        "order_id": order_id == null ? null : order_id,
        "order_amount": order_amount == null ? null : order_amount,
      };
}

Future<List<Supply>> fetchSupplies() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplies'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Supply> supplies =
        await resultsJson.map<Supply>((json) => Supply.fromJson(json)).toList();
    return supplies;
  } else {
    throw Exception('Failed to load Supplies');
  }
}

Future<Supply> fetchSupply(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplies/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Supply supply =
        await resultsJson.map<Supply>((json) => Supply.fromJson(json));
    return supply;
  } else {
    throw Exception('Failed to load Supply');
  }
}

Future<http.Response> createSupply(Supply supply) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplies'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(supply.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create Supply.');
  }
}

Future<http.Response> updateSupply(Supply supply) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplies'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
    body: jsonEncode(supply.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Supply.');
  }
}

Future<http.Response> deleteSupply(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/supplies/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Supply.');
  }
}
