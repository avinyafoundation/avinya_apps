import 'package:mobile/data.dart';

final campusAttendanceSystemInstance = CampusAttendanceSystem()
  ..setUserPerson(Person(
      id: 2,
      jwt_sub_id: 'jwt-sub-id123',
      preferred_name: 'Nimal',
      is_graduated: false))
  ..setCheckinActivityInstance(ActivityInstance(
    id: 1,
  ))
  ..setCheckoutActivityInstance(ActivityInstance(id: 11));

class CampusAttendanceSystem {
  List<AddressType>? addressTypes = [];
  List<Person>? persons = [];
  List<AvinyaType>? avinyaTypes = [];
  Activity? activity;
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person userPerson = Person(is_graduated: false);
  String? user_jwt_sub;
  String? user_jwt_email;
  String? user_digital_id;
  ActivityInstance checkinActivityInstance = ActivityInstance();
  ActivityInstance checkoutActivityInstance = ActivityInstance();

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

  void setAddressTypes(List<AddressType>? addressTypes) {
    this.addressTypes = addressTypes;
  }

  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  void setAvinyaTypes(List<AvinyaType>? avinyaTypes) {
    this.avinyaTypes = avinyaTypes;
  }

  void setActivity(Activity? activity) {
    this.activity = activity;
  }

  void setCheckinActivityInstance(ActivityInstance? activityInstance) {
    checkinActivityInstance = activityInstance!;
  }

  void setCheckoutActivityInstance(ActivityInstance? activityInstance) {
    checkoutActivityInstance = activityInstance!;
  }

  Future<ActivityInstance> getCheckinActivityInstance(int? activityId) async {
    List<ActivityInstance> activityInstances =
        await fetchActivityInstance(activityId!);
    return activityInstances[0];
  }

  Future<ActivityInstance> getCheckoutActivityInstance(int? activityId) async {
    List<ActivityInstance> activityInstances =
        await fetchActivityInstance(activityId!);
    return activityInstances[0];
  }

  void addPerson(Person person) {
    persons!.add(person);
  }
}
