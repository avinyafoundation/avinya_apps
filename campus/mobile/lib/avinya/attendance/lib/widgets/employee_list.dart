import 'package:flutter/material.dart';

import '../data.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key, this.onTap});
  final ValueChanged<Employee>? onTap;

  @override
  // ignore: no_logic_in_create_state
  EmployeeListState createState() => EmployeeListState(onTap);
}

class EmployeeListState extends State<EmployeeList> {
  late Future<List<Employee>> futureEmployees;
  final ValueChanged<Employee>? onTap;

  EmployeeListState(this.onTap);

  @override
  void initState() {
    super.initState();
    futureEmployees = fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Employee>>(
      future: futureEmployees,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusAttendanceSystemInstance.setEmployees(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                snapshot.data![index].first_name,
              ),
              subtitle: Text(
                snapshot.data![index].last_name,
              ),
              onTap: onTap != null ? () => onTap!(snapshot.data![index]) : null,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
