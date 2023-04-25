import 'package:flutter/material.dart';

import '../data.dart';

class PersonDetailsScreen extends StatelessWidget {
  final Person? person;

  const PersonDetailsScreen({
    super.key,
    this.person,
  });

  @override
  Widget build(BuildContext context) {
    if (person == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Person found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(person!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              person!.record_type!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.preferred_name!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.full_name!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.notes!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.date_of_birth!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.sex!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.avinya_type_id!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.passport_no!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.permanent_address_id!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.mailing_address_id!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.nic_no!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.id_no!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.phone!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.organization_id!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.asgardeo_id!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              person!.email!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
