// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/widgets/daily_attendance_report.dart';
// import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:intl/intl.dart';

class DailyAttendanceReportScreen extends StatefulWidget {
  const DailyAttendanceReportScreen({super.key});

  @override
  _DailyAttendanceReportScreenState createState() =>
      _DailyAttendanceReportScreenState();
}

class _DailyAttendanceReportScreenState
    extends State<DailyAttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  // final _RestorableDessertSelections _dessertSelections = _RestorableDessertSelections();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = GalleryLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Daily Attendance Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: DailyAttendanceReport(
            title: 'Daily Attendnace',
          ),
        ),
      ),
    );
  }
}
