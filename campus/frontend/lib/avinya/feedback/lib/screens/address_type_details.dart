import 'package:flutter/material.dart';

import '../data.dart';

class AddressTypeDetailsScreen extends StatelessWidget {
  final AddressType? addressType;

  const AddressTypeDetailsScreen({
    super.key,
    this.addressType,
  });

  @override
  Widget build(BuildContext context) {
    if (addressType == null) {
      return const Scaffold(
        body: Center(
          child: Text('No AddressType found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(addressType!.id!.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              addressType!.name!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              addressType!.description!.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
