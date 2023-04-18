import 'package:flutter/material.dart';

import '../data.dart';

class AvinyaTypeDetailsScreen extends StatelessWidget {
  final AvinyaType? avinyaType;

  const AvinyaTypeDetailsScreen({
    super.key,
    this.avinyaType,
  });

  @override
  Widget build(BuildContext context) {
    if (avinyaType == null) {
      return const Scaffold(
        body: Center(
          child: Text('No AvinyaType found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(avinyaType!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              avinyaType!.global_type!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.foundation_type!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.focus!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.active!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.level!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.name!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              avinyaType!.description!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
