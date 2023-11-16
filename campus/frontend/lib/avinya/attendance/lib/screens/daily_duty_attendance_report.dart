import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/avinya/attendance/lib/widgets/daily_duty_attendance_report.dart';

class DailyDutyAttendanceReportScreen extends StatefulWidget {
  const DailyDutyAttendanceReportScreen({super.key});

  @override
  State<DailyDutyAttendanceReportScreen> createState() => _DailyDutyAttendanceReportScreenState();
}

class _DailyDutyAttendanceReportScreenState extends State<DailyDutyAttendanceReportScreen> {
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Daily Duty Attendance Report"),
      ),
      body: SingleChildScrollView(
        child: Container(
            child: DailyDutyAttendanceReport(),
        ),
      ),
    );
  }
}