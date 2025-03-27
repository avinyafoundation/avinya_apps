import 'dart:developer';

import 'package:flutter/src/material/data_table.dart';
import 'package:gallery/avinya/attendance/lib/data.dart';
import 'package:gallery/avinya/attendance/lib/data/organization_meta_data.dart';
// import 'package:gallery/data/address.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

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

class City {
  int? id;
  Name? name;
  District? district;
  double? latitude;
  double? longitude;

  City({this.id, this.name, this.district, this.latitude, this.longitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
        id: json['id'],
        name: json['name'] != null ? Name.fromJson(json['name']) : null,
        district: json['district'] != null
            ? District.fromJson(json['district'])
            : null,
        latitude: json['latitude'],
        longitude: json['longitude']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name?.toJson(),
        if (district != null) 'district': district?.toJson(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
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

class Name {
  String? name_en;
  String? name_si;
  String? name_ta;

  Name({
    this.name_en,
    this.name_si,
    this.name_ta,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      name_en: json['name_en'],
      name_si: json['name_si'],
      name_ta: json['name_ta'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (name_en != null) 'name_en': name_en,
        if (name_si != null) 'name_si': name_si,
        if (name_ta != null) 'name_ta': name_ta,
        // if (address != null) 'address': address!.toJson(),
        // if (employees != null) 'employees': List<dynamic>.from(employees!.map((x) => x.toJson())),
      };
}

class Organization {
  int? id;
  Name? name;
  String? description;
  var child_organizations = <Organization>[];
  var parent_organizations = <Organization>[];
  var child_organizations_for_dashboard = <Organization>[];
  var people = <Person>[];
  var organization_metadata = <OrganizationMetaData>[];

  Organization({
    this.id,
    this.name,
    this.description,
    this.child_organizations = const [],
    this.parent_organizations = const [],
    this.child_organizations_for_dashboard = const [],
    this.people = const [],
    this.organization_metadata = const [],
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      description: json['description'],
      child_organizations: json['child_organizations'] != null
          ? List<Organization>.from(
              json['child_organizations'].map((x) => Organization.fromJson(x)))
          : [],
      parent_organizations: json['parent_organizations'] != null
          ? List<Organization>.from(
              json['parent_organizations'].map((x) => Organization.fromJson(x)))
          : [],
      child_organizations_for_dashboard:
          json['child_organizations_for_dashboard'] != null
              ? List<Organization>.from(
                  json['child_organizations_for_dashboard']
                      .map((x) => Organization.fromJson(x)))
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
        // if (name != null) 'name': name,
        // if (name != null) 'name': Name!.toJson(),
        if (name != null) 'name': name!.toJson(),
        if (description != null) 'description': description,
        'child_organizations':
            List<dynamic>.from(child_organizations.map((x) => x.toJson())),
        'parent_organizations':
            List<dynamic>.from(parent_organizations.map((x) => x.toJson())),
        'child_organizations_for_dashboard': List<dynamic>.from(
            child_organizations_for_dashboard.map((x) => x.toJson())),
        'people': List<dynamic>.from(people.map((x) => x.toJson())),
        'organization_metadata':
            List<dynamic>.from(organization_metadata.map((x) => x.toJson()))
        // if (employees != null) 'employees': List<dynamic>.from(employees!.map((x) => x.toJson())),
      };
}

Future<Organization> fetchOrganization(int id) async {
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
    Organization organization =
        Organization.fromJson(json.decode(response.body));
    return organization;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<List<Person>> fetchOrganizationForAll(int id) async {
  final uri = Uri.parse(
          AppConfig.campusProfileBffApiUrl + '/student_list_by_parent_org_id')
      .replace(queryParameters: {
    'id': [id.toString()]
  });

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> studentList =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return studentList;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<List<Organization>> fetchOrganizationsByAvinyaType(
    int avinya_type) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/organizations_by_avinya_type/$avinya_type'),
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

Future<List<Organization>> fetchActiveOrganizationsByAvinyaType(
    int avinya_type) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/organizations_by_avinya_type_with_active_status/$avinya_type/1'),
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

class Alumni {
  int? id;
  String? status;
  int? person_count;
  String? company_name;
  String? job_title;
  String? linkedin_id;
  String? facebook_id;
  String? instagram_id;
  String? tiktok_id;
  String? updated_by;
  String? created;
  String? updated;

  Alumni(
      {this.id,
      this.status,
      this.person_count,
      this.company_name,
      this.job_title,
      this.linkedin_id,
      this.facebook_id,
      this.instagram_id,
      this.tiktok_id,
      this.updated_by,
      this.created,
      this.updated});

  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
        id: json['id'],
        status: json['status'],
        person_count: json['person_count'],
        company_name: json['company_name'],
        job_title: json['job_title'],
        linkedin_id: json['linkedin_id'],
        facebook_id: json['facebook_id'],
        instagram_id: json['instagram_id'],
        tiktok_id: json['tiktok_id'],
        updated_by: json['updated_by'],
        created: json['created'],
        updated: json['updated']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (status != null) 'status': status,
        if (person_count != null) 'person_count': person_count,
        if (company_name != null) 'company_name': company_name,
        if (job_title != null) 'job_title': job_title,
        if (linkedin_id != null) 'linkedin_id': linkedin_id,
        if (facebook_id != null) 'facebook_id': facebook_id,
        if (instagram_id != null) 'instagram_id': instagram_id,
        if (tiktok_id != null) 'tiktok_id': tiktok_id,
        if (updated_by != null) 'updated_by': updated_by,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated
      };
}

class AlumniPerson {
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
  String? digital_id;
  String? bank_account_name;
  int? avinya_phone;
  int? academy_org_id;
  String? created;
  String? updated;
  int? alumni_id;
  bool? is_graduated;
  int? document_id;
  List<WorkExperience>? alumni_work_experience;
  List<EducationQualifications>? alumni_education_qualifications;
  // EducationQualifications? alumni_education_qualifications;
  Alumni? alumni;

  // var alumni_work_experience;

  AlumniPerson(
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
      this.avinya_phone,
      this.academy_org_id,
      this.created,
      this.updated,
      this.alumni_id,
      required this.is_graduated,
      this.document_id,
      this.alumni_education_qualifications,
      this.alumni_work_experience,
      this.alumni});

  factory AlumniPerson.fromJson(Map<String, dynamic> json) {
    return AlumniPerson(
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
      bank_account_name: json['bank_account_name'],
      avinya_phone: json['avinya_phone'],
      academy_org_id: json['academy_org_id'],
      organization: Organization.fromJson(
          json['organization'] != null ? json['organization'] : {}),
      avinya_type: AvinyaType.fromJson(
          json['avinya_type'] != null ? json['avinya_type'] : {}),
      created: json['created'],
      updated: json['updated'],
      alumni_id: json['alumni_id'],

      // alumni_work_experience: json['alumni_work_experience']
      //     ?.map<WorkExperience>(
      //         (alumni_json) => WorkExperience.fromJson(alumni_json))
      //     ?.toList(),
      // alumni_education_qualifications: json['alumni_education_qualifications']
      //     ?.map<EducationQualifications>(
      //         (alumni_json) => EducationQualifications.fromJson(alumni_json))
      //     ?.toList(),
      alumni: Alumni.fromJson(json['alumni'] != null ? json['alumni'] : {}),

      alumni_work_experience: json['alumni_work_experience'] != null
          ? (json['alumni_work_experience'] as List)
              .map((item) => WorkExperience.fromJson(item))
              .toList()
          : [],

      alumni_education_qualifications:
          json['alumni_education_qualifications'] != null
              ? (json['alumni_education_qualifications'] as List)
                  .map((item) => EducationQualifications.fromJson(item))
                  .toList()
              : [],
      is_graduated: json['is_graduated'],
      document_id: json['document_id'],
    );
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
        if (organization_id != null) 'organization_id': organization_id,
        if (asgardeo_id != null) 'asgardeo_id': asgardeo_id,
        if (jwt_sub_id != null) 'jwt_sub_id': jwt_sub_id,
        if (jwt_email != null) 'jwt_email': jwt_email,
        if (email != null) 'email': email,
        if (permanent_address != null)
          'permanent_address': permanent_address!.toJson(),
        if (mailing_address != null)
          'mailing_address': mailing_address!.toJson(),
        if (street_address != null) 'street_address': street_address,
        if (bank_account_number != null)
          'bank_account_number': bank_account_number,
        if (bank_name != null) 'bank_name': bank_name,
        if (bank_branch != null) 'bank_name': bank_branch,
        if (digital_id != null) 'digital_id': digital_id,
        if (bank_account_name != null) 'bank_account_name': bank_account_name,
        if (avinya_phone != null) 'avinya_phone': avinya_phone,
        if (academy_org_id != null) 'academy_org_id': academy_org_id,
        if (organization != null) 'organization': organization!.toJson(),
        if (avinya_type != null) 'avinya_type': avinya_type!.toJson(),
        if (alumni != null) 'alumni': alumni!.toJson(),
        if (created != null) 'created': created,
        if (alumni_id != null) 'alumni_id': alumni_id,
        // if (alumni_work_experience != null)
        //   'parent_activities': alumni_work_experience
        //       ?.map((activity) => activity.toJson())
        //       .toList(),
        // 'alumni_work_experience':
        //     alumni_work_experience?.map((e) => e.toJson()).toList(),
        // 'alumni_education_qualifications':
        //     alumni_education_qualifications?.map((e) => e.toJson()).toList(),
        if (is_graduated != null) 'is_graduated': is_graduated,
        if (document_id != null) 'document_id': document_id,
        if (updated != null) 'updated': updated,
      };
}

class WorkExperience {
  int? person_id;
  int? id;
  String? companyName;
  String? jobTitle;
  bool? currentlyWorking;
  String? startDate;
  String? endDate;

  WorkExperience({
    this.person_id,
    this.id,
    this.companyName,
    this.jobTitle,
    this.currentlyWorking,
    this.startDate,
    this.endDate,
  });

  // Updated fromJson method to handle a dynamic list.
  factory WorkExperience.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return WorkExperience(
        person_id: json['person_id'],
        id: json['id'],
        companyName: json['company_name'],
        jobTitle: json['job_title'],
        currentlyWorking: json['currently_working'] == 1,
        startDate: json['start_date'] != null ? json['start_date'] : null,
        endDate: json['end_date'] != null ? json['end_date'] : null,
      );
    } else {
      // Handle the case where json is not a map but a list or other type.
      throw ArgumentError('Invalid format for WorkExperience: $json');
    }
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (companyName != null) 'company_name': companyName,
        if (jobTitle != null) 'job_title': jobTitle,
        if (currentlyWorking != null)
          'currently_working': currentlyWorking! ? 1 : 0,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };
}

class EducationQualifications {
  int? person_id;
  int? id;
  String? universityName;
  String? courseName;
  bool? isCurrentlyStudying;
  String? startDate;
  String? endDate;

  EducationQualifications({
    this.person_id,
    this.id,
    this.universityName,
    this.courseName,
    this.isCurrentlyStudying,
    this.startDate,
    this.endDate,
  });

  factory EducationQualifications.fromJson(Map<String, dynamic> json) {
    return EducationQualifications(
      id: json['id'],
      person_id: json['person_id'],
      universityName: json['university_name'],
      courseName: json['course_name'],
      isCurrentlyStudying: json['is_currently_studying'] == 1,
      startDate: json['start_date'] != null ? json['start_date'] : null,
      endDate: json['end_date'] != null ? json['end_date'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (person_id != null) 'person_id': person_id,
        if (universityName != null) 'university_name': universityName,
        if (courseName != null) 'course_name': courseName,
        if (isCurrentlyStudying != null)
          'is_currently_studying': isCurrentlyStudying! ? 1 : 0,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
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
  String? digital_id;
  String? bank_account_name;
  int? avinya_phone;
  int? academy_org_id;
  String? created;
  String? updated;
  int? alumni_id;
  bool? is_graduated;
  int? document_id;
  List<WorkExperience>? alumni_work_experience;
  List<EducationQualifications>? alumni_education_qualifications;
  var parent_students = <Person>[];
  Alumni? alumni;

  Person({
    this.id,
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
    this.avinya_phone,
    this.academy_org_id,
    this.created,
    this.updated,
    this.alumni_id,
    required this.is_graduated,
    this.document_id,
    this.alumni_education_qualifications,
    this.alumni_work_experience,
    this.alumni,
    this.parent_students = const [],
  });

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
        bank_account_name: json['bank_account_name'],
        avinya_phone: json['avinya_phone'],
        academy_org_id: json['academy_org_id'],
        organization: Organization.fromJson(
            json['organization'] != null ? json['organization'] : {}),
        avinya_type: AvinyaType.fromJson(
            json['avinya_type'] != null ? json['avinya_type'] : {}),
        created: json['created'],
        updated: json['updated'],
        parent_students: json['parent_students'] != null
            ? json['parent_students']
                .map<Person>((eval_json) => Person.fromJson(eval_json))
                .toList()
            : [],
        is_graduated: json['is_graduated'],
        document_id: json['document_id'],
        alumni_id: json['alumni_id'],
        alumni_work_experience: json['alumni_work_experience']
            ?.map<WorkExperience>(
                (alumni_json) => WorkExperience.fromJson(alumni_json))
            ?.toList(),
        alumni_education_qualifications: json['alumni_education_qualifications']
            ?.map<EducationQualifications>(
                (alumni_json) => EducationQualifications.fromJson(alumni_json))
            ?.toList(),
        alumni: Alumni.fromJson(json['alumni'] != null ? json['alumni'] : {}));
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
        if (organization_id != null) 'organization_id': organization_id,
        if (asgardeo_id != null) 'asgardeo_id': asgardeo_id,
        if (jwt_sub_id != null) 'jwt_sub_id': jwt_sub_id,
        if (jwt_email != null) 'jwt_email': jwt_email,
        if (email != null) 'email': email,
        if (permanent_address != null)
          'permanent_address': permanent_address!.toJson(),
        if (mailing_address != null)
          'mailing_address': mailing_address!.toJson(),
        if (street_address != null) 'street_address': street_address,
        if (bank_account_number != null)
          'bank_account_number': bank_account_number,
        if (bank_name != null) 'bank_name': bank_name,
        if (bank_branch != null) 'bank_name': bank_branch,
        if (digital_id != null) 'digital_id': digital_id,
        if (bank_account_name != null) 'bank_account_name': bank_account_name,
        if (avinya_phone != null) 'avinya_phone': avinya_phone,
        if (academy_org_id != null) 'academy_org_id': academy_org_id,
        if (organization != null) 'organization': organization!.toJson(),
        if (avinya_type != null) 'avinya_type': avinya_type!.toJson(),
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        'parent_students': [parent_students],
        if (alumni_id != null) 'alumni_id': alumni_id,
        if (alumni_work_experience != null)
          'parent_activities': alumni_work_experience
              ?.map((activity) => activity.toJson())
              .toList(),
        'alumni_work_experience':
            alumni_work_experience?.map((e) => e.toJson()).toList(),
        'alumni_education_qualifications':
            alumni_education_qualifications?.map((e) => e.toJson()).toList(),
        if (is_graduated != null) 'is_graduated': is_graduated,
        if (document_id != null) 'document_id': document_id,
        if (alumni != null) 'alumni': alumni!.toJson(),
      };

  map(DataRow Function(dynamic evaluation) param0) {}
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
//-------- start of profile functions ---------------

Future<Person> fetchPerson(String digital_id) async {
  final uri = Uri.parse(AppConfig.campusProfileBffApiUrl + '/person')
      .replace(queryParameters: {'digital_id': digital_id});

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<List<Person>> fetchAlumniPersonList(int? parent_organization_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAlumniBffApiUrl +
        '/alumni_persons/$parent_organization_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> persons =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return persons;
  } else {
    throw Exception('Failed to get alumni persons Data');
  }
}

Future<List<Person>> fetchStudentListByParentOrg(
    int parent_organization_id) async {
  final uri = Uri.parse(
          AppConfig.campusProfileBffApiUrl + '/student_list_by_parent_org_id')
      .replace(queryParameters: {
    'parent_organization_id': [parent_organization_id.toString()]
  });

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> studentList =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return studentList;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<List<Person>> fetchStudentListByBatchId(int batch_id) async {
  final uri =
      Uri.parse(AppConfig.campusProfileBffApiUrl + '/student_list_by_batch_id')
          .replace(queryParameters: {
    'batch_id': [batch_id.toString()]
  });

  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> studentList =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return studentList;
  } else {
    throw Exception('Failed to load Person');
  }
}

//-------- end of profile functions ---------------

//-------- start of alumni functions ---------------

Future<AlumniPerson> fetchAlumniPerson(int id) async {
  final uri =
      Uri.parse('${AppConfig.campusAlumniBffApiUrl}/alumni_person_by_id/$id');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    AlumniPerson person = AlumniPerson.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<AlumniPerson> createAlumniPerson(
    AlumniPerson person, selectedDistrictId) async {
  print("Sending data: ${jsonEncode(person.toJson())}");
  final response = await http.post(
    Uri.parse(AppConfig.campusAlumniBffApiUrl + '/create_alumni'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    AlumniPerson AlumniUserPerson =
        AlumniPerson.fromJson(json.decode(response.body));
    AlumniPerson person2 = AlumniPerson(
      id: null,
      full_name: AlumniUserPerson.full_name,
      email: AlumniUserPerson.email,
      phone: AlumniUserPerson.phone,
      mailing_address: Address(
        id: AlumniUserPerson.mailing_address?.id,
        name_en: AlumniUserPerson.mailing_address?.name_en,
        street_address: AlumniUserPerson.mailing_address?.street_address,
        phone: AlumniUserPerson.mailing_address?.phone,
        city: City(
          id: AlumniUserPerson.mailing_address?.city?.id,
          name: Name(
            name_en: AlumniUserPerson.mailing_address?.city?.name?.name_en,
          ),
          district:
              District(id: selectedDistrictId, name: Name(name_en: "Kalutara")),
          latitude: AlumniUserPerson.mailing_address?.city?.latitude ?? 0.0,
          longitude: AlumniUserPerson.mailing_address?.city?.longitude ?? 0.0,
        ),
      ),
      alumni: Alumni(
        id: AlumniUserPerson.alumni?.id,
        status: AlumniUserPerson.alumni?.status,
        company_name: AlumniUserPerson.alumni?.company_name,
        job_title: AlumniUserPerson.alumni?.job_title,
        linkedin_id: AlumniUserPerson.alumni?.linkedin_id,
        facebook_id: AlumniUserPerson.alumni?.facebook_id,
        instagram_id: AlumniUserPerson.alumni?.instagram_id,
        tiktok_id: AlumniUserPerson.alumni?.tiktok_id,
        updated_by: AlumniUserPerson.digital_id,
      ),
      is_graduated: null,
    );
    return person2;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<AlumniPerson> updateAlumniPerson(
    AlumniPerson person, id, selectedDistrictId) async {
  print("Sending data: ${jsonEncode(person.toJson())}");
  final response = await http.put(
    Uri.parse(AppConfig.campusAlumniBffApiUrl + '/update_alumni'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    AlumniPerson AlumniUserPerson =
        AlumniPerson.fromJson(json.decode(response.body));
    AlumniPerson person2 = AlumniPerson(
      id: id,
      full_name: AlumniUserPerson.full_name,
      email: AlumniUserPerson.email,
      phone: AlumniUserPerson.phone,
      mailing_address: Address(
        id: AlumniUserPerson.mailing_address?.id,
        name_en: AlumniUserPerson.mailing_address?.name_en,
        street_address: AlumniUserPerson.mailing_address?.street_address,
        phone: AlumniUserPerson.mailing_address?.phone,
        city: City(
          id: AlumniUserPerson.mailing_address?.city?.id,
          name: Name(
            name_en: AlumniUserPerson.mailing_address?.city?.name?.name_en,
          ),
          district:
              District(id: selectedDistrictId, name: Name(name_en: "Kalutara")),
          latitude: AlumniUserPerson.mailing_address?.city?.latitude ?? 0.0,
          longitude: AlumniUserPerson.mailing_address?.city?.longitude ?? 0.0,
        ),
      ),
      alumni: Alumni(
        id: AlumniUserPerson.alumni?.id,
        status: AlumniUserPerson.alumni?.status,
        company_name: AlumniUserPerson.alumni?.company_name,
        job_title: AlumniUserPerson.alumni?.job_title,
        linkedin_id: AlumniUserPerson.alumni?.linkedin_id,
        facebook_id: AlumniUserPerson.alumni?.facebook_id,
        instagram_id: AlumniUserPerson.alumni?.instagram_id,
        tiktok_id: AlumniUserPerson.alumni?.tiktok_id,
        updated_by: AlumniUserPerson.digital_id,
      ),
      is_graduated: null,
    );
    return person2;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<EducationQualifications> createAlumniEduQualification(
    EducationQualifications edu) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAlumniBffApiUrl +
        '/create_alumni_education_qualification'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(edu.toJson()),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    EducationQualifications edu =
        EducationQualifications.fromJson(json.decode(response.body));
    return edu;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updateAlumniEduQualification(
    EducationQualifications edu) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAlumniBffApiUrl +
        '/update_alumni_education_qualification'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(edu.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deleteAlumniEduQualification(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAlumniBffApiUrl +
        '/alumni_education_qualification_by_id/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete.');
  }
}

Future<http.Response> deleteAlumniWorkQualification(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(
        AppConfig.campusAlumniBffApiUrl + '/alumni_work_experience_by_id/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete.');
  }
}

Future<WorkExperience> createAlumniWorkQualification(
    WorkExperience work) async {
  final response = await http.post(
    Uri.parse(
        AppConfig.campusAlumniBffApiUrl + '/create_alumni_work_experience'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(work.toJson()),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    WorkExperience work = WorkExperience.fromJson(json.decode(response.body));
    return work;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updateAlumniWorkQualification(WorkExperience work) async {
  final response = await http.put(
    Uri.parse(
        AppConfig.campusAlumniBffApiUrl + '/update_alumni_work_experience'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(work.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

//-------- end of alumni functions ---------------

//-------- start of attendance functions ---------------

Future<List<Person>> fetchPersons() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> persons =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return persons;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> createPerson(Person person) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updatePerson(Person person) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deletePerson(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/student_applicant/$id'),
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

//-------- end of attendance functions ---------------

//-------- start of pcti_notes_admin functions ---------------

Future<List<Person>> fetchStudentApplicants() async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> persons =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return persons;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<http.Response> deleteStudentApplicant(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/student_applicant/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Person.');
  }
}

Future<Person> createStudentApplicant(Person person) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    log("${response.body} Status code =${response.statusCode}");
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updateStudentApplicant(Person person) async {
  final response = await http.put(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<Person> fetchPersonFromPctiNoteAdmin(int person_id) async {
  final response = await http.get(
    Uri.parse('${AppConfig.campusPctiNotesBffApiUrl}/person?id=$person_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> fetchStudentApplicant(String jwt_sub_id) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusPctiNotesBffApiUrl}/student_applicant/$jwt_sub_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ${AppConfig.campusBffApiKey}',
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

//-------- end of pcti_notes_admin functions ---------------

//-------- start of asset functions ---------------

Future<List<Person>> fetchPersonsFromAsset() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> persons =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return persons;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> fetchPersonFromAsset(String jwt_sub_id) async {
  final response = await http.get(
    Uri.parse(
        AppConfig.campusAssetsBffApiUrl + '/student_applicant/$jwt_sub_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> createPersonFromAsset(Person person) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updatePersonFromAsset(Person person) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAssetsBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deletePersonFromAsset(String id) async {
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

//-------- end of asset functions -----------------

//-------- start of pcti_feedback functions ---------------

Future<Person> fetchPersonFromPctiFeedback(int person_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl + '/person?id=$person_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  // if (response.statusCode == 200) {
  //   var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
  //   List<Person> persons =
  //       await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
  //   return persons;
  // } else {
  //   throw Exception('Failed to load Person');
  // }
  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<List<Person>> fetchStudentApplicantsFromPctiFeedback() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Person> persons =
        await resultsJson.map<Person>((json) => Person.fromJson(json)).toList();
    return persons;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> fetchStudentApplicantFromPctiFeedback(String jwt_sub_id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl +
        '/student_applicant/$jwt_sub_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    throw Exception('Failed to load Person');
  }
}

Future<Person> createStudentApplicantFromPctiFeedback(Person person) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    // var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    Person person = Person.fromJson(json.decode(response.body));
    return person;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updateStudentApplicantFromPctiFeedback(
    Person person) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl + '/student_applicant'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
    },
    body: jsonEncode(person.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Person.');
  }
}

Future<http.Response> deleteStudentApplicantFromPctiFeedback(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusPctiFeedbackBffApiUrl + '/student_applicant/$id'),
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

//-------- end of pcti_feedback functions ---------------
