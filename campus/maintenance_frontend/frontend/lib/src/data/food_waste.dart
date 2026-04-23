import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

//Get data for the smarboard food waste chart (Most recent 7 days)
Future<List<Map<String, dynamic>>> getFoodWasteData(
  int organizationId,
  int days,
) async {
  final uri = Uri.parse(
    '${AppConfig.campusFoodWasteBffApiUrl}/analytics/organizations/$organizationId/waste?days=$days',
  );

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'api-key': AppConfig.foodWasteBffApiKey,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> dailyWaste = responseData['daily_waste'] as List<dynamic>? ?? [];
      
      return dailyWaste.map<Map<String, dynamic>>((item) {
        return {
          'date': item['date'] as String? ?? '',
          'total_waste': item['total_waste'] as double? ?? 0.0,
        };
      }).toList();
    } else {
      throw Exception('Failed to get Food Waste Data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching food waste data: $e');
    return [];
  }
}