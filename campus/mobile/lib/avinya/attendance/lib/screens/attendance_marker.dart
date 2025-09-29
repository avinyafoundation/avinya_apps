// AttendanceMarker screen class

import 'package:attendance/widgets/attedance_marker.dart';
import 'package:flutter/material.dart';
import '../widgets/person_attendance_report.dart';

class AttendanceMarkerScreen extends StatefulWidget {
  const AttendanceMarkerScreen({Key? key}) : super(key: key);

  @override
  _AttendanceMarkerScreenState createState() => _AttendanceMarkerScreenState();
}

class _AttendanceMarkerScreenState extends State<AttendanceMarkerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Marker',style: TextStyle(color: Colors.black)),
          backgroundColor: Color.fromARGB(255, 236, 230, 253),
        ),
        body: SingleChildScrollView(
          child: Center(
            child:Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  FittedBox(child: AttendanceMarker()),
                  const SizedBox(height: 20),
                  const Text('Person Attendance Report'),
                  const SizedBox(height: 5),
                  const SizedBox(
                      width: 500,
                      height: 500,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 25.0),
                        child: PersonAttendanceMarkerReport(),
                      )),
                ],
              ),
            ),
          ),
        ),
      );
}
