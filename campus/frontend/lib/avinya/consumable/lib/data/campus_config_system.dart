import 'dart:developer';

import 'package:consumable/data.dart';

//import 'package:ShoolManagementSystem/src/data.dart';

// final campusConfigSystemInstance = CampusConfigSystem()

class CampusConfigSystem {
  List<Person>? persons = [];
  List<Consumable>? consumables = [];
  List<Organization>? organizations = [];
  List<ResourceAllocation>? resourceAllocations = [];
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person studentPerson = Person();
  String? user_jwt_sub;
  String? user_jwt_email;

  void setVacancyId(int id) {
    vacancyId = id;
  }

  int getVacancyId() {
    return vacancyId;
  }

  void setStudentPerson(Person person) {
    studentPerson = person;
  }

  Person getStudentPerson() {
    return studentPerson;
  }

  void setPrecondisionsSubmitted(bool value) {
    precondisionsSubmitted = value;
  }

  void setApplicationSubmitted(bool value) {
    applicationSubmitted = value;
  }

  bool getPrecondisionsSubmitted() {
    return precondisionsSubmitted;
  }

  bool getApplicationSubmitted() {
    return applicationSubmitted;
  }

  String getSchoolName() {
    return schoolName;
  }

  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  void setConsumables(List<Consumable>? consumables) {
    this.consumables = consumables;
  }

  void setOrganizations(List<Organization>? organizations) {
    this.organizations = organizations;
  }

  void setResourceAllocations(List<ResourceAllocation>? resourceAllocations) {
    this.resourceAllocations = resourceAllocations;
  }

  void addPerson(Person person) {
    persons!.add(person);
  }
}
