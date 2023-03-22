import 'dart:developer';

import 'package:feedbacks/data.dart';

final campusFeedbackSystemInstance = CampusFeedbackSystem()
  ..addBook(
      title: 'Left Hand of Darkness',
      authorName: 'Ursula K. Le Guin',
      isPopular: true,
      isNew: true)
  ..addBook(
      title: 'Too Like the Lightning',
      authorName: 'Ada Palmer',
      isPopular: false,
      isNew: true)
  ..addBook(
      title: 'Kindred',
      authorName: 'Octavia E. Butler',
      isPopular: true,
      isNew: false)
  ..addBook(
      title: 'The Lathe of Heaven',
      authorName: 'Ursula K. Le Guin',
      isPopular: false,
      isNew: false)
  ..setJWTSub('jwt-sub-id123')
  ..setDigitalId('digital-id123')
  ..setUserPerson(
      Person(id: 2, jwt_sub_id: 'jwt-sub-id123', preferred_name: 'Nimal'));

class CampusFeedbackSystem {
  final List<Book> allBooks = [];
  final List<Author> allAuthors = [];
  List<Employee>? allEmployees = [];
  List<AddressType>? addressTypes = [];
  List<Person>? persons = [];
  late Future<List<Vacancy>>? vacancies;
  List<AvinyaType>? avinyaTypes = [];
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person studentPerson = Person();
  Application application = Application();
  String? user_digital_id;
  String? user_jwt_sub;
  String? user_jwt_email;
  List<Evaluation>? pctiNotes = [];
  List<Evaluation>? evaluations = [];
  List<EvaluationCriteria>? evaluation_criterias = [];
  List<Activity>? activities = [];
  List<ActivityInstance>? activityInstances = [];

  void setDigitalId(String? jwt_sub) {
    user_digital_id = jwt_sub;
  }

  String? getDigitalId() {
    return user_digital_id;
  }

  void setVacancyId(int id) {
    vacancyId = id;
  }

  int getVacancyId() {
    return vacancyId;
  }

  void setUserPerson(Person person) {
    studentPerson = person;
  }

  void setStudentPerson(Person person) {
    studentPerson = person;
  }

  Person getStudentPerson() {
    return studentPerson;
  }

  void setApplication(Application? application) {
    this.application = application!;
  }

  Application getApplication() {
    return this.application;
  }

  void setJWTSub(String? jwt_sub) {
    user_jwt_sub = jwt_sub;
  }

  String? getJWTSub() {
    return user_jwt_sub;
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

  void setEmployees(List<Employee>? employees) {
    allEmployees = employees;
  }

  void setAddressTypes(List<AddressType>? addressTyples) {
    this.addressTypes = addressTyples;
  }

  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  void setVacancies(Future<List<Vacancy>> vacancies) {
    this.vacancies = vacancies;
  }

  void setAvinyaTypes(List<AvinyaType>? avinyaTypes) {
    this.avinyaTypes = avinyaTypes;
  }

  void setPctiNotes(List<Evaluation>? pctiNotes) {
    this.pctiNotes = pctiNotes;
  }

  void setActivities(List<Activity>? activities) {
    this.activities = activities;
  }

  void setActivityInstances(List<ActivityInstance>? activityInstances) {
    this.activityInstances = activityInstances;
  }

  void setEvaluations(List<Evaluation>? evaluations) {
    this.evaluations = evaluations;
  }

  void setEvaluationCriteria(List<EvaluationCriteria>? evaluation_criteria) {
    this.evaluation_criterias = evaluation_criteria;
  }

  Future<List<Vacancy>>? getVacancies() {
    return vacancies;
  }

  void fetchPersonForUser() async {
    // check if user is in Avinya database person table as a student
    try {
      Person person = campusFeedbackSystemInstance.getStudentPerson();
      if (person.jwt_sub_id == null ||
          person.jwt_sub_id != this.user_jwt_sub!) {
        person = await fetchStudentApplicant(this.user_jwt_sub!.toString());
        this.studentPerson = person;
        log('AdmissionSystem fetchPersonForUser: ' +
            person.toJson().toString());
      }
    } catch (e) {
      print(
          'AdmissionSystem fetchPersonForUser :: Error fetching person for user');
      print(e);
    }
  }

  void addPerson(Person person) {
    persons!.add(person);
  }

  void addBook({
    required String title,
    required String authorName,
    required bool isPopular,
    required bool isNew,
  }) {
    var author = allAuthors.firstWhere(
      (author) => author.name == authorName,
      orElse: () {
        final value = Author(allAuthors.length, authorName);
        allAuthors.add(value);
        return value;
      },
    );
    var book = Book(allBooks.length, title, isPopular, isNew, author);

    author.books.add(book);
    allBooks.add(book);
  }

  List<Book> get popularBooks => [
        ...allBooks.where((book) => book.isPopular),
      ];

  List<Book> get newBooks => [
        ...allBooks.where((book) => book.isNew),
      ];
}
