import 'package:flutter/material.dart';

import '../data.dart';

class ConsumableDetailsScreen extends StatelessWidget {
  final Consumable? consumable;

  const ConsumableDetailsScreen({
    super.key,
    this.consumable,
  });

  @override
  Widget build(BuildContext context) {
    if (consumable == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Consumable found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(consumable!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              consumable!.name!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              consumable!.description!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              consumable!.avinyaTypeId!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              consumable!.manufacturer!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              consumable!.model!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              consumable!.serialNumber!.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
