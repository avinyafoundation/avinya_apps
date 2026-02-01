import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/widgets/add_job_widget.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Alumni Job Portal",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              AddJobWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
