import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/consumable_weekly_report.dart';

class ConsumableWeeklyReportScreen extends StatefulWidget {
  const ConsumableWeeklyReportScreen({super.key});

  @override
  State<ConsumableWeeklyReportScreen> createState() =>
      _ConsumableWeeklyReportScreenState();
}

class _ConsumableWeeklyReportScreenState
    extends State<ConsumableWeeklyReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        automaticallyImplyLeading: false,
        title: Text("Consumable Weekly Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ConsumableWeeklyReport(),
        ),
      ),
    );
  }
}
