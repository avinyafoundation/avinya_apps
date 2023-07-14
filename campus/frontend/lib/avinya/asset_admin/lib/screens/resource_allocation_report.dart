import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/resource_allocation_report.dart';





class ResourceAllocationReportScreen extends StatefulWidget {
  const ResourceAllocationReportScreen({super.key});

  @override
  State<ResourceAllocationReportScreen> createState() => _ResourceAllocationReportScreenState();
}

class _ResourceAllocationReportScreenState extends State<ResourceAllocationReportScreen> {


 

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Resource Allocation Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ResourceAllocationReport(),
        ),
      ),
    );
  }



}