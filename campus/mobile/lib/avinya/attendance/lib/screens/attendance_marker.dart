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
          title: const Text('Attendance Marker'),
          backgroundColor: Colors.lightBlue,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                AttendanceMarker(),
                const SizedBox(height: 20),
                const Text('Person Attendance Report'),
                const SizedBox(height: 5),
                const SizedBox(
                    width: 500,
                    height: 500,
                    child: PersonAttendanceMarkerReport()),
              ],
            ),
          ),
        ),
      );
}
