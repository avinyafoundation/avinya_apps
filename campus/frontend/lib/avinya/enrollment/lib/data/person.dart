import 'dart:developer';
import 'dart:typed_data';
import 'package:gallery/avinya/attendance/lib/data/organization_meta_data.dart';
import 'package:gallery/widgets/success_message.dart';
import 'package:gallery/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class Organization {
  int? id;
  String? description;
  String? notes;
  Address? address;
  AvinyaType? avinya_type;
  Name? name;
  String? phone;
  List<ParentOrganization>? parent_organizations;
  var child_organizations = <Organization>[];
  var people = <Person>[];
  var organization_metadata = <OrganizationMetaData>[];

  Organization(
      {this.id,
      this.description,
      this.notes,
      this.address,
      this.avinya_type,
      this.name,
      this.phone,
      this.parent_organizations,
      this.child_organizations = const [],
      this.people = const [],
      this.organization_metadata = const [],
      });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      description: json['description'],
      notes: json['notes'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      avinya_type: json['avinya_type'] != null
          ? AvinyaType.fromJson(json['avinya_type'])
          : null,
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      phone: json['phone'],
      // Safely handle 'parent_organizations' being null
      parent_organizations: json['parent_organizations'] != null
          ? (json['parent_organizations'] as List)
              .map((item) => ParentOrganization.fromJson(item))
              .toList()
          : [],
      child_organizations: json['child_organizations'] != null
          ? List<Organization>.from(
              json['child_organizations'].map((x) => Organization.fromJson(x)))
          : [],
      people: json['people'] != null
          ? List<Person>.from(json['people'].map((x) => Person.fromJson(x)))
          : [],
      organization_metadata: json['organization_metadata'] != null
          ? List<OrganizationMetaData>.from(json['organization_metadata']
              .map((x) => OrganizationMetaData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (address != null) 'address': address!.toJson(),
        if (avinya_type != null) 'avinya_type': avinya_type!.toJson(),
        if (name != null) 'name': name!.toJson(),
        if (phone != null) 'phone': phone,
        // Correctly handling 'parent_organizations' as a list
        if (parent_organizations != null)
          'parent_organizations': parent_organizations!
              .map((parentOrg) => parentOrg.toJson())
              .toList(),
        'child_organizations':
            List<dynamic>.from(child_organizations.map((x) => x.toJson())),
        'people': List<dynamic>.from(people.map((x) => x.toJson())),
        'organization_metadata':
            List<dynamic>.from(organization_metadata.map((x) => x.toJson()))
      };
}

class AvinyaType {
  int? id;
  String? name;
  int? level;
  bool? active;
  String? foundationType;
  String? focus;
  String? globalType;

  AvinyaType({
    this.id,
    this.name,
    this.level,
    this.active,
    this.foundationType,
    this.focus,
    this.globalType,
  });

  factory AvinyaType.fromJson(Map<String, dynamic> json) {
    return AvinyaType(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      active: json['active'],
      foundationType: json['foundation_type'],
      focus: json['focus'],
      globalType: json['global_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (level != null) 'level': level,
        if (active != null) 'active': active,
        if (foundationType != null) 'foundation_type': foundationType,
        if (focus != null) 'focus': focus,
        if (globalType != null) 'global_type': globalType,
      };
}

class Name {
  String? name_en;

  Name({this.name_en});

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      name_en: json['name_en'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (name_en != null) 'name_en': name_en,
      };
}

class ParentOrganization {
  int? id;
  Name? name;

  ParentOrganization({this.id, this.name});

  factory ParentOrganization.fromJson(Map<String, dynamic> json) {
    return ParentOrganization(
      id: json['id'],
      name: json['name'] is Map<String, dynamic>
          ? Name.fromJson(json['name'])
          : null, // Handle cases where 'name' is not a Map
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name?.toJson(),
      };
}

class City {
  int? id;
  Name? name;
  District? district;

  City({this.id, this.name, this.district});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      district:
          json['district'] != null ? District.fromJson(json['district']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name?.toJson(),
        if (district != null) 'district': district?.toJson(),
      };
}

class Address {
  String? record_type;
  int? id;
  String? name_en;
  String? street_address;
  int? phone;
  int? city_id;
  int? district_id;
  City? city;
  District? district;

  Address(
      {this.id,
      this.name_en,
      this.street_address,
      this.phone,
      this.city_id,
      this.district_id,
      this.record_type,
      this.city,
      this.district});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name_en: json['name_en'],
      street_address: json['street_address'],
      phone: json['phone'],
      city_id: json['city_id'],
      district_id: json['district_id'],
      record_type: json['record_type'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      district:
          json['district'] != null ? District.fromJson(json['district']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name_en != null) 'name_en': name_en,
        if (street_address != null) 'street_address': street_address,
        if (phone != null) 'phone': phone,
        if (city_id != null) 'city_id': city_id,
        if (district_id != null) 'district_id': district_id,
        if (record_type != null) 'record_type': record_type,
        // if (city != null) 'city': city,
        if (city != null) 'city': city!.toJson(),
        if (district != null) 'district': district,
      };
}

class UserDocument {
  int? id;
  String? document_type;
  String? document;

  UserDocument({this.id, this.document, this.document_type});

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
        id: json['id'],
        document: json['document'],
        document_type: json['document_type']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (document != null) 'document': document,
        if (document_type != null) 'document_type': document_type
      };
}

class Person {
  int? id;
  String? record_type;
  String? preferred_name;
  String? full_name;
  String? notes;
  String? date_of_birth;
  String? sex;
  int? avinya_type_id;
  String? passport_no;
  int? permanent_address_id;
  int? mailing_address_id;
  String? nic_no;
  String? id_no;
  int? phone;
  int? organization_id;
  Organization? organization;
  int? parent_organization_id;
  AvinyaType? avinya_type;
  String? asgardeo_id;
  String? jwt_sub_id;
  String? jwt_email;
  String? email;
  Address? permanent_address;
  Address? mailing_address;
  String? street_address;
  String? bank_account_number;
  String? bank_name;
  String? bank_branch;
  String? guardian_name;
  int? guardian_contact_number;
  String? digital_id;
  String? bank_account_name;
  int? avinya_phone;
  int? academy_org_id;
  String? created;
  String? updated;
  String? current_job;
  int? documents_id;
  var parent_students = <Person>[];

  Person(
      {this.id,
      this.record_type,
      this.preferred_name,
      this.full_name,
      this.notes,
      this.date_of_birth,
      this.sex,
      this.avinya_type_id,
      this.passport_no,
      this.permanent_address_id,
      this.mailing_address_id,
      this.nic_no,
      this.id_no,
      this.phone,
      this.organization_id,
      this.organization,
      this.parent_organization_id,
      this.avinya_type,
      this.asgardeo_id,
      this.jwt_sub_id,
      this.jwt_email,
      this.email,
      this.permanent_address,
      this.mailing_address,
      this.street_address,
      this.bank_account_number,
      this.bank_name,
      this.bank_branch,
      this.digital_id,
      this.bank_account_name,
      this.guardian_name,
      this.guardian_contact_number,
      this.avinya_phone,
      this.academy_org_id,
      this.created,
      this.updated,
      this.parent_students = const [],
      this.current_job,
      this.documents_id});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
        id: json['id'],
        record_type: json['record_type'],
        preferred_name: json['preferred_name'],
        full_name: json['full_name'],
        notes: json['notes'],
        date_of_birth: json['date_of_birth'],
        sex: json['sex'],
        avinya_type_id: json['avinya_type_id'],
        passport_no: json['passport_no'],
        permanent_address_id: json['permanent_address_id'],
        mailing_address_id: json['mailing_address_id'],
        nic_no: json['nic_no'],
        id_no: json['id_no'],
        phone: json['phone'],
        organization_id: json['organization_id'],
        asgardeo_id: json['asgardeo_id'],
        jwt_sub_id: json['jwt_sub_id'],
        jwt_email: json['jwt_email'],
        email: json['email'],
        permanent_address: Address.fromJson(
            json['permanent_address'] != null ? json['permanent_address'] : {}),
        mailing_address: Address.fromJson(
            json['mailing_address'] != null ? json['mailing_address'] : {}),
        street_address: json['street_address'],
        bank_account_number: json['bank_account_number'],
        bank_name: json['bank_name'],
        bank_branch: json['bank_branch'],
        digital_id: json['digital_id'],
        guardian_name: json['guardian_name'],
        guardian_contact_number: json['guardian_contact_number'],
        bank_account_name: json['bank_account_name'],
        avinya_phone: json['avinya_phone'],
        academy_org_id: json['academy_org_id'],
        organization: Organization.fromJson(
            json['organization'] != null ? json['organization'] : {}),
        parent_organization_id: json['parent_organization_id'],
        avinya_type: AvinyaType.fromJson(
            json['avinya_type'] != null ? json['avinya_type'] : {}),
        created: json['created'],
        updated: json['updated'],
        parent_students: json['parent_students'] != null
            ? json['parent_students']
                .map<Person>((eval_json) => Person.fromJson(eval_json))
                .toList()
            : [],
        current_job: json['current_job'],
        documents_id: json['documents_id']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (record_type != null) 'record_type': record_type,
        if (preferred_name != null) 'preferred_name': preferred_name,
        if (full_name != null) 'full_name': full_name,
        if (notes != null) 'notes': notes,
        if (date_of_birth != null) 'date_of_birth': date_of_birth,
        if (sex != null) 'sex': sex,
        if (avinya_type_id != null) 'avinya_type_id': avinya_type_id,
        if (passport_no != null) 'passport_no': passport_no,
        if (permanent_address_id != null)
          'permanent_address_id': permanent_address_id,
        if (mailing_address_id != null)
          'mailing_address_id': mailing_address_id,
        if (nic_no != null) 'nic_no': nic_no,
        if (id_no != null) 'id_no': id_no,
        if (phone != null) 'phone': phone,
        if (organization != null) 'organization_id': organization!.id,
        if (organization_id != null) 'organization_id': organization_id,
        if (parent_organization_id != null)
          'parent_organization_id': parent_organization_id,
        if (asgardeo_id != null) 'asgardeo_id': asgardeo_id,
        if (jwt_sub_id != null) 'jwt_sub_id': jwt_sub_id,
        if (jwt_email != null) 'jwt_email': jwt_email,
        if (email != null) 'email': email,
        if (permanent_address != null && permanent_address!.toJson().isNotEmpty)
          'permanent_address': permanent_address!.toJson(),
        if (mailing_address != null)
          'mailing_address': mailing_address!.toJson(),
        if (street_address != null) 'street_address': street_address,
        if (bank_account_number != null)
          'bank_account_number': bank_account_number,
        if (bank_name != null) 'bank_name': bank_name,
        if (guardian_name != null) 'guardian_name': guardian_name,
        if (guardian_contact_number != null)
          'guardian_contact_number': guardian_contact_number,
        if (bank_branch != null) 'bank_branch': bank_branch,
        if (digital_id != null) 'digital_id': digital_id,
        if (bank_account_name != null) 'bank_account_name': bank_account_name,
        if (avinya_phone != null) 'avinya_phone': avinya_phone,
        if (academy_org_id != null) 'academy_org_id': academy_org_id,
        // if (organization != null) 'organization': organization!.toJson(),
        // if (avinya_type != null) 'avinya_type': avinya_type!.toJson(),
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        // 'parent_students': [parent_students],
        if (current_job != null) 'current_job': current_job,
        if (documents_id != null) 'documents_id': documents_id,
      };

  map(DataRow Function(dynamic evaluation) param0) {}
}

class District {
  int? id;
  Province? province;
  List<City>? cities;
  Name? name;

  District({this.id, this.province, this.cities, this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      province:
          json['province'] != null ? Province.fromJson(json['province']) : null,
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (province != null) 'province': province?.toJson(),
        if (name != null) 'name': name?.toJson(),
      };
}

class Province {
  int? id;
  Name? name;

  Province({this.id, this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: Name.fromJson(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name?.toJson(),
      };
}

Future<List<UserDocument>?> fetchDocuments(int id) async {
  List<UserDocument>? userDocuments;
  final response = await http.get(
    Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/document_list/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    userDocuments = await resultsJson
        .map<UserDocument>((json) => UserDocument.fromJson(json))
        .toList();
    return userDocuments;
  } else if (response.statusCode >= 500) {
    return null;
  } else {
    throw Exception('Failed to get user documents');
  }
}

Future<List<Person>> fetchPersons(
  int organizationId,
  int avinyaTypeId, {
  int? limit,
  int? offset,
  int? classId,
  String? search,
}) async {
  final uri = Uri.parse(
    '${AppConfig.campusEnrollmentsBffApiUrl}/persons/$organizationId/$avinyaTypeId',
  ).replace(
    queryParameters: {
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
      if (classId != null) 'class_id': classId.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    },
  );

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final List<dynamic> resultsJson = json.decode(response.body);

    return resultsJson
        .map((json) => Person.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception(
      'Failed to get persons data. Status code: ${response.statusCode}',
    );
  }
}


Future<Person> fetchPerson(int? person_id) async {
  final response = await http.get(
    Uri.parse(
        AppConfig.campusEnrollmentsBffApiUrl + '/person_by_id/$person_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode > 199 && response.statusCode < 300) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> createPerson(BuildContext context, Person person) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusEnrollmentsBffApiUrl + '/add_person'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 201) {
    Person person = Person.fromJson(json.decode(response.body));
    showSuccessToast("Student Profile Successfully Created!");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => StudentsScreen(),
    //   ),
    // );
    return person;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    showErrorToast("Student Account Already Exists");
    return person;
    // throw Exception('Failed to create Person.');
  }
}

Future<Person> updatePerson(Person person) async {
  print("update person: ${jsonEncode(person.permanent_address)}");
  print("update person: ${jsonEncode(person.toJson())}");
  final response = await http.put(
    Uri.parse(AppConfig.campusEnrollmentsBffApiUrl + '/update_person'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    Person updatedPerson = Person.fromJson(json.decode(response.body));
    showSuccessToast("Student Profile Successfully Updated!");
    return updatedPerson;
  } else {
    showErrorToast(
        response.body + " Status code =" + response.statusCode.toString());
    return person;
    // throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deletePerson(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Person.');
  }
}

Future<List<AvinyaType>> fetchAvinyaTypes() async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/avinya_types'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<AvinyaType> activityAttendances = await resultsJson
        .map<AvinyaType>((json) => AvinyaType.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception('Failed to get AvinyaType Data');
  }
}



Future<List<Organization>> fetchClasses(int? id) async {
  final uri = Uri.parse(AppConfig.campusProfileBffApiUrl + '/organization')
      .replace(queryParameters: {'id': id.toString()});

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    // Parse the response body as JSON
    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    // Extract the child_organizations_for_dashboard field
    final List<Organization> classes =
        (jsonResponse['child_organizations'] as List)
            .map((data) => Organization.fromJson(data))
            .toList();

    return classes;
  } else {
    throw Exception('Failed to load Classes');
  }
}

Future<List<Organization>> fetchOrganizations() async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/all_organizations'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Organization> activityAttendances = await resultsJson
        .map<Organization>((json) =>Organization.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception('Failed to get Org Data');
  }
}

Future<List<District>> fetchDistricts() async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/districts'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<District> activityAttendances = await resultsJson
        .map<District>((json) => District.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception('Failed to get District Data');
  }
}

Future<List<City>> fetchCities(id) async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/cities/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<City> activityAttendances =
        await resultsJson.map<City>((json) => City.fromJson(json)).toList();
    return activityAttendances;
  } else {
    throw Exception('Failed to get City Data');
  }
}

// Future<http.StreamedResponse?> uploadFile(
//     Uint8List file, Map<String, dynamic> documentDetails) async {
//   try {
//     // Create the multipart request
//     final uri =
//         Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/upload_document');
//     final request = http.MultipartRequest('POST', uri);

//     // Set the headers
//     request.headers.addAll({
//       'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
//       'accept': 'application/ld+json',
//     });

//     // Add the document_details as a JSON string
//     request.fields['document_details'] = jsonEncode(documentDetails);

//     // Determine the MIME type of the file
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

//     // Attach the file to the request
//     request.files.add(
//       http.MultipartFile(
//         'document', // Key for the file in form-data
//         file.readAsBytes().asStream(),
//         file.lengthSync(),
//         filename: basename(file.path),
//         contentType: MediaType.parse(mimeType),
//       ),
//     );

//     // Send the request
//     final response = await request.send();

//     return response;
//   } catch (e) {
//     print('Error uploading file: $e');
//     return null;
//   }
// }

Future<http.StreamedResponse?> uploadFile(
    Uint8List fileBytes, Map<String, dynamic> documentDetails) async {
  try {
    // Create the multipart request
    final uri =
        Uri.parse('${AppConfig.campusEnrollmentsBffApiUrl}/upload_document');
    final request = http.MultipartRequest('POST', uri);

    // Set the headers
    request.headers.addAll({
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
      'accept': 'application/ld+json',
    });

    // Add the document_details as a JSON string
    request.fields['document_details'] = jsonEncode(documentDetails);

    // Determine the MIME type of the file
    final mimeType = lookupMimeType('', headerBytes: fileBytes) ??
        'application/octet-stream';

    // Attach the file to the request
    request.files.add(
      http.MultipartFile(
        'document', // Key for the file in form-data
        Stream.fromIterable([fileBytes]), // Convert Uint8List to stream
        fileBytes.length, // The length of the file
        filename: 'document.png', // Adjust this as needed
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Send the request
    final response = await request.send();

    return response;
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}

Future<List<Organization>> fetchOrganizationsByAvinyaTypeAndStatus(
      int? avinya_type, int? active) async {
    Map<String, String> queryParams = {};

    if (avinya_type != null)
      queryParams['avinya_type'] = avinya_type.toString();
    if (active != null) queryParams['active'] = active.toString();

    final response = await http.get(
      Uri.parse(
              '${AppConfig.campusAttendanceBffApiUrl}/organizations_by_avinya_type_and_status')
          .replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
      },
    );

    if (response.statusCode > 199 && response.statusCode < 300) {
      var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();

      List<Organization> organization = await resultsJson
          .map<Organization>((json) => Organization.fromJson(json))
          .toList();
      return organization;
    } else {
      throw Exception('Failed to load organizations');
    }
  }

