import 'dart:developer';
import 'dart:typed_data';
import 'package:gallery/avinya/alumni/lib/data/alumni.dart';
import 'package:gallery/widgets/success_message.dart';
import 'package:gallery/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class MainOrganization {
  int? id;
  String? description;
  String? notes;
  Address? address;
  AvinyaType? avinya_type;
  Name? name;
  String? phone;
  List<ParentOrganization>? parent_organizations;

  MainOrganization(
      {this.id,
      this.description,
      this.notes,
      this.address,
      this.avinya_type,
      this.name,
      this.phone,
      this.parent_organizations});

  factory MainOrganization.fromJson(Map<String, dynamic> json) {
    return MainOrganization(
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

class Organization {
  int? id;
  Name? name;
  String? description;
  var child_organizations = <Organization>[];
  var parent_organizations = <Organization>[];
  var people = <Person>[];

  Organization({
    this.id,
    this.name,
    this.description,
    this.child_organizations = const [],
    this.parent_organizations = const [],
    this.people = const [],
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
      people: json['people'] != null
          ? List<Person>.from(json['people'].map((x) => Person.fromJson(x)))
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
        'people': List<dynamic>.from(people.map((x) => x.toJson())),
        // if (employees != null) 'employees': List<dynamic>.from(employees!.map((x) => x.toJson())),
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
  MainOrganization? organization;
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
  Alumni? alumni;
  List<WorkExperience>? alumni_work_experience;
  List<EducationQualifications>? alumni_education_qualifications;
  bool? is_graduated;

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
      this.documents_id,
      this.is_graduated,
      this.alumni_education_qualifications,
      this.alumni_work_experience,
      this.alumni});

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
        organization: MainOrganization.fromJson(
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
        alumni_work_experience: json['alumni_work_experience']
            ?.map<WorkExperience>(
                (alumni_json) => WorkExperience.fromJson(alumni_json))
            ?.toList(),
        alumni_education_qualifications: json['alumni_education_qualifications']
            ?.map<EducationQualifications>(
                (alumni_json) => EducationQualifications.fromJson(alumni_json))
            ?.toList(),
        current_job: json['current_job'],
        documents_id: json['documents_id'],
        is_graduated: json['is_graduated'],
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
        if (organization != null) 'organization_id': organization!.id,
        if (organization_id != null) 'organization_id': organization_id,
        if (parent_organization_id != null)
          'parent_organization_id': parent_organization_id,
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
        if (alumni != null) 'alumni': alumni!.toJson(),
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
