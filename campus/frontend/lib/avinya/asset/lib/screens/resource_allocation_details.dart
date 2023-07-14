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
    }else if(resourceAllocation != null){
    return Scaffold(
      appBar: AppBar(
        title: Text(resourceAllocation!.asset!.model!.toString()),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            title: Text('Name'),
            subtitle: Text(resourceAllocation!.asset!.name?.isNotEmpty == true ?  resourceAllocation!.asset!.name!.toString() : 'N/A'),
          ),
          ListTile(
            title: Text('Manufacturer'),
            subtitle: Text(resourceAllocation!.asset!.manufacturer?.isNotEmpty == true ? resourceAllocation!.asset!.manufacturer!.toString(): 'N/A'),
          ),
          ListTile(
            title: Text('Model'),
            subtitle: Text(resourceAllocation!.asset!.model?.isNotEmpty == true ? resourceAllocation!.asset!.model!.toString() : 'N/A'),
          ),
          ListTile(
            title: Text('Serial Number'),
            subtitle: Text(resourceAllocation!.asset!.serialNumber?.isNotEmpty == true ? resourceAllocation!.asset!.serialNumber!.toString() : 'N/A'),
          ),
          ListTile(
            title: Text('Registration Number'),
            subtitle:
                Text(resourceAllocation!.asset!.registrationNumber?.isNotEmpty == true ? resourceAllocation!.asset!.registrationNumber!.toString() : 'N/A'),
          ),
          ListTile(
            title: Text('Description'),
            subtitle: Text( resourceAllocation!.asset!.description?.isNotEmpty == true ? resourceAllocation!.asset!.description!.toString() : 'N/A'),
          ),
          // ListTile(
          //   title: Text('Avinya Type'),
          //   subtitle:
          //       Text(resourceAllocation!.asset!.avinya_type!.id!.toString()),
          // ),
        ],
      ),
     );
    }else{
      return CircularProgressIndicator();
    }
  }
}
