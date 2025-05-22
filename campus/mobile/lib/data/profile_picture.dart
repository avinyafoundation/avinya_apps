import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mobile/widgets/error_message.dart';
import 'package:mobile/widgets/success_message.dart';


class ProfilePicture {
  int? id;
  int? person_id;
  String? profile_picture_drive_id;
  String? picture;
  String? nic_no;
  String? uploaded_by;
  String? created;
  String? updated;

  ProfilePicture(
      {this.id,
      this.person_id,
      this.profile_picture_drive_id,
      this.picture,
      this.nic_no,
      this.uploaded_by,
      this.created,
      this.updated});

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(
      id: json['id'],
      person_id: json['person_id'],
      profile_picture_drive_id: json['profile_picture_drive_id'],
      picture: json['picture'],
      nic_no: json['nic_no'],
      uploaded_by: json['uploaded_by'],
      created: json['created'],
      updated: json['updated']
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (profile_picture_drive_id != null) 'profile_picture_drive_id': profile_picture_drive_id,
        if (picture != null) 'picture': picture,
        if (nic_no != null) 'nic_no': nic_no,
        if (uploaded_by != null) 'uploaded_by': uploaded_by,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated
      };
}

Future<ProfilePicture> uploadProfilePicture(
    Uint8List fileBytes, Map<String, dynamic> profilePictureDetails) async {
  try {
    //final profilePictureObject;
    // Create the multipart request
    final uri =
        Uri.parse('${AppConfig.campusAlumniBffApiUrl}/upload_person_profile_picture');
    final request = http.MultipartRequest('POST', uri);

    // Set the headers
    request.headers.addAll({
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
      'accept': 'application/ld+json',
    });

    // Add the profile picture details as a JSON string
    request.fields['profile_picture_details'] = jsonEncode(profilePictureDetails);

    // Determine the MIME type of the file
    final mimeType = lookupMimeType('', headerBytes: fileBytes) ??
        'application/octet-stream';

    // Attach the profile picture to the request
    request.files.add(
      http.MultipartFile(
        'profile_picture', // Key for the file in form-data
        Stream.fromIterable([fileBytes]), // Convert Uint8List to stream
        fileBytes.length, // The length of the file
        //filename: 'document.png', // Adjust this as needed
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Send the request
    final response = await request.send();

    // Convert StreamedResponse to a String
    final responseBody = await response.stream.bytesToString();

    if(response.statusCode == 201){
      //Decoded Json response
      final decoded = jsonDecode(responseBody);

      // If you're using a model class
      final profilePictureObject = ProfilePicture.fromJson(decoded);

      return profilePictureObject;
    }else{
      throw Exception('Failed: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    throw Exception('Failed To Upload Profile Picture');
    
  }
}

Future<int> deleteProfilePictureById(int id) async {
  try{
  final response = await http.delete(
    Uri.parse('${AppConfig.campusAlumniBffApiUrl}/person_profile_picture_by_id/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return int.parse(response.body);
  } else {
    throw Exception('Failed To Delete Person Profile Picture.');
  }
  }catch(e){
    throw Exception('Failed To Delete Profile Picture');
  }
}

