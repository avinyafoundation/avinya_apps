import 'dart:ui';
import 'package:gallery/avinya/asset_admin/lib/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gallery/config/app_config.dart';

class StockReplenishment {
  int? id;
  String? name;
  String? description;
  AvinyaType? avinya_type;
  String? manufacturer;
  int? quantity;
  int? quantity_in;
  int? quantity_out;
  ResourceProperty? resource_property;

  StockReplenishment({
    this.id,
    this.name,
    this.description,
    this.avinya_type,
    this.manufacturer,
    this.quantity,
    this.quantity_in,
    this.quantity_out,
    this.resource_property,
  });

  factory StockReplenishment.fromJson(Map<String, dynamic> json) =>
      StockReplenishment(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        avinya_type: AvinyaType.fromJson(json['avinya_type']),
        manufacturer:
            json["manufacturer"] == null ? null : json["manufacturer"],
        quantity: json["quantity"] == null ? null : json["quantity"],
        quantity_in: json["quantity_in"] == null ? null : json["quantity_in"],
        quantity_out:
            json["quantity_out"] == null ? null : json["quantity_out"],
        resource_property: ResourceProperty.fromJson(json['resource_property']),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "avinya_type": avinya_type == null ? null : avinya_type,
        "manufacturer": manufacturer == null ? null : manufacturer,
        "quantity": quantity == null ? null : quantity,
        "quantity_in": quantity_in == null ? null : quantity_in,
        "quantity_out": quantity_out == null ? null : quantity_out,
        "resource_property":
            resource_property == null ? null : resource_property,
      };
}

Future<List<StockReplenishment>> addConsumableReplenishment(
    List<StockReplenishment> stockList) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusAssetsBffApiUrl}/consumable_replenishment'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(stockList.map((stockList) => stockList.toJson()).toList()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    // return StockReplenishment.fromJson(jsonDecode(response.body));
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<StockReplenishment> stockList = await resultsJson
        .map<StockReplenishment>((json) => StockReplenishment.fromJson(json))
        .toList();
    return stockList;
  } else {
    throw Exception('Failed to create Activity Participant Attendance.');
  }
}

Future<List<StockReplenishment>> getStockListforReplenishment(
    int? organization_id, String to_date) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAssetsBffApiUrl}/inventory_data_by_organization/$organization_id/$to_date'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<StockReplenishment> stockList = await resultsJson
        .map<StockReplenishment>((json) => StockReplenishment.fromJson(json))
        .toList();
    return stockList;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendance report for organization ID $organization_id and activity');
  }
}
