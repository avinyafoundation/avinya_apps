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

  List<String?> classes=[];

  void selectWeek(DateTime today, activityId) async {
    // Calculate the start of the week (excluding weekends) based on the selected day
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    while (startOfWeek.weekday > DateTime.friday) {
      startOfWeek = startOfWeek.subtract(Duration(days: 1));
    }

    // Calculate the end of the week (excluding weekends) based on the start of the week
    DateTime endOfWeek = startOfWeek.add(Duration(days: 4));

    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;

    if (parentOrgId != null) {
      setState(() {
        this.isFetching = true;
      });
      try {
        _fetchedExcelReportData =
            await getClassActivityAttendanceReportByParentOrg(
                parentOrgId,
                activityId,
                DateFormat('yyyy-MM-dd').format(startOfWeek),
                DateFormat('yyyy-MM-dd').format(endOfWeek));
        _fetchedStudentList = await fetchStudentList(parentOrgId);

        setState(() {
          this._fetchedExcelReportData = _fetchedExcelReportData;
          this._fetchedStudentList = _fetchedStudentList;
          this.isFetching = false;
        });
      } catch (e) {
        setState(() {
          this.isFetching = false;
        });
      }
    }
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      setState(() {
        this.isFetching = true;
      });
      try {
        _fetchedExcelReportData =
            await getClassActivityAttendanceReportByParentOrg(
                parentOrgId,
                activityId,
                DateFormat('yyyy-MM-dd').format(_rangeStart),
                DateFormat('yyyy-MM-dd').format(_rangeEnd));
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedStudentList = _fetchedStudentList;
          this.isFetching = false;
          this._fetchedExcelReportData = _fetchedExcelReportData;
        });
      } catch (e) {
        setState(() {
          this.isFetching = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var today = DateTime.now();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    selectWeek(today, activityId);
    var organizations = campusAppsPortalInstance
        .getUserPerson()
        .organization!
        .child_organizations
        .where((org) => org.child_organizations.isNotEmpty);
    if (organizations.length > 0)
     classes = organizations.expand((Organization org) =>
          (org.child_organizations.map((e) => e.description))).toList();
  }

  void updateExcelState() {
    MonthlyPaymentReportExcelExport(
      classes: classes,
      fetchedAttendance: _fetchedExcelReportData,
      columnNames: columnNames,
      fetchedStudentList: _fetchedStudentList,
      updateExcelState: updateExcelState,
      isFetching: isFetching,
      totalSchoolDaysInMonth: [1, 2, 3, 4, 5],
      dailyAmount: 333.47,
      numberOfDaysInMonth: 30,
      year: 2024,
      month: "January",
    );
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
        title: Text("Weekly Student Payment Report",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              MonthlyPaymentReport(
                title: 'Weekly Student Payment',
                updateDateRangeForExcel: updateDateRange,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: this.isFetching
          ? null
          : MonthlyPaymentReportExcelExport(
              classes:classes,
              fetchedAttendance: _fetchedExcelReportData,
              columnNames: columnNames,
              fetchedStudentList: _fetchedStudentList,
              updateExcelState: updateExcelState,
              isFetching: isFetching,
              totalSchoolDaysInMonth: [1, 2, 3, 4, 5],
              dailyAmount: 333.47,
              numberOfDaysInMonth: 30,
              year: 2024,
              month: "January",
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
