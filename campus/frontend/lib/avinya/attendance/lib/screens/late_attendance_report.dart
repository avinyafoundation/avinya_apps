// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/widgets/late_attendance_report.dart';
import 'package:gallery/data/campus_apps_portal.dart';

class LateAttendanceReportScreen extends StatefulWidget {
  const LateAttendanceReportScreen({super.key});

  @override
  _LateAttendanceReportScreenState createState() =>
      _LateAttendanceReportScreenState();
}

class _LateAttendanceReportScreenState extends State<LateAttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  List<String?> columnNames = [];
  var activityId = 0;

  @override
  void initState() {
    super.initState();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Daily Late Attendance Report",style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [LateAttendanceReport(title: 'Late Attendance Report')],
          ),
        ),
      ),
    );
  }
}
