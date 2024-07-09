import 'dart:ui';
import 'package:gallery/avinya/asset_admin/lib/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gallery/config/app_config.dart';

class StockReplenishment {
  int? id;
  int? avinya_type_id;
  int? consumable_id;
  int? person_id;
  int? organization_id;
  String? updated;
  AvinyaType? avinya_type;
  double? quantity;
  double? quantity_in;
  double? quantity_out;
  ResourceProperty? resource_property;
  Consumable? consumable;

  StockReplenishment(
      {this.id,
      this.avinya_type_id,
      this.consumable_id,
      this.person_id,
      this.organization_id,
      this.updated,
      this.avinya_type,
      this.quantity,
      this.quantity_in,
      this.quantity_out,
      this.resource_property,
      this.consumable});

  factory StockReplenishment.fromJson(Map<String, dynamic> json) =>
      StockReplenishment(
        id: json["id"] == null ? null : json["id"],
        avinya_type_id:
            json["avinya_type_id"] == null ? null : json["avinya_type_id"],
        consumable_id:
            json["consumable_id"] == null ? null : json["consumable_id"],
        person_id: json["person_id"] == null ? null : json["person_id"],
        organization_id:
            json["organization_id"] == null ? null : json["organization_id"],
        updated: json["updated"] == null ? null : json["updated"],
        avinya_type: json['avinya_type'] == null
            ? null
            : AvinyaType.fromJson(json['avinya_type']),
        quantity: json["quantity"] == null ? null : json["quantity"],
        quantity_in: json["quantity_in"] == null ? null : json["quantity_in"],
        quantity_out:
            json["quantity_out"] == null ? null : json["quantity_out"],
        resource_property: json['resource_property'] == null
            ? null
            : ResourceProperty.fromJson(json['resource_property']),
        consumable: json['consumable'] == null
            ? null
            : Consumable.fromJson(json['consumable']),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "avinya_type_id": avinya_type_id == null ? null : avinya_type_id,
        "consumable_id": consumable_id == null ? null : consumable_id,
        "person_id": person_id == null ? null : person_id,
        "organization_id": organization_id == null ? null : organization_id,
        "updated": updated == null ? null : updated,
        "avinya_type": avinya_type == null ? null : avinya_type,
        "quantity": quantity == null ? null : quantity,
        "quantity_in": quantity_in == null ? null : quantity_in,
        "quantity_out": quantity_out == null ? null : quantity_out,
        "resource_property":
            resource_property == null ? null : resource_property,
        "consumable": consumable == null ? null : consumable,
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
    var resultsJson = json.decode(response.body)['data']
        ['consumable_replenishment'] as List<dynamic>;
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
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

Future<List<StockReplenishment>> getConsumableMonthlyReport(
    int organization_id,
    int year,
    int month
    ) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAssetsBffApiUrl}/consumable_monthly_report/$organization_id/$year/$month'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<StockReplenishment> consumableMonthlySummaryData = await resultsJson
        .map<StockReplenishment>((json) => StockReplenishment.fromJson(json))
        .toList();
    return consumableMonthlySummaryData;
  } else {
    throw Exception('Failed to get Consumable Monthly Summary Data');
  }
}

Future<List<StockReplenishment>> getConsumableWeeklyReport(
    int organization_id, String from_date, String to_date) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAssetsBffApiUrl}/consumable_weekly_report/$organization_id/$from_date/$to_date'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<StockReplenishment> consumableWeeklySummaryData = await resultsJson
        .map<StockReplenishment>((json) => StockReplenishment.fromJson(json))
        .toList();
    return consumableWeeklySummaryData;
  } else {
    throw Exception('Failed to get Consumable Weekly Summary Data');
  }
}
