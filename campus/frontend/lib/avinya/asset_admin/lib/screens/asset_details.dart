import 'package:flutter/material.dart';

import '../data.dart';

class AssetDetailsScreen extends StatelessWidget {
  final Asset? asset;

  const AssetDetailsScreen({
    super.key,
    this.asset,
    //required ResourceAllocation resourceAllocation,
  });

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Asset found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(asset!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              asset!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.manufacturer!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.model!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.serialNumber!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.registrationNumber!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              asset!.avinya_type_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
