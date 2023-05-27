import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:attendance/widgets/person_attendance_report.dart';

class PersonAttendanceReportScreen extends StatefulWidget {
  const PersonAttendanceReportScreen({super.key});

  @override
  State<PersonAttendanceReportScreen> createState() => _PersonAttendanceReportScreenState();
}

class _PersonAttendanceReportScreenState extends State<PersonAttendanceReportScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Payment Report"),
      ),
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              children: [
                Container(child: PersonAttendanceMarkerReport()),
              ],
            )
          ), 
      ),

    );
  }

}