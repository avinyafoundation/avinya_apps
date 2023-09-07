

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';

class DutyRotationMetadata{

 int? id;
 String? start_date;
 String? end_date;
 
 DutyRotationMetadata({
   this.id,
   this.start_date,
   this.end_date,
 });

 factory DutyRotationMetadata.fromJson(Map<String,dynamic>  json){
  log(json.toString());
  return DutyRotationMetadata(
     id: json['id'],
     start_date: json['start_date'],
     end_date: json['end_date'],
  );
 }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (start_date != null) 'start_date': start_date,
        if (end_date != null) 'end_date': end_date,
      };

}

Future<DutyRotationMetadata> updateDutyRotation(DutyRotationMetadata dutyRotationMetadata) async {
  final response = await http.put(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/update_duty_rotation'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(dutyRotationMetadata.toJson()),
  );
  if (response.statusCode == 200) {
    return DutyRotationMetadata.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update Duty Rotation.');
  }
}