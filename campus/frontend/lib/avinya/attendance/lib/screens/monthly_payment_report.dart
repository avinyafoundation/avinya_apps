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
  List<ActivityAttendance> _fetchedExcelReportData = [];
  List<Person> _fetchedStudentList = [];
  List<String?> columnNames = [];
  var activityId = 0;
  bool isFetching = true;

  //calendar specific variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late String formattedStartDate;
  late String formattedEndDate;
  late int _totalSchoolDaysInMonth = 0;
  late String _monthFullName = "";
  late double _dailyAmount = 0.0;

  List<String?> classes = [];

  late int _organization_id;
  late int _totalDaysInMonth;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  // void selectedYearAndMonth(int year, int month) async {
  //   _organization_id =
  //       campusAppsPortalInstance.getUserPerson().organization!.id!;
  //   setState(() {
  //     _year = year;
  //     _month = month;
  //   });
  //  // await _fetchLeaveDates(_year, _month);
  // }

  // void selectMonth(DateTime today, activityId) async {
  //   // Calculate the start of the week (excluding weekends) based on the selected day
  //   // Calculate the first date of the month
  //   DateTime firstDateOfMonth = DateTime(today.year, today.month, 1);

  //   // Calculate the last date of the month
  //   DateTime lastDateOfMonth =
  //       DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1));

  //   int? parentOrgId =
  //       campusAppsPortalInstance.getUserPerson().organization!.id;

  //   if (parentOrgId != null) {
  //     setState(() {
  //       this.isFetching = true;
  //     });
  //     try {
  //       _fetchedExcelReportData =
  //           await getClassActivityAttendanceReportByParentOrg(
  //               parentOrgId,
  //               activityId,
  //               DateFormat('yyyy-MM-dd').format(firstDateOfMonth),
  //               DateFormat('yyyy-MM-dd').format(lastDateOfMonth));
  //       _fetchedStudentList = await fetchStudentList(parentOrgId);

  //       setState(() {
  //         this._fetchedExcelReportData = _fetchedExcelReportData;
  //         this._fetchedStudentList = _fetchedStudentList;
  //         this.isFetching = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         this.isFetching = false;
  //       });
  //     }
  //   }
  // }

  // void updateDateRange(_rangeStart, _rangeEnd) async {
  //   int? parentOrgId =
  //       campusAppsPortalInstance.getUserPerson().organization!.id;
  //   if (parentOrgId != null) {
  //     setState(() {
  //       this.isFetching = true;
  //     });
  //     try {
  //       _fetchedExcelReportData =
  //           await getClassActivityAttendanceReportByParentOrg(
  //               parentOrgId,
  //               activityId,
  //               DateFormat('yyyy-MM-dd').format(_rangeStart),
  //               DateFormat('yyyy-MM-dd').format(_rangeEnd));
  //       setState(() {
  //         final startDate = _rangeStart ?? _selectedDay;
  //         final endDate = _rangeEnd ?? _selectedDay;
  //         final formatter = DateFormat('MMM d, yyyy');
  //         final formattedStartDate = formatter.format(startDate!);
  //         final formattedEndDate = formatter.format(endDate!);
  //         this.formattedStartDate = formattedStartDate;
  //         this.formattedEndDate = formattedEndDate;
  //         this._fetchedStudentList = _fetchedStudentList;
  //         this.isFetching = false;
  //         this._fetchedExcelReportData = _fetchedExcelReportData;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         this.isFetching = false;
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //var today = DateTime.now();
   // selectedYearAndMonth(_year, _month);
   // activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    //selectMonth(today, activityId);
    // var organizations = campusAppsPortalInstance
    //     .getUserPerson()
    //     .organization!
    //     .child_organizations
    //     .where((org) => org.child_organizations.isNotEmpty);
    // if (organizations.length > 0)
    //   classes = organizations
    //       .expand((Organization org) =>
    //           (org.child_organizations.map((e) => e.description)))
    //       .toList();
  }

  // void updateExcelState() {
  //   MonthlyPaymentReportExcelExport(
  //     classes: classes,
  //     fetchedAttendance: _fetchedExcelReportData,
  //     columnNames: columnNames,
  //     fetchedStudentList: _fetchedStudentList,
  //     updateExcelState: updateExcelState,
  //     isFetching: isFetching,
  //     totalSchoolDaysInMonth: _totalSchoolDaysInMonth,
  //     dailyAmount: _dailyAmount,
  //     year: _year,
  //     month: _monthFullName,
  //   );
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // Future<void> _fetchLeaveDates(int year, int month) async {
  //   try {
  //     // Fetch leave dates and payment details for the month
  //     List<LeaveDate> fetchedDates = await getLeaveDatesForMonth(
  //       year,
  //       month,
  //       _organization_id,
  //       44
  //     );

  //     _totalDaysInMonth = DateTime(_year, _month + 1, 0).day;
  //     _totalSchoolDaysInMonth = _totalDaysInMonth - fetchedDates.length;
  //     _monthFullName = DateFormat.MMMM().format(DateTime(0, _month));

  //     setState(() {
  //       if (fetchedDates.isNotEmpty) {
  //         _dailyAmount = fetchedDates.first.dailyAmount;
  //         // MonthlyPayment = DailyPayment * fetchedDates.length;
  //       } else {
  //         _dailyAmount = 0.00;
  //       }
  //     });
  //   } catch (e) {
  //     print("Error fetching leave dates: $e");
  //   }
  // }

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
               // updateDateRangeForExcel: updateDateRange,
               // onYearMonthSelected: selectedYearAndMonth,
               // classes: classes,
              )
            ],
          ),
        ),
      ),
      //floatingActionButton: this.isFetching
      //     ? null
      //     : MonthlyPaymentReportExcelExport(
      //         classes: classes,
      //         fetchedAttendance: _fetchedExcelReportData,
      //         columnNames: columnNames,
      //         fetchedStudentList: _fetchedStudentList,
      //         updateExcelState: updateExcelState,
      //         isFetching: isFetching,
      //         totalSchoolDaysInMonth: _totalSchoolDaysInMonth,
      //         dailyAmount: _dailyAmount,
      //         year: _year,
      //         month: _monthFullName,
      //       ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
