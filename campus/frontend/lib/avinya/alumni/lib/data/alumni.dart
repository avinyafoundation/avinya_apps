import 'dart:convert';

import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
class Alumni {
  int? id;
  String? status;
  int? person_count;
  String? company_name;
  String? job_title;
  String? linkedin_id;
  String? facebook_id;
  String? instagram_id;
  String? updated_by;
  String? created;
  String? updated;

  Alumni({
    this.id,
    this.status,
    this.person_count,
    this.company_name,
    this.job_title,
    this.linkedin_id,
    this.facebook_id,
    this.instagram_id,
    this.updated_by,
    this.created,
    this.updated
  });

  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['id'],
      status: json['status'],
      person_count: json['person_count'],
      company_name: json['company_name'],
      job_title: json['job_title'],
      linkedin_id: json['linkedin_id'],
      facebook_id:json['facebook_id'],
      instagram_id: json['instagram_id'],
      updated_by:json['updated_by'],
      created: json['created'],
      updated: json['updated']
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (status != null) 'status': status,
        if (person_count != null) 'person_count': person_count,
        if (company_name != null) 'company_name': company_name,
        if (job_title != null) 'job_title': job_title,
        if (linkedin_id !=null) 'linkedin_id': linkedin_id,
        if (facebook_id !=null) 'facebook_id': facebook_id,
        if (instagram_id !=null) 'instagram_id':instagram_id,
        if (updated_by !=null) 'updated_by': updated_by,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated
      };
}

Future<List<Alumni>> fetchAlumniSummaryList(int? alumni_batch_id) async {
  final response = await http.get(
    Uri.parse(
        AppConfig.campusAlumniBffApiUrl + '/alumni_summary/$alumni_batch_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Alumni> alumniSummaryList =
        await resultsJson.map<Alumni>((json) => Alumni.fromJson(json)).toList();
    return alumniSummaryList;
  } else {
    throw Exception('Failed to get alumni summary list Data');
  }
}
