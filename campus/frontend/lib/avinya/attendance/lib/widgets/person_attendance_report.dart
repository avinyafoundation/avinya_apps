import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';
import 'package:intl/intl.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../routing.dart';

List<DateTime> getWeekdaysFromDate(DateTime fromDate, int numberOfWeekdays) {
  List<DateTime> weekdaysList = [];
  DateTime current = fromDate;
  while (weekdaysList.length < numberOfWeekdays) {
    current = current.add(const Duration(days: 1));
    if (current.weekday >= 1 && current.weekday <= 5) {
      weekdaysList.add(current);
    }
  }
  return weekdaysList;
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
  final int resultLimit = 20;
  final DateTime twentyEightDaysAgoDate =
      DateTime.now().subtract(const Duration(days: 28));

  List<DateTime> weekdaysList = [];
  List<String> stringDateTimeList = [];
  bool isAttendanceMarkerPathTemplate = false;

  @override
  void initState() {
    super.initState();
    weekdaysList = getWeekdaysFromDate(twentyEightDaysAgoDate, 20);
    stringDateTimeList =
        weekdaysList.map((d) => d.toString().split(" ")[0]).toList();
  }

  List<DataColumn> _buildDataColumns(bool isTemplate) {
    return [
      const DataColumn(
        label: Expanded(
          child: Center(
            child: Text('Date',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50))),
          ),
        ),
      ),
      const DataColumn(
        label: Expanded(
          child: Center(
            child: Text('Attendance',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50))),
          ),
        ),
      ),
      if (!isTemplate) ...[
        const DataColumn(
          label: Expanded(
            child: Center(
              child: Text('Daily Payment',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50))),
            ),
          ),
        ),
        const DataColumn(
          label: Expanded(
            child: Center(
              child: Text('Phone Payment',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50))),
            ),
          ),
        ),
      ]
    ];
  }

  Future<List<ActivityAttendance>>
      refreshPersonActivityAttendanceReport() async {
    int? activityId;
    if (campusAppsPortalInstance.isStudent) {
      activityId = campusAppsPortalInstance.activityIds['homeroom'];
    } else {
      activityId = campusAppsPortalInstance.activityIds['school-day'];
    }

    if (activityId == null) return [];

    _personAttendanceReport = await getPersonActivityAttendanceReport(
        campusAppsPortalInstance.getUserPerson().id!, activityId, resultLimit);
    return _personAttendanceReport;
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = RouteStateScope.of(context).route;
    isAttendanceMarkerPathTemplate =
        currentRoute.pathTemplate.startsWith('/attendance_marker');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data Table Content
              FutureBuilder<List<ActivityAttendance>>(
                future: refreshPersonActivityAttendanceReport(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(60.0),
                            child: SpinKitCircle(
                                color: Color(0xFF1BB6E8), size: 50)));
                  }

                  if (snapshot.hasData) {
                    // Force the table to take up the full width of the parent container
                    return LayoutBuilder(builder: (context, constraints) {
                      return ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFF8F9FA)),
                              headingTextStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50)),
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth:
                                    constraints.maxWidth), // Force full width
                            child: PaginatedDataTable(
                              showCheckboxColumn: false,
                              columns: _buildDataColumns(
                                  isAttendanceMarkerPathTemplate),
                              source: _PersonAttendanceMarkerReportDataSource(
                                snapshot.data!,
                                stringDateTimeList,
                                isAttendanceMarkerPathTemplate,
                              ),
                              rowsPerPage: 20,
                              columnSpacing:
                                  40,
                              horizontalMargin: 24,
                              showFirstLastButtons: true,
                            ),
                          ),
                        ),
                      );
                    });
                  }
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text("No data available")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonAttendanceMarkerReportDataSource extends DataTableSource {
  final List<ActivityAttendance> _data;
  final List<String> dates;
  final bool isTemplate;

  _PersonAttendanceMarkerReportDataSource(
      this._data, this.dates, this.isTemplate) {
    dates.sort((a, b) => b.compareTo(a));
  }

  @override
  DataRow? getRow(int index) {
    if (index >= dates.length) return null;

    final String dateStr = dates[index];
    final DateTime dateObj = DateTime.parse(dateStr);

    final bool isPresent = _data.any((attendance) =>
        attendance.sign_in_time != null &&
        attendance.sign_in_time!.split(" ")[0] == dateStr);

    List<DataCell> cells = [];

    cells.add(DataCell(Center(
        child: Text("$dateStr (${DateFormat.EEEE().format(dateObj)})",
            style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50))))));

    cells.add(DataCell(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color:
                  isPresent ? const Color(0xFFE8F8F5) : const Color(0xFFFDEDED),
              borderRadius: BorderRadius.circular(12)),
          child: Text(isPresent ? "Present" : "Absent",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPresent
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C))),
        ),
      ),
    ));

    if (!isTemplate) {
      double daily = isPresent ? 100.0 : 0.0;
      double phone = isPresent ? 100.0 : 0.0;
      cells.add(DataCell(Center(
          child: Text("Rs.${daily.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)))));
      cells.add(DataCell(Center(
          child: Text("Rs.${phone.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)))));
    }

    return DataRow(
      cells: cells,
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered))
          return Colors.blue.withOpacity(0.05);
        if (index.isEven) return Colors.grey.withOpacity(0.05);
        return null;
      }),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => dates.length;
  @override
  int get selectedRowCount => 0;
}
