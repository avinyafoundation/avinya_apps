import 'dart:developer';

import 'package:gallery/data/person.dart';

import '../auth.dart';

final campusAppsPortalInstance = CampusAppsPortal()
  ..setJWTSub('jwt-sub-id123')
  ..setDigitalId('digital-id123')
  ..setUserPerson(
      Person(id: 2, jwt_sub_id: 'jwt-sub-id123', preferred_name: 'Nimal'));

final campusAppsPortalPersonMetaDataInstance = CampusAppsPortalPersonMetaData()
  ..setGroups(['educator', 'teacher'])
  ..setScopes('address email');

class CampusAppsPortal {
  List<Person>? persons = [];
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person userPerson = Person();
  String? user_jwt_sub;
  String? user_jwt_email;
  String? user_digital_id;
  CampusAppsPortalAuth? auth;
  bool signedIn = false;
  bool isStudent = false;
  bool isParent = false;
  bool isSecurity = false;
  bool isJanitor = false;
  bool isTeacher = false;
  bool isFoundation = false;

  final activityIds = {
    'school-day': 1,
    'arrival': 2,
    'breakfast-break': 3,
    'homeroom': 4,
    'pcti': 5,
    'class-tutorial': 6,
    'class-presentation': 7,
    'tea-break': 8,
    'free-time': 9,
    'lunch-break': 10,
    'work': 11,
    'departure': 12,
    'after-school': 13,
  };

  final todaysActivityInstanceIds = {
    'school-day': [],
    'arrival': [],
    'breakfast-break': [],
    'homeroom': [],
    'pcti': [],
    'class-tutorial': [],
    'class-presentation': [],
    'tea-break': [],
    'free-time': [],
    'lunch-break': [],
    'work': [],
    'departure': [],
  };

  void setSignedIn(bool value) {
    signedIn = value;
  }

  bool getSignedIn() {
    return signedIn;
  }

  void setAuth(CampusAppsPortalAuth auth) {
    this.auth = auth;
  }

  CampusAppsPortalAuth? getAuth() {
    return this.auth;
  }

  Future<bool> getAuthSignedIn() async {
    final signedIn = await auth!.getSignedIn();
    return signedIn;
  }

  void setVacancyId(int id) {
    vacancyId = id;
  }

  int getVacancyId() {
    return vacancyId;
  }

  void setUserPerson(Person person) {
    userPerson = person;
  }

  Person getUserPerson() {
    return userPerson;
  }

  // void setApplication(Application? application) {
  //   this.application = application!;
  // }

  // Application getApplication() {
  //   return this.application;
  // }

  void setJWTSub(String? jwt_sub) {
    user_jwt_sub = jwt_sub;
  }

  String? getJWTSub() {
    return user_jwt_sub;
  }

  void setDigitalId(String? jwt_sub) {
    user_digital_id = jwt_sub;
  }

  String? getDigitalId() {
    return user_digital_id;
  }

  void setJWTEmail(String? jwt_email) {
    user_jwt_email = jwt_email;
  }

  String? getJWTEmail() {
    return user_jwt_email;
  }

  // void addEmployee(Employee employee) {
  //   allEmployees.add(employee);
  // }
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

  void fetchPersonForUser() async {
    // check if user is in Avinya database person table as a student
    try {
      Person person = campusAppsPortalInstance.getUserPerson();
      if (person.digital_id == null ||
          person.digital_id != this.user_digital_id!) {
        person = await fetchPerson(this.user_digital_id!);
        this.userPerson = person;
        log('Campus Apps Portal - fetchPersonForUser: ' +
            person.toJson().toString());
        print('Campus Apps Portal - fetchPersonForUser: ' +
            person.toJson().toString());
        campusAppsPortalInstance.setUserPerson(person);

        if (person.digital_id != null) {
          this.isStudent = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student');
          this.isParent = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Parent');
          this.isSecurity = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Security');
          this.isJanitor = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Janitor');
          this.isTeacher = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Educator');
          this.isFoundation = campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Foundation');
        }
      }
    } catch (e) {
      print(
          'Campus Apps Portal fetchPersonForUser :: Error fetching person for user');
      print(e);
    }
  }

  void addPerson(Person person) {
    persons!.add(person);
  }

  int getActivityId(String activityName) {
    return activityIds[activityName]!;
  }
}

class CampusAppsPortalPersonMetaData {
  List<dynamic> _groups = [];
  String? _scopes;

  void setGroups(List<dynamic> groups) {
    _groups = groups;
  }

  List<dynamic> getGroups() {
    return this._groups;
  }

  void setScopes(String scopes) {
    _scopes = scopes;
  }

  List<String>? getScopes() {
    if (_scopes == null) {
      return null;
    }
    return _scopes!.split(' ');
  }
}
