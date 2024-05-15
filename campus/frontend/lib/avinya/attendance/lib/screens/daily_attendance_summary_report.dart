import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/widgets/attendance_summary_report.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:intl/intl.dart';
import 'package:gallery/data/campus_apps_portal.dart';

import 'package:gallery/avinya/attendance/lib/widgets/attendance_summary_excel_report_export.dart';

class DailyAttendanceSummaryReportScreen extends StatefulWidget{

  const DailyAttendanceSummaryReportScreen({super.key});

  @override
  State<DailyAttendanceSummaryReportScreen> createState() {
    return _DailyAttendanceSummaryReportScreenState();
  }
}

class _DailyAttendanceSummaryReportScreenState  extends State<DailyAttendanceSummaryReportScreen>{
  
  List<ActivityAttendance> _fetchedDailyAttendanceSummaryData = [];
  List<ActivityAttendance> _fetchedExcelReportData = [];
  bool _isFetching = true;

  List<String?> columnNames = [];

  late String formattedStartDate;
  late String formattedEndDate;

  late DataTableSource _data;

  //calendar specific variables
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Daily Attendance Summary Report",style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
      ),
      body: SingleChildScrollView(
          child: Container(            
           child: Column(
             children: [
               AttendanceSummaryReport(),
             ],
           ),     
          ), 
      ),
    );
  }
}