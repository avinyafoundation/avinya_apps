import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/app_config.dart';

class Employee {
  final int employee_id;
  final String first_name;
  final String last_name;
  final String email;
  final String phone;
  //time:Date hire_date;
  final int manager_id;
  final String job_title;

  const Employee({
    required this.employee_id,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.phone,
    //required this.hire_date,
    required this.manager_id,
    required this.job_title,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employee_id: json['employee_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      //hire_date: json['hire_date'],
      manager_id: json['manager_id'],
      job_title: json['job_title'],
    );
  }
}

Future<List<Employee>> fetchEmployees() async {
  final response =
      await http.get(Uri.parse(AppConfig.apiUrl + '/sms/hrm/employees'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Employee> emplist = await resultsJson
        .map<Employee>((json) => Employee.fromJson(json))
        .toList();
    return emplist;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
