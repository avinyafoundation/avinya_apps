import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/config/app_config.dart';

class PersonFcmToken {
  int? id;
  int? person_id;
  String? fcm_token;
  String? created;
  String? updated;

  PersonFcmToken(
      {this.id,
      this.person_id,
      this.fcm_token,
      this.created,
      this.updated});

  factory PersonFcmToken.fromJson(Map<String, dynamic> json) {
    return PersonFcmToken(
        id: json['id'],
        person_id: json['person_id'],
        fcm_token: json['fcm_token'],
        created: json['created'],
        updated: json['updated']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (fcm_token != null) 'fcm_token':fcm_token,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated
      };
}

// Future<ActivityParticipant> createActivityParticipant(
//     ActivityParticipant activityParticipant) async {
//   final response = await http.post(
//     Uri.parse('${AppConfig.campusAlumniBffApiUrl}/create_activity_participant'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//     },
//     body: jsonEncode(activityParticipant.toJson()),
//   );
//   if (response.statusCode > 199 && response.statusCode < 300) {
//     return ActivityParticipant.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to create activity participant.');
//   }
// }

// Future<JobPost> createJobPost(
//     Uint8List? fileBytes, JobPost jobPostDetails) async {
//   try {
//     //final jobPostObject;
//     // Create the multipart request
//     final uri = Uri.parse('${AppConfig.campusAlumniBffApiUrl}/create_job_post');
//     final request = http.MultipartRequest('POST', uri);

//     // Set the headers
//     request.headers.addAll({
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//       'accept': 'application/json',
//     });

//     // Add the job post details as a JSON string
//     request.fields['job_post_details'] = jsonEncode(jobPostDetails);

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

//     //String responseBody;

//     if (response.statusCode == 201) {
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
