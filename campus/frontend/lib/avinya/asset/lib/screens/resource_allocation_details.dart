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
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            title: Text('Name'),
            subtitle: Text(resourceAllocation!.asset!.name!.toString()),
          ),
          ListTile(
            title: Text('Manufacturer'),
            subtitle: Text(resourceAllocation!.asset!.manufacturer!.toString()),
          ),
          ListTile(
            title: Text('Model'),
            subtitle: Text(resourceAllocation!.asset!.model!.toString()),
          ),
          ListTile(
            title: Text('Serial Number'),
            subtitle: Text(resourceAllocation!.asset!.serialNumber!.toString()),
          ),
          ListTile(
            title: Text('Registration Number'),
            subtitle:
                Text(resourceAllocation!.asset!.registrationNumber!.toString()),
          ),
          ListTile(
            title: Text('Description'),
            subtitle: Text(resourceAllocation!.asset!.description!.toString()),
          ),
          // ListTile(
          //   title: Text('Avinya Type'),
          //   subtitle:
          //       Text(resourceAllocation!.asset!.avinya_type!.id!.toString()),
          // ),
        ],
      ),
    );
  }
}
