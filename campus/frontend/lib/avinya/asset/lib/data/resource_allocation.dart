import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';
import '../data.dart';

class ResourceAllocation {
  DateTime? endDate;
  int? quantity;
  bool? requested;
  bool? approved;
  int? id;
  bool? allocated;
  DateTime? startDate;
  Asset? asset;
  dynamic consumable;
  Organization? organization;
  Person? person;

  ResourceAllocation({
    this.endDate,
    this.quantity,
    this.requested,
    this.approved,
    this.id,
    this.allocated,
    this.startDate,
    this.asset,
    this.consumable,
    this.organization,
    this.person,
  });

  factory ResourceAllocation.fromJson(Map<String, dynamic> json) {
    return ResourceAllocation(
      id: json['id'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      quantity: json['quantity'],
      requested: json['requested'],
      approved: json['approved'],
      allocated: json['allocated'],
      asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
      consumable: json['consumable'],
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      person: json['person'] != null ? Person.fromJson(json['person']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (quantity != null) 'quantity': quantity,
        if (requested != null) 'requested': requested,
        if (approved != null) 'approved': approved,
        if (allocated != null) 'allocated': allocated,
        if (asset != null) 'asset': asset,
        if (consumable != null) 'consumable': consumable,
        if (organization != null) 'organization': organization,
        if (person != null) 'person': person,
      };
}

Future<List<ResourceAllocation>> fetchResourceAllocation(int id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl +
        '/resource_allocation?resourceAllocationId=$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ResourceAllocation> resourceAllocations = await resultsJson
        .map<ResourceAllocation>((json) => ResourceAllocation.fromJson(json))
        .toList();
    return resourceAllocations;
  } else {
    throw Exception('Failed to load ResourceAllocation');
  }
}

Future<List<ResourceAllocation>> fetchResourceAllocations(int personId) async {
  final response = await http.get(Uri.parse(AppConfig.campusConfigBffApiUrl +
      '/resource_allocation_by_person?personId=$personId'));

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ResourceAllocation> resourceAllocations = await resultsJson
        .map<ResourceAllocation>((json) => ResourceAllocation.fromJson(json))
        .toList();
    return resourceAllocations;
  } else {
    throw Exception('Failed to load ResourceAllocation');
  }
}

Future<http.Response> createResourceAllocation(
    ResourceAllocation resourceAllocation) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/resource_allocation'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(resourceAllocation.toJson()),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to create ResourceAllocation');
  }
}

Future<List<AvinyaType>> fetchAvinyaTypesByAsset() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusConfigBffApiUrl + '/avinyaTypesByAsset'),
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

Future<Asset> fetchAssetByAvinyaType(int id) async {
  final response = await http.get(
    Uri.parse(
        AppConfig.campusConfigBffApiUrl + '/assetByAvinyaType?avinyaType=$id'),
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














// import 'dart:async';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../config/app_config.dart';
// import '../data.dart';

// class ResourceAllocation {
//   int? id;
//   bool? requested;
//   bool? approved;
//   bool? allocated;
//   Asset? asset;
//   Consumable? consumable;
//   Organization? organization;
//   Person? person;
//   int? quantity;
//   String? start_date;
//   String? end_date;

//   ResourceAllocation({
//     this.id,
//     this.requested,
//     this.approved,
//     this.allocated,
//     this.asset,
//     this.consumable,
//     this.organization,
//     this.person,
//     this.quantity,
//     this.start_date,
//     this.end_date,
//   });

//   factory ResourceAllocation.fromJson(Map<String, dynamic> json) {
//     return ResourceAllocation(
//       id: json['id'],
//       requested: json['requested'],
//       approved: json['approved'],
//       allocated: json['allocated'],
//       asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
//       consumable: json['consumable'] != null
//           ? Consumable.fromJson(json['consumable'])
//           : null,
//       organization: json['organization'] != null
//           ? Organization.fromJson(json['organization'])
//           : null,
//       person: json['person'] != null ? Person.fromJson(json['person']) : null,
//       quantity: json['quantity'],
//       start_date: json['start_date'],
//       end_date: json['end_date'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         if (id != null) 'id': id,
//         if (requested != null) 'requested': requested,
//         if (approved != null) 'approved': approved,
//         if (allocated != null) 'allocated': allocated,
//         if (asset != null) 'asset': asset,
//         if (consumable != null) 'consumable': consumable,
//         if (organization != null) 'organization': organization,
//         if (person != null) 'person': person,
//         if (quantity != null) 'quantity': quantity,
//         if (start_date != null) 'start_date': start_date,
//         if (end_date != null) 'end_date': end_date,
//       };

//   Future<List<ResourceAllocation>> fetchResourceAllocations() async {
//     final response = await http.get(
//       Uri.parse(AppConfig.campusConfigBffApiUrl + '/resource_allocations'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'accept': 'application/json',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//     );

//     if (response.statusCode == 200) {
//       var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//       List<ResourceAllocation> resourceAllocations = await resultsJson
//           .map<ResourceAllocation>((json) => ResourceAllocation.fromJson(json))
//           .toList();
//       return resourceAllocations;
//     } else {
//       throw Exception('Failed to load ResourceAllocation');
//     }
//   }

//   Future<List<ResourceAllocation>> fetchResourceAllocationsByPersonId(
//       int id) async {
//     final response = await http.get(
//       Uri.parse(AppConfig.campusConfigBffApiUrl +
//           '/resource_allocation_by_person?personId=$id'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'accept': 'application/json',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//     );

//     if (response.statusCode == 200) {
//       var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//       List<ResourceAllocation> resourceAllocations = await resultsJson
//           .map<ResourceAllocation>((json) => ResourceAllocation.fromJson(json))
//           .toList();
//       return resourceAllocations;
//     } else {
//       throw Exception('Failed to load ResourceAllocation');
//     }
//   }

//   Future<List<ResourceAllocation>> fetchResourceAllocation(int id) async {
//     final response = await http.get(
//       Uri.parse(AppConfig.campusConfigBffApiUrl +
//           '/resource_allocation?resourceAllocationId=$id'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'accept': 'application/json',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//     );

//     if (response.statusCode == 200) {
//       var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//       List<ResourceAllocation> resourceAllocations = await resultsJson
//           .map<ResourceAllocation>((json) => ResourceAllocation.fromJson(json))
//           .toList();
//       return resourceAllocations;
//     } else {
//       throw Exception('Failed to load ResourceAllocation');
//     }
//   }

//   Future<http.Response> createResourceAllocation(
//       ResourceAllocation resourceAllocation) async {
//     final response = await http.post(
//       Uri.parse(AppConfig.campusConfigBffApiUrl + '/resource_allocation'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//       body: jsonEncode(resourceAllocation.toJson()),
//     );
//     if (response.statusCode == 200) {
//       return response;
//     } else {
//       throw Exception('Failed to create ResourceAllocation.');
//     }
//   }

//   Future<http.Response> updateResourceAllocation(
//       ResourceAllocation resourceAllocation) async {
//     final response = await http.put(
//       Uri.parse(AppConfig.campusConfigBffApiUrl + '/resource_allocation'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//       body: jsonEncode(resourceAllocation.toJson()),
//     );
//     if (response.statusCode == 200) {
//       return response;
//     } else {
//       throw Exception('Failed to update ResourceAllocation.');
//     }
//   }

//   Future<http.Response> deleteResourceAllocation(int id) async {
//     final response = await http.delete(
//       Uri.parse(AppConfig.campusConfigBffApiUrl + '/resource_allocation/$id'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer ' + AppConfig.campusConfigBffApiKey,
//       },
//     );
//     if (response.statusCode == 200) {
//       return response;
//     } else {
//       throw Exception('Failed to delete ResourceAllocation.');
//     }
//   }
// }
