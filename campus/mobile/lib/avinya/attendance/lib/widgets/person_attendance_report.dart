import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:mobile/data/campus_apps_portal.dart';
import '../routing.dart';


  List<DateTime> getPastDaysIncludingToday(int numberOfDays){
    List<DateTime> daysList = [];
    DateTime date = DateTime.now();
    for(int i =0;i < numberOfDays;i++){
      daysList.insert(i,date);
      date = date.subtract(Duration(days: 1));
    }
    return daysList;
  }

class PersonAttendanceMarkerReport extends StatefulWidget {
  const PersonAttendanceMarkerReport({super.key});

  @override
  State<PersonAttendanceMarkerReport> createState() =>
      _PersonAttendanceMarkerReportState();
}

class _PersonAttendanceMarkerReportState
    extends State<PersonAttendanceMarkerReport> {
  List<ActivityAttendance> _personAttendanceReport = [];
  var result_limit = 20;
  List<DataColumn> _daysColumns = [];
  List<String?> stringDateTimeList = [];
  List<DateTime> daysList = [];
  bool isAttendanceMarkerPathTemplate = false;

  @override
  void initState() {
    super.initState();
    _generateDaysColumns();
  }


  List<DataColumn> _buildDataColumns(bool isAttendanceMarkerPathTemplate) {
    List<DataColumn> ColumnNames = [];

    ColumnNames.add(DataColumn(
        label: Text('Date',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Attendance',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    if (!isAttendanceMarkerPathTemplate) {
      ColumnNames.add(DataColumn(
          label: Text('Daily Payment',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Phone Payment',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    }

    return ColumnNames;
  }

  void _generateDaysColumns() {
    daysList = getPastDaysIncludingToday(10);
    // Generate the DataColumn list
    for (DateTime date in daysList) {
      _daysColumns.add(DataColumn(
        label: Text('${date.toString().split(" ")[0]}'),
      ));
    }
  }

  Future<List<ActivityAttendance>>
      refreshPersonActivityAttendanceReport() async {
    var activityInstance;
    if (campusAppsPortalInstance.isStudent) {
      activityInstance = campusAppsPortalInstance.activityIds['homeroom']!;
    } else {
      activityInstance = campusAppsPortalInstance.activityIds['school-day']!;
    }
    _personAttendanceReport = await getPersonActivityAttendanceReport(
        campusAppsPortalInstance.getUserPerson().id!,
        activityInstance!,
        result_limit);
    return _personAttendanceReport;
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = RouteStateScope.of(context).route;

    if (currentRoute.pathTemplate.startsWith('/attendance_marker')) {
      isAttendanceMarkerPathTemplate = true;
    } else {
      isAttendanceMarkerPathTemplate = false;
    }

    return FutureBuilder<List<ActivityAttendance>>(
      future: refreshPersonActivityAttendanceReport(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          stringDateTimeList = daysList.map((datetime) {
            return datetime.toString().split(" ")[0];
          }).toList();
          return SingleChildScrollView(
            child: PaginatedDataTable(
              columns: _buildDataColumns(isAttendanceMarkerPathTemplate),
              source: _PersonAttendanceMarkerReportDataSource(snapshot.data,
                  stringDateTimeList, isAttendanceMarkerPathTemplate),
              rowsPerPage: 7,
              columnSpacing: 30,
              horizontalMargin: 15,
            ),
          );
        } // } else if (snapshot.hasError) {
        //   return Text("${snapshot.error}");
        // }
        return Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SpinKitCircle(
                          color: (Colors.deepPurpleAccent), // Customize the color of the indicator
                          size: 70, // Customize the size of the indicator
                        ),
            );
      },
    );
  }
}

class _PersonAttendanceMarkerReportDataSource extends DataTableSource {
  _PersonAttendanceMarkerReportDataSource(
      this._data, this.numberOfColumns, this.isAttendanceMarkerPathTemplate) {
    numberOfColumns.sort((a, b) => b!.compareTo(a!));
  }

  List<ActivityAttendance> _data;
  List<String?> numberOfColumns = [];
  bool isAttendanceMarkerPathTemplate;

  @override
  DataRow? getRow(int index) {
    List<DataCell> cells = [];

    final attendance = numberOfColumns[index];

    int i = 0;
    double dailyPayment;
    double phonePayment;

    for (; i < _data.length; i++) {
      if (_data[i].sign_in_time != null &&
          attendance == _data[i].sign_in_time!.split(" ")[0]) {
        cells.add(DataCell(Text(attendance! +
            "-" +
            "(" +
            DateFormat.EEEE().format(DateTime.parse(attendance)) +
            ")")));
        cells.add(DataCell(Text("Present")));

        if (!isAttendanceMarkerPathTemplate) {
          dailyPayment = 100.00;
          phonePayment = 100.00;
          cells.add(DataCell(Text("Rs.$dailyPayment")));
          cells.add(DataCell(Text("Rs.$phonePayment")));
        }
        break;
      }
    }

    if (i == _data.length) {
      if (cells.isEmpty) {
        cells.add(DataCell(Text(attendance! +
            "-" +
            "(" +
            DateFormat.EEEE().format(DateTime.parse(attendance)) +
            ")")));
        cells
            .add(DataCell(Container(child: Text("Absent"), color: Colors.red)));

        if (!isAttendanceMarkerPathTemplate) {
          dailyPayment = 00.00;
          phonePayment = 00.00;
          cells.add(DataCell(Text("Rs.$dailyPayment")));
          cells.add(DataCell(Text("Rs.$phonePayment")));
        }
      }
    }
    return DataRow(cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => numberOfColumns.length;

  @override
  int get selectedRowCount => 0;
}
