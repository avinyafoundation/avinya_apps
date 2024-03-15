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


  void selectDateRange(DateTime today) async {
    // Update the variables to select the week
    final formatter = DateFormat('MMM d, yyyy');
    formattedStartDate = formatter.format(today);
    formattedEndDate = formatter.format(today);
    setState(() {
      _isFetching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    var today = DateTime.now();
    selectDateRange(today);
  }

  void updateExcelState() {
    AttendanceSummaryExcelReportExport(
      fetchedDailyAttendanceSummaryData: _fetchedExcelReportData,
      columnNames: columnNames,
      updateExcelState: updateExcelState,
      isFetching: _isFetching,
      formattedStartDate: formattedStartDate,
      formattedEndDate: formattedEndDate,
    );
  }


  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
   
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });

      _fetchedExcelReportData = await getDailyAttendanceSummaryReport(
          parentOrgId,
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));


      try {
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedExcelReportData = _fetchedExcelReportData;
          refreshState();
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  void refreshState() async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
     int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;

     _fetchedExcelReportData = await getDailyAttendanceSummaryReport(
          parentOrgId!,
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
   
    
    setState(() {
      this._isFetching = false;
      _data = MyData(_fetchedDailyAttendanceSummaryData,updateSelected);
    });
  }

  List<DataColumn> _buildDataColumns() {

    List<DataColumn> ColumnNames = [];

      ColumnNames.add(DataColumn(
          label: Text('Date',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Daily Count',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Daily Attendance Percentage',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Late Count',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Late Attendance Percentage',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Total Count',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));        

    return ColumnNames;
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
               AttendanceSummaryReport(
                updateDateRangeForExcel: updateDateRange,
               ),
             ],
           ),     
          ), 
      ),
      floatingActionButton: this._isFetching
          ? null
          :  AttendanceSummaryExcelReportExport(
                fetchedDailyAttendanceSummaryData: _fetchedExcelReportData,
                columnNames: columnNames,
                updateExcelState: updateExcelState,
                isFetching: _isFetching,
                formattedStartDate: formattedStartDate,
                formattedEndDate: formattedEndDate,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}