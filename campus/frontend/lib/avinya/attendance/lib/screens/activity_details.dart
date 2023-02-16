import 'package:flutter/material.dart';

import '../data.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final Activity? activity;

  const ActivityDetailsScreen({
    super.key,
    this.activity,
  });

  @override
  Widget build(BuildContext context) {
    if (activity == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Activity found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activity!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              activity!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              activity!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              activity!.notes!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
