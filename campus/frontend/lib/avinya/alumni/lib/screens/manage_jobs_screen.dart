import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/widgets/manage_jobs_widget.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Job Board",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ManageJobsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}