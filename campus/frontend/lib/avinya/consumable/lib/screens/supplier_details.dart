import 'package:flutter/material.dart';

import '../data.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final Supplier? supplier;

  const SupplierDetailsScreen({
    super.key,
    this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    if (supplier == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Supplier found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(supplier!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              supplier!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supplier!.phone!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supplier!.email!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              supplier!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
