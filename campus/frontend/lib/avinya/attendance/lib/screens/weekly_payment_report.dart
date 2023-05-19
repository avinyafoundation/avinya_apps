// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/widgets/weekly_payment_report.dart';

class WeeklyPaymentReportScreen extends StatefulWidget {
  const WeeklyPaymentReportScreen({super.key});

  @override
  _WeeklyPaymentReportScreenState createState() =>
      _WeeklyPaymentReportScreenState();
}

class _WeeklyPaymentReportScreenState extends State<WeeklyPaymentReportScreen>
    with SingleTickerProviderStateMixin {
  // final _RestorableDessertSelections _dessertSelections = _RestorableDessertSelections();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Weekly Student Payment Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: WeeklyPaymentReport(
            title: 'Weekly Student Payment',
          ),
        ),
      ),
    );
  }
}
