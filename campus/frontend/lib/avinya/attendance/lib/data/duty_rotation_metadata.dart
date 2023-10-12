

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:gallery/config/app_config.dart';

class DutyRotationMetaDetails{

 int? id;
 String? start_date;
 String? end_date;
 int? organization_id;
 
 DutyRotationMetaDetails({
   this.id,
   this.start_date,
   this.end_date,
   this.organization_id,
 });

 factory DutyRotationMetaDetails.fromJson(Map<String,dynamic>  json){
  log(json.toString());
  return DutyRotationMetaDetails(
     id: json['id'],
     start_date: json['start_date'],
     end_date: json['end_date'],
     organization_id: json['organization_id'],
  );
 }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (start_date != null) 'start_date': start_date,
        if (end_date != null) 'end_date': end_date,
        if (organization_id !=null) 'organization_id' : organization_id,
      };

}

Future<DutyRotationMetaDetails> updateDutyRotationMetadata(DutyRotationMetaDetails dutyRotationMetadata) async {
  final response = await http.put(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/update_duty_rotation_metadata'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(dutyRotationMetadata.toJson()),
  );
  if (response.statusCode == 200) {
    return DutyRotationMetaDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update Duty Rotation.');
  }
}

Future<DutyRotationMetaDetails> fetchDutyRotationMetadataByOrganization(int organization_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/duty_rotation_metadata_by_organization/$organization_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    DutyRotationMetaDetails dutyRotationMetaDetails = DutyRotationMetaDetails.fromJson(json.decode(response.body));
    print(dutyRotationMetaDetails.toJson());
    return dutyRotationMetaDetails;
  } else {
    throw Exception('Failed to load duty rotation metadata');
  }
}