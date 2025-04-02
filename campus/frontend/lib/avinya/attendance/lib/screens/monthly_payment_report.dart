// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:attendance/widgets/excel_export.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_payment_report_excel_export.dart';
import 'package:gallery/data/person.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_payment_report.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';

class MonthlyPaymentReportScreen extends StatefulWidget {
  const MonthlyPaymentReportScreen({super.key});

  @override
  _MonthlyPaymentReportScreenState createState() =>
      _MonthlyPaymentReportScreenState();
}

class _MonthlyPaymentReportScreenState extends State<MonthlyPaymentReportScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Monthly Student Payment Report",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              MonthlyPaymentReport(
                title: 'Weekly Student Payment',
              )
            ],
          ),
        ),
      ),
    );
  }
}
