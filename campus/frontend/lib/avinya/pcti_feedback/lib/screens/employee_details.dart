import 'package:flutter/material.dart';

import '../data.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final Employee? employee;

  const EmployeeDetailsScreen({
    super.key,
    this.employee,
  });

  @override
  Widget build(BuildContext context) {
    if (employee == null) {
      return const Scaffold(
        body: Center(
          child: Text('No employee found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(employee!.first_name),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              employee!.first_name,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              employee!.last_name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              employee!.email,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              employee!.phone,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              employee!.job_title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
