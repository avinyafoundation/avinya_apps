import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/widgets/alumni_admin.dart';
import 'package:gallery/avinya/alumni/lib/widgets/alumni_dashboard.dart';

class AlumniAdminScreen extends StatefulWidget {
  const AlumniAdminScreen({super.key});

  @override
  State<AlumniAdminScreen> createState() => _AlumniAdminScreenState();
}

class _AlumniAdminScreenState extends State<AlumniAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Alumni Managment",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              AlumniAdmin(),
            ],
          ),
        ),
      ),
    );
  }
}
