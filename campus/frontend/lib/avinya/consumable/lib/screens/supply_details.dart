import 'package:flutter/material.dart';

import '../data.dart';

class SupplyDetailsScreen extends StatelessWidget {
  final Supply? supply;

  const SupplyDetailsScreen({
    super.key,
    this.supply,
  });

  @override
  Widget build(BuildContext context) {
    if (supply == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Supply found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(supply!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              supply!.asset_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.consumable_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.supplier_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.person_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.order_date!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.delivery_date!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.order_id!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supply!.order_amount!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
