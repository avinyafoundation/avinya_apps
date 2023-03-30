import 'dart:developer';

import 'package:gallery/avinya/asset/lib/data.dart';

//import 'package:ShoolManagementSystem/src/data.dart';

final campusConfigSystemInstance = CampusConfigSystem()
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
      isNew: false);

class CampusConfigSystem {
  final List<Book> allBooks = [];
  final List<Author> allAuthors = [];
  List<Employee>? allEmployees = [];
  List<AddressType>? addressTypes = [];
  List<Person>? persons = [];
  //late Future<List<Vacancy>>? vacancies;
  List<AvinyaType>? avinyaTypes = [];
  List<Asset>? assets = [];
  List<Supplier>? suppliers = [];
  List<Consumable>? consumables = [];
  List<Supply>? supplies = [];
  List<Inventory>? inventories = [];
  List<Organization>? organizations = [];
  List<ResourceAllocation>? resourceAllocations = [];
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person studentPerson = Person();
  Application application = Application();
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

  void setApplication(Application? application) {
    this.application = application!;
  }

  Application getApplication() {
    return this.application;
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

  void setEmployees(List<Employee>? employees) {
    allEmployees = employees;
  }

  void setAddressTypes(List<AddressType>? addressTyples) {
    this.addressTypes = addressTyples;
  }

  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  // void setVacancies(Future<List<Vacancy>> vacancies) {
  //   this.vacancies = vacancies;
  // }

  void setAvinyaTypes(List<AvinyaType>? avinyaTypes) {
    this.avinyaTypes = avinyaTypes;
  }

  void setAssets(List<Asset>? assets) {
    this.assets = assets;
  }

  void setSuppliers(List<Supplier>? suppliers) {
    this.suppliers = suppliers;
  }

  void setConsumables(List<Consumable>? consumables) {
    this.consumables = consumables;
  }

  void setSupplies(List<Supply>? supplies) {
    this.supplies = supplies;
  }

  void setInventories(List<Inventory>? inventories) {
    this.inventories = inventories;
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
