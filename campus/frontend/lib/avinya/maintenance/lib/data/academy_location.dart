import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AcademyLocation {
  int? id;
  int? organizationId;
  String? name;
  String? description;

  AcademyLocation({
    this.id,
    this.organizationId,
    this.name,
    this.description,
  });

  // Create AcademyLocation instance from JSON
  factory AcademyLocation.fromJson(Map<String, dynamic> json) {
    return AcademyLocation(
      id: json['id'],
      organizationId: json['organization_id'],
      name: json['location_name'],
      description: json['description'],
    );
  }

  // Convert AcademyLocation instance to JSON
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (organizationId != null) 'organization_id': organizationId,
        if (name != null) 'location_name': name,
        if (description != null) 'description': description,
      };
}

// Function to create a new Academy Location via POST request
Future<http.Response> createAcademyLocation(
    AcademyLocation academyLocation) async {
  try {
    final resposne = await http.post(
      Uri.parse(
          '${AppConfig.campusMaintenanceBffApiUrl}/organizations/${academyLocation.organizationId}/locations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(academyLocation.toJson()),
    );

    if (resposne.statusCode == 200 || resposne.statusCode == 201) {
      return resposne;
    } else {
      throw Exception(
          'Failed to create academy location. Status code: ${resposne.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Error creating academy location: $error');
  }
}

// Function to fetch all Academy Locations for a given organization via GET request
Future<List<AcademyLocation>> fetchAllAcademyLocations(
    int organizationId) async {
  try {
    final response = await http.get(Uri.parse(
        '${AppConfig.campusMaintenanceBffApiUrl}/organizations/$organizationId/locations'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<AcademyLocation> locations =
          body.map((json) => AcademyLocation.fromJson(json)).toList();
      return locations;
    } else {
      throw Exception(
          'Failed to load academy locations. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Error fetching academy locations: $error');
  }
}
