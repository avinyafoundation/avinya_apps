import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../widgets/consumable_monthly_report.dart';

class ConsumableMonthlyReportScreen extends StatefulWidget {
  const ConsumableMonthlyReportScreen({super.key});

  @override
  State<ConsumableMonthlyReportScreen> createState() => _ConsumableMonthlyReportScreenState();
}

class _ConsumableMonthlyReportScreenState extends State<ConsumableMonthlyReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        automaticallyImplyLeading: false,
        title: Text("Consumable Monthly Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ConsumableMonthlyReport(),
        ),
      ),
    );
  }
}