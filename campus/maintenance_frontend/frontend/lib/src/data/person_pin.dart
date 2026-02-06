import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class PersonPin {
  static Future<Map<String, dynamic>?> validatePin(String pin) async {
    final response = await http.post(
      Uri.parse('${AppConfig.campusMaintenanceBffApiUrl}/validate_pin'),
      headers: {'Content-Type': 'application/json', 'api-key': AppConfig.maintenanceAppBffApiKey,},
      body: jsonEncode({'pin_hash': pin}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    }

    if (response.statusCode == 404) return null;

    throw Exception('Unexpected response: ${response.statusCode}');
  }
}
