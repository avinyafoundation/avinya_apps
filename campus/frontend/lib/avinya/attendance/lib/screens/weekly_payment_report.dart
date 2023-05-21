// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:attendance/widgets/excel_export.dart';
import 'package:gallery/data/person.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/avinya/attendance/lib/widgets/weekly_payment_report.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';

class WeeklyPaymentReportScreen extends StatefulWidget {
  const WeeklyPaymentReportScreen({super.key});

  @override
  _WeeklyPaymentReportScreenState createState() =>
      _WeeklyPaymentReportScreenState();
}

class _WeeklyPaymentReportScreenState extends State<WeeklyPaymentReportScreen>
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
    }
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      _fetchedExcelReportData =
          await getClassActivityAttendanceReportByParentOrg(
              parentOrgId,
              activityId,
              DateFormat('yyyy-MM-dd').format(_rangeStart),
              DateFormat('yyyy-MM-dd').format(_rangeEnd));
    }
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
    });
  }

  @override
  void initState() {
    super.initState();
    var today = DateTime.now();
    if (campusAppsPortalInstance.isTeacher) {
      activityId = campusAppsPortalInstance.activityIds['homeroom']!;
      selectWeek(today, activityId);
    } else if (campusAppsPortalInstance.isSecurity)
      activityId = campusAppsPortalInstance.activityIds['arrival']!;
    selectWeek(today, activityId);
  }

  void updateExcelState() {
    ExcelExport(
      fetchedAttendance: _fetchedExcelReportData,
      columnNames: columnNames,
      fetchedStudentList: _fetchedStudentList,
      updateExcelState: updateExcelState,
      isFetching: isFetching,
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
        title: Text("Weekly Student Payment Report"),
      ),
      body: isFetching
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    WeeklyPaymentReport(
                      title: 'Weekly Student Payment',
                      updateDateRangeForExcel: updateDateRange,
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: ExcelExport(
        fetchedAttendance: _fetchedExcelReportData,
        columnNames: columnNames,
        fetchedStudentList: _fetchedStudentList,
        updateExcelState: updateExcelState,
        isFetching: isFetching,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
