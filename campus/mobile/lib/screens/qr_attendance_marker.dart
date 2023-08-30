// AttendanceMarker screen class

import 'package:mobile/widgets/qr_attedance_marker.dart';
import 'package:flutter/material.dart';
import '../widgets/person_attendance_report.dart';

class QrAttendanceMarkerScreen extends StatefulWidget {
  const QrAttendanceMarkerScreen({Key? key}) : super(key: key);

  @override
  _QrAttendanceMarkerScreenState createState() =>
      _QrAttendanceMarkerScreenState();
}

class _QrAttendanceMarkerScreenState extends State<QrAttendanceMarkerScreen> {
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
          title: Text('Attendance Marker by QR Code'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                QrAttendanceMarker(),
                SizedBox(height: 20),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      );
}
