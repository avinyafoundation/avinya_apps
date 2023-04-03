import 'package:flutter/material.dart';

import '../data.dart';

class ResourceAllocationDetailsScreen extends StatelessWidget {
  final ResourceAllocation? resourceAllocation;

  const ResourceAllocationDetailsScreen({
    super.key,
    this.resourceAllocation,
  });

  @override
  Widget build(BuildContext context) {
    if (resourceAllocation == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Asset found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(resourceAllocation!.asset!.model!.toString()),
      ),
      body: Center(
        child: Row(
          children: [
            Text(
              resourceAllocation!.asset!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              resourceAllocation!.asset!.manufacturer!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              resourceAllocation!.asset!.model!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              resourceAllocation!.asset!.serialNumber!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              resourceAllocation!.asset!.registrationNumber!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              resourceAllocation!.asset!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            // Text(
            //   resourceAllocation!.asset!.avinya_type!.id!.toString(),
            //   style: Theme.of(context).textTheme.headline4,
            // ),
          ],
        ),
      ),
    );
  }
}
