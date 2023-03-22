import 'package:flutter/material.dart';

import '../data.dart';

class VacancyDetailsScreen extends StatelessWidget {
  final Vacancy? vacancy;

  const VacancyDetailsScreen({
    super.key,
    this.vacancy,
  });

  @override
  Widget build(BuildContext context) {
    if (vacancy == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Vacancy found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(vacancy!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              vacancy!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.organization_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.avinya_type_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.evaluation_cycle_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.head_count!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.avinya_type!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              vacancy!.evaluation_criteria.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
