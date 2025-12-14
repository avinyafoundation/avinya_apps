import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/config/app_config.dart';

class CvRequest {
  int? id;
  int? person_id;
  int? phone;
  String? status;
  String? created;
  String? updated;

  CvRequest(
      {this.id,
      this.person_id,
      this.phone,
      this.status,
      this.created,
      this.updated});

  factory CvRequest.fromJson(Map<String, dynamic> json) {
    return CvRequest(
        id: json['id'],
        person_id: json['person_id'],
        phone: json['phone'],
        status: json['status'],
        created: json['created'],
        updated: json['updated']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (phone != null) 'phone': phone,
        if (status != null) 'status': status,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated
      };
}

Future<CvRequest> createCvRequest(CvRequest cvRequest, int personId) async {
  try {
    final response = await http.post(
      Uri.parse(
          '${AppConfig.campusAlumniBffApiUrl}/alumni/$personId/cv_requests'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
      },
      body: jsonEncode(cvRequest.toJson()),
    );
    if (response.statusCode > 199 && response.statusCode < 300) {
      return CvRequest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create cv request.');
    }
  } catch (e) {
    throw Exception('Error creating CV Request: $e');
  }
}

Future<CvRequest?> fetchLatestCvRequest(int personId) async {
  try{
    final response = await http.get(
      Uri.parse('${AppConfig.campusAlumniBffApiUrl}/alumni/$personId/cv_requests/last'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
      },
    );
    //No content
    if (response.statusCode == 204) {
      return null;
    }

    if (response.statusCode == 200) {
      
      final body = response.body.trim();

      // empty, null, or {}
      if (body.isEmpty || body == "null") {
        return null;
      }

      CvRequest cvRequest = CvRequest.fromJson(json.decode(response.body));
      return cvRequest;

    } else {
      throw Exception('Failed to load Latest Cv Request');
    }
  }catch(e){
    throw Exception('Error fetching latest CV request: $e');
  }
}

// Future<JobPost> updateJobPost(
//     Uint8List? fileBytes, JobPost updateJobPostDetails) async {
//   try {
//     //final jobPostObject;
//     // Create the multipart request
//     final uri = Uri.parse('${AppConfig.campusAlumniBffApiUrl}/update_job_post');
//     final request = http.MultipartRequest('PUT', uri);

//     // Set the headers
//     request.headers.addAll({
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//       'accept': 'application/json',
//     });

//     // Add the job post details as a JSON string
//     request.fields['job_post_details'] = jsonEncode(updateJobPostDetails);

//     // Determine the MIME type of the file
//     final mimeType = lookupMimeType('', headerBytes: fileBytes) ??
//         'application/octet-stream';

//     // Attach the job post picture to the request
//     if (fileBytes != null) {
//       request.files.add(
//         http.MultipartFile(
//           'job_post_picture', // Key for the file in form-data
//           Stream.fromIterable([fileBytes]), // Convert Uint8List to stream
//           fileBytes.length, // The length of the file
//           //filename: 'document.png', // Adjust this as needed
//           contentType: MediaType.parse(mimeType),
//         ),
//       );
//     }

//     // Send the request
//     final response = await request.send();

//     // Convert StreamedResponse to a String
//     final bytes = await response.stream.toBytes();

//     final responseBody = utf8.decode(bytes, allowMalformed: true);

//     if (response.statusCode == 200) {
//       //Decoded Json response
//       final decoded = jsonDecode(responseBody);

//       final jobPostObject = JobPost.fromJson(decoded);

//       return jobPostObject;
//     } else {
//       throw Exception('Failed: ${response.statusCode} - $responseBody');
//     }
//   } catch (e) {
//     throw Exception('Failed To Upload Job Post');
//   }
// }

// Future<int> deleteJobPost(JobPost jobPost) async {
//   final response = await http.delete(
//       Uri.parse('${AppConfig.campusAlumniBffApiUrl}/job_post'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'accept': 'application/json',
//         'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//       },
//       body: jsonEncode(jobPost.toJson()));
//   if (response.statusCode > 199 && response.statusCode < 300) {
//     return int.parse(response.body);
//   } else {
//     throw Exception('Failed to delete Job Post.');
//   }
// }

// Future<JobPost> fetchJobPost(int id) async {
//   final response = await http.get(
//     Uri.parse('${AppConfig.campusAlumniBffApiUrl}/job_post/$id'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'accept': 'application/json',
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//     },
//   );

//   if (response.statusCode == 200) {
//     JobPost jobPost = JobPost.fromJson(json.decode(response.body));
//     return jobPost;
//   } else {
//     throw Exception('Failed to load Job Post');
//   }
// }

// Future<List<JobPost>> fetchJobPosts(int result_limit, int offset) async {
//   final response = await http.get(
//     Uri.parse(
//         '${AppConfig.campusAlumniBffApiUrl}/job_posts/$result_limit/$offset'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'accept': 'application/json',
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//     },
//   );
//   if (response.statusCode > 199 && response.statusCode < 300) {
//     var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
//     List<JobPost> jobPosts = await resultsJson
//         .map<JobPost>((json) => JobPost.fromJson(json))
//         .toList();
//     print("job posts" + "$jobPosts");
//     return jobPosts;
//   } else {
//     throw Exception('Failed to get Job Posts');
//   }
// }
