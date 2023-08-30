


import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:attendance/widgets/duty_attendance_marker.dart';

class DutyAttendanceMarkerScreen extends StatefulWidget {
  const DutyAttendanceMarkerScreen({super.key});

  @override
  State<DutyAttendanceMarkerScreen> createState() => _DutyAttendanceMarkerScreenState();
}

class _DutyAttendanceMarkerScreenState extends State<DutyAttendanceMarkerScreen> {
  @override
 Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Duty Attendance Marker"),
      ),
      body: SingleChildScrollView(
          child: Container(            
           child: DutyAttendanceMarker(),     
          ), 
      ),

    );
  }
}