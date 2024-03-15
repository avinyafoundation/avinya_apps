import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:attendance/data/activity_attendance.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/widgets/date_range_picker.dart';

import 'attendance_summary_excel_report_export.dart';

class AttendanceSummaryReport extends StatefulWidget{
 
  const AttendanceSummaryReport({super.key,required this.updateDateRangeForExcel});

  final Function(DateTime, DateTime) updateDateRangeForExcel;
 
 
  @override
  State<AttendanceSummaryReport> createState() {
    return _AttendanceSummaryReportState();
  }
}

class _AttendanceSummaryReportState extends State<AttendanceSummaryReport>{

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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedDailyAttendanceSummaryData,updateSelected);
    DateRangePicker(updateDateRange, formattedStartDate);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    widget.updateDateRangeForExcel(_rangeStart, _rangeEnd);
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
          _isFetching = false;
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
   
    _fetchedDailyAttendanceSummaryData = await getDailyAttendanceSummaryReport(
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


    AttendanceSummaryExcelReportExport(
      fetchedDailyAttendanceSummaryData: _fetchedExcelReportData,
      columnNames: columnNames,
      updateExcelState: updateExcelState,
      isFetching: _isFetching,
      formattedStartDate: formattedStartDate,
      formattedEndDate: formattedEndDate,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // create a text widget with some padding

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, top: 20, bottom: 10),
                            child: Row(children: <Widget>[
                              ElevatedButton(
                                style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all(
                                    TextStyle(fontSize: 20),
                                  ),
                                  elevation: MaterialStateProperty.all(20),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.greenAccent),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                ),
                                onPressed: _isFetching
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DateRangePicker(
                                                  updateDateRange,
                                                  formattedStartDate)),
                                        );
                                      },
                                child: Container(
                                  height: 50, // Adjust the height as needed
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isFetching)
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: SpinKitFadingCircle(
                                            color: Colors
                                                .black, // Customize the color of the indicator
                                            size:
                                                20, // Customize the size of the indicator
                                          ),
                                        ),
                                      if (!_isFetching)
                                        Icon(Icons.calendar_today,
                                            color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        '${this.formattedStartDate} - ${this.formattedEndDate}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                  ],
                ),
                Wrap(children: [
                  if (_isFetching)
                    Container(
                      margin: EdgeInsets.only(top: 180),
                      child: SpinKitCircle(
                        color: (Colors.deepPurpleAccent), // Customize the color of the indicator
                        size: 50, // Customize the size of the indicator
                      ),
                    )
                  else if (_fetchedDailyAttendanceSummaryData.length > 0)
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: _buildDataColumns(),
                        // header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 100,
                        horizontalMargin: 60,
                        rowsPerPage: 20,
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Text('No daily attendance summary data found'),
                    ),
                ]),
              ],
            ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource{
  MyData(this._fetchedDailyAttendanceSummaryData,this.updateSelected);

  
  final  List<ActivityAttendance> _fetchedDailyAttendanceSummaryData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {

    if(index == 0){
      List<DataCell> cells = List<DataCell>.filled(6,DataCell.empty);
      return DataRow(
        cells: cells,
      );
    }

    if(_fetchedDailyAttendanceSummaryData.length > 0 && index <= _fetchedDailyAttendanceSummaryData.length){
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);
      
      cells[0] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].sign_in_date!)));
      
      cells[1] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].present_count!.toString())));

      cells[2] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].present_attendance_percentage!.toString()+ " %")));

      cells[3] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].late_count!.toString())));

      cells[4] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].late_attendance_percentage!.toString()+ " %")));

      cells[5] = DataCell(
              Center(child: Text(_fetchedDailyAttendanceSummaryData[index - 1].total_count.toString())));

      return DataRow(cells: cells);
    }

    return null; // Return null for invalid index values
  }
  
  @override
  bool get isRowCountApproximate => false;
  
  @override
  int get rowCount {
    int count = 0;
    count = _fetchedDailyAttendanceSummaryData.length + 1;
    return count;
  }
  
  @override
  int get selectedRowCount => 0;


}