import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:attendance/widgets/week_picker.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_calender.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_payment_report_excel_export.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:month_year_picker/month_year_picker.dart';

class MonthlyPaymentReport extends StatefulWidget {
  const MonthlyPaymentReport({
    Key? key,
    required this.title,
  }) : super(key: key);
  //final Function(DateTime, DateTime) updateDateRangeForExcel;
  // final Function(int, int) onYearMonthSelected;
  //final List<String?> classes;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MonthlyPaymentReport> createState() => _MonthlyPaymentReportState();
}

class _MonthlyPaymentReportState extends State<MonthlyPaymentReport> {
  List<ActivityAttendance> _fetchedAttendance = [];
  List<ActivityAttendance> _fetchedExcelReportData = [];
  List<Person> _fetchedStudentList = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;
  int organization_id = 0;
  double? MonthlyPayment = 0.00;
  // double? DailyPayment = 0.00;

  //calendar specific variables
  DateTime? _selectedDay;
  DateTime? _selected = DateTime.now();
  late DateTime firstDateOfMonth;
  late DateTime lastDateOfMonth;

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  late DataTableSource _data;
  List<String?> columnNames = [];
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;

  late String formattedStartDate;
  late String formattedEndDate;
  var today = DateTime.now();

  List<Organization> _batchData = [];
  Organization? _selectedOrganizationValue;
  CalendarMetadata? _calendarMetadata;
  List<Organization> _fetchedOrganizations = [];
  late Future<List<Organization>> _fetchBatchData;

  late int _totalDaysInMonth;
  late int _totalSchoolDaysInMonth = 0;
  late String _monthFullName = "";
  late double _dailyAmount = 0.0;

  List<String?> classes = [];

  void selectedYearAndMonth(int year, int month) async {
    setState(() {
      _year = year;
      _month = month;
    });
  }

  @override
  void initState() {
    super.initState();
    _year = _selected?.year ?? _year;
    _month = _selected?.month ?? _month;
    firstDateOfMonth = DateTime(today.year, today.month, 1);
    lastDateOfMonth =
        DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1));
    _fetchBatchData = _loadBatchData();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    // selectedYearAndMonth(_year, _month);
    organization_id =
        campusAppsPortalInstance.getUserPerson().organization!.id!;
  }

  Future<List<Organization>> _loadBatchData() async {
    _batchData = await fetchActiveOrganizationsByAvinyaType(86);
    _selectedOrganizationValue = _batchData.isNotEmpty ? _batchData.last : null;

    if (_selectedOrganizationValue != null) {
      int orgId = _selectedOrganizationValue!.id!;
      _fetchedOrganization = await fetchOrganization(orgId);
      _calendarMetadata =
          await fetchCalendarMetaDataByOrgId(organization_id, orgId);
      MonthlyPayment = _calendarMetadata!.monthly_payment_amount ?? 0.0;
      _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      classes = _fetchedOrganizations.map((org) => org.description).toList();
      _fetchLeaveDates(_year, _month);
      _fetchedExcelReportData = await getActivityAttendanceReportByBatch(
          _selectedOrganizationValue!.id!,
          activityId,
          DateFormat('yyyy-MM-dd').format(firstDateOfMonth),
          DateFormat('yyyy-MM-dd').format(lastDateOfMonth));
      _fetchedStudentList =
          await fetchStudentListByBatchId(_selectedOrganizationValue!.id!);
      setState(() {
        _selectedOrganizationValue;
        _fetchedOrganizations = _fetchedOrganizations;
        this._fetchedExcelReportData = _fetchedExcelReportData;
        this._fetchedStudentList = _fetchedStudentList;
        this._isFetching = false;
      });
    }
    return _batchData;
  }

  Future<void> _fetchLeaveDates(int year, int month) async {
    try {
      // Fetch leave dates and payment details for the month
      List<LeaveDate> fetchedDates = await getLeaveDatesForMonth(
          year, month, organization_id, _selectedOrganizationValue!.id!);

      _totalDaysInMonth = DateTime(_year, _month + 1, 0).day;
      _totalSchoolDaysInMonth = _totalDaysInMonth - fetchedDates.length;
      _monthFullName = DateFormat.MMMM().format(DateTime(0, _month));

      setState(() {
        if (fetchedDates.isNotEmpty) {
          _dailyAmount = fetchedDates.first.dailyAmount;
          // MonthlyPayment = DailyPayment * fetchedDates.length;
        } else {
          _dailyAmount = 0.00;
        }
      });
    } catch (e) {
      print("Error fetching leave dates: $e");
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _data = MyData(_fetchedAttendance, columnNames, _fetchedOrganization,
        updateSelected, _dailyAmount);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;

    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
      locale: localeObj,
    );

    if (selected != null) {
      int year = selected.year;
      int month = selected.month;

      // Calculate the start and end dates of the selected month
      final _rangeStart = DateTime(year, month, 1); // First day of the month
      final _rangeEnd = DateTime(year, month + 1, 0); // Last day of the month

      // Pass the calculated dates to updateDateRange
      updateDateRange(_rangeStart, _rangeEnd);

      setState(() {
        _selected = selected;
      });
      //widget.onYearMonthSelected(selected.year, selected.month);
      selectedYearAndMonth(selected.year, selected.month);
    }
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    //widget.updateDateRangeForExcel(_rangeStart, _rangeEnd);
    // int? parentOrgId =
    //     campusAppsPortalInstance.getUserPerson().organization!.id;
    _fetchLeaveDates(_rangeStart.year, _rangeStart.month);

    // if (_fetchedOrganization != null) {
    //   _fetchedAttendance = await getClassActivityAttendanceReportForPayment(
    //       this._fetchedOrganization!.id!,
    //       activityId,
    //       DateFormat('yyyy-MM-dd').format(_rangeStart),
    //       DateFormat('yyyy-MM-dd').format(_rangeEnd));
    // }
    if (_selectedOrganizationValue != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        _calendarMetadata = await fetchCalendarMetaDataByOrgId(
            organization_id, _selectedOrganizationValue!.id!);

        MonthlyPayment = _calendarMetadata!.monthly_payment_amount ?? 0.0;

        _fetchedExcelReportData = await getActivityAttendanceReportByBatch(
            _selectedOrganizationValue!.id!,
            activityId,
            DateFormat('yyyy-MM-dd').format(_rangeStart),
            DateFormat('yyyy-MM-dd').format(_rangeEnd));
        final fetchedStudentList =
            await fetchStudentListByBatchId(_selectedOrganizationValue!.id!);
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedStudentList = fetchedStudentList;
          this._fetchedExcelReportData = _fetchedExcelReportData;
          _fetchedAttendance;
          MonthlyPayment;
          _calendarMetadata;
          _isFetching = false;
          if (this._selectedValue != null) {
            refreshState(this._selectedValue);
          }
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

  void refreshState(Organization? newValue) async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
    var cols =
        columnNames.map((label) => DataColumn(label: Text(label!))).toList();
    _selectedValue = newValue!;
    // print(newValue.id);
    _fetchedOrganization = await fetchOrganization(newValue.id!);

    _fetchedAttendance = await getClassActivityAttendanceReportForPayment(
        _fetchedOrganization!.id!,
        activityId,
        DateFormat('yyyy-MM-dd')
            .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
        DateFormat('yyyy-MM-dd')
            .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
    if (_fetchedAttendance.length > 0) {
      // Add null check here
      // Process attendance data here
      columnNames.clear();
      List<String?> names = _fetchedAttendance
          .map((attendance) => attendance.sign_in_time?.split(" ")[0])
          .where((name) => name != null) // Filter out null values
          .toList();
      columnNames.addAll(names);
    } else {
      columnNames.clear();
    }

    columnNames = columnNames.toSet().toList();
    columnNames.sort();
    columnNames.insert(0, "Name");
    columnNames.insert(1, "NIC");
    columnNames.insert(columnNames.length, "Present Count");
    columnNames.insert(columnNames.length, "Absent Count");
    columnNames.insert(columnNames.length, "Student Payment Rs.");
    // columnNames.insert(columnNames.length, "Phone Payment Rs.");
    cols = columnNames.map((label) => DataColumn(label: Text(label!))).toList();
    print(cols.length);
    if (_fetchedAttendance.length == 0)
      _fetchedAttendance = new List.filled(_fetchedOrganization!.people.length,
          new ActivityAttendance(person_id: -1));
    else {
      for (int i = 0; i < _fetchedOrganization!.people.length; i++) {
        if (_fetchedAttendance.indexWhere((attendance) =>
                attendance.person_id == _fetchedOrganization!.people[i].id) ==
            -1) {
          _fetchedAttendance.add(new ActivityAttendance(person_id: -1));
        }
      }
    }

    setState(() {
      _fetchedOrganization;
      this._isFetching = false;
      _data = MyData(_fetchedAttendance, columnNames, _fetchedOrganization,
          updateSelected, _dailyAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    var cols =
        columnNames.map((label) => DataColumn(label: Text(label!))).toList();

    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Wrap(
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(width: 20),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // for (var org in campusAppsPortalInstance
                        //     .getUserPerson()
                        //     .organization!
                        //     .child_organizations)
                        // create a text widget with some padding
                        SizedBox(width: 5),
                        Text('Select a Batch:'),
                        SizedBox(width: 5),
                        FutureBuilder<List<Organization>>(
                          future: _fetchBatchData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: SpinKitCircle(
                                  color: (Colors.deepPurpleAccent),
                                  size: 70,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('Something went wrong...'),
                              );
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text('No batch found'),
                              );
                            }
                            final batchData = snapshot.data!;
                            return DropdownButton<Organization>(
                                value: _selectedOrganizationValue,
                                items: batchData.map((Organization batch) {
                                  return DropdownMenuItem(
                                      value: batch,
                                      child: Text(batch.name!.name_en ?? ''));
                                }).toList(),
                                onChanged: (Organization? newValue) async {
                                  if (newValue == null) {
                                    return;
                                  }

                                  if (newValue.organization_metadata.isEmpty) {
                                    return;
                                  }

                                  setState(() {
                                    _isFetching = true;
                                  });
                                  _selectedOrganizationValue = newValue;
                                  _fetchedOrganization =
                                      await fetchOrganization(newValue!.id!);
                                  _fetchedOrganizations = _fetchedOrganization
                                          ?.child_organizations ??
                                      [];

                                  // Calculate the start and end dates of the selected month
                                  final _rangeStart = DateTime(_year, _month,
                                      1); // First day of the month
                                  final _rangeEnd = DateTime(_year, _month + 1,
                                      0); // Last day of the month

                                  classes = _fetchedOrganizations
                                      .map((org) => org.description)
                                      .toList();

                                  _calendarMetadata =
                                      await fetchCalendarMetaDataByOrgId(
                                          organization_id, newValue.id!);
                                  MonthlyPayment = _calendarMetadata!
                                          .monthly_payment_amount ??
                                      0.0;
                                  _fetchLeaveDates(_year, _month);
                                  _fetchedExcelReportData =
                                      await getActivityAttendanceReportByBatch(
                                          _selectedOrganizationValue!.id!,
                                          activityId,
                                          DateFormat('yyyy-MM-dd')
                                              .format(_rangeStart),
                                          DateFormat('yyyy-MM-dd')
                                              .format(_rangeEnd));
                                  final fetchedStudentList =
                                      await fetchStudentListByBatchId(
                                          _selectedOrganizationValue!.id!);
                                  setState(() {
                                    _fetchedOrganizations;
                                    _selectedValue = null;
                                    _selectedValue;
                                    _selectedOrganizationValue = newValue;
                                    MonthlyPayment;
                                    _calendarMetadata;
                                    this._fetchedStudentList =
                                        fetchedStudentList;
                                    this._fetchedExcelReportData =
                                        _fetchedExcelReportData;
                                    _isFetching = false;
                                  });
                                });
                          },
                        ),
                        SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (_fetchedOrganizations.length > 0)
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, top: 20, bottom: 10),
                                  child: Row(children: <Widget>[
                                    Text('Select a class:'),
                                    SizedBox(width: 5),
                                    DropdownButton<Organization>(
                                      value: _selectedValue,
                                      onChanged:
                                          (Organization? newValue) async {
                                        _selectedValue = newValue!;
                                        print(newValue.id);
                                        setState(() {
                                          _isFetching = true;
                                        });
                                        _fetchedOrganization =
                                            await fetchOrganization(
                                                newValue.id!);

                                        _fetchedAttendance =
                                            await getClassActivityAttendanceReportForPayment(
                                                _fetchedOrganization!.id!,
                                                activityId,
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateFormat('MMM d, yyyy')
                                                        .parse(this
                                                            .formattedStartDate)),
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateFormat('MMM d, yyyy')
                                                        .parse(this
                                                            .formattedEndDate)));
                                        if (_fetchedAttendance.length > 0) {
                                          // Add null check here
                                          // Process attendance data here
                                          columnNames.clear();
                                          List<String?> names =
                                              _fetchedAttendance
                                                  .map((attendance) =>
                                                      attendance.sign_in_time
                                                          ?.split(" ")[0])
                                                  .where((name) =>
                                                      name !=
                                                      null) // Filter out null values
                                                  .toList();
                                          columnNames.addAll(names);
                                        } else {
                                          columnNames.clear();
                                        }

                                        columnNames =
                                            columnNames.toSet().toList();
                                        columnNames.sort();
                                        columnNames.insert(0, "Name");
                                        columnNames.insert(1, "NIC");
                                        columnNames.insert(columnNames.length,
                                            "Present Count");
                                        columnNames.insert(
                                            columnNames.length, "Absent Count");
                                        columnNames.insert(columnNames.length,
                                            "Student Payment Rs.");
                                        // columnNames.insert(columnNames.length,
                                        //     "Phone Payment Rs.");
                                        cols = columnNames
                                            .map((label) =>
                                                DataColumn(label: Text(label!)))
                                            .toList();
                                        print(cols.length);
                                        if (_fetchedAttendance.length == 0)
                                          _fetchedAttendance = new List.filled(
                                              _fetchedOrganization!
                                                  .people.length,
                                              new ActivityAttendance(
                                                  person_id: -1));
                                        else {
                                          for (int i = 0;
                                              i <
                                                  _fetchedOrganization!
                                                      .people.length;
                                              i++) {
                                            if (_fetchedAttendance.indexWhere(
                                                    (attendance) =>
                                                        attendance.person_id ==
                                                        _fetchedOrganization!
                                                            .people[i].id) ==
                                                -1) {
                                              _fetchedAttendance.add(
                                                  new ActivityAttendance(
                                                      person_id: -1));
                                            }
                                          }
                                        }
                                        setState(() {
                                          _isFetching = false;
                                          _fetchedOrganization;
                                          _data = MyData(
                                              _fetchedAttendance,
                                              columnNames,
                                              _fetchedOrganization,
                                              updateSelected,
                                              _dailyAmount);
                                        });
                                      },
                                      items: _fetchedOrganizations
                                          .map((Organization value) {
                                        return DropdownMenuItem<Organization>(
                                          value: value,
                                          child: Text(value.description!),
                                        );
                                      }).toList(),
                                    ),
                                  ]),
                                ),
                            ]),
                        SizedBox(width: 10),
                        FittedBox(
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LeaveDatePicker(
                                        organizationId: organization_id ??
                                            0, // Provide a default value if needed
                                        batchId:
                                            _selectedOrganizationValue?.id ?? 0,
                                        year: _selected?.year ??
                                            _year, // Ensure an `int` value is passed
                                        month: _selected?.month ?? _month,
                                        selectedDay:
                                            _selectedDay ?? DateTime.now(),
                                      ),
                                    )).then((value) {
                                  setState(() {
                                    _isFetching = true;
                                  });

                                  _fetchLeaveDates(_year, _month);

                                  setState(() {
                                    _isFetching = false;
                                  });
                                });
                              },
                              child: const Text('Update Monthly Leave Dates'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Select a Year & Month :',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            TextButton(
                              onPressed: () =>
                                  _onPressed(context: context, locale: 'en'),
                              child: Icon(Icons.calendar_month),
                            ),
                            if (_selected == null)
                              Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: const Text(
                                  'No month & year selected.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              )
                            else
                              Container(
                                child: Text(
                                  DateFormat.yMMMM()
                                      .format(_selected!)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 20),
                        this._isFetching
                            ? Container(
                                margin: EdgeInsets.only(top: 10),
                                child: SpinKitCircle(
                                  color: (Colors
                                      .deepPurpleAccent), // Customize the color of the indicator
                                  size:
                                      50, // Customize the size of the indicator
                                ))
                            : MonthlyPaymentReportExcelExport(
                                classes: classes,
                                fetchedAttendance: _fetchedExcelReportData,
                                columnNames: columnNames,
                                fetchedStudentList: _fetchedStudentList,
                                isFetching: _isFetching,
                                totalSchoolDaysInMonth: _totalSchoolDaysInMonth,
                                dailyAmount: _dailyAmount,
                                year: _year,
                                month: _monthFullName,
                                batch:
                                    _selectedOrganizationValue!.name!.name_en!,
                              )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Payment Amount:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rs. ${MonthlyPayment}',
                                // 'Rs.10000.00',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Payment Amount:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rs. ${_dailyAmount}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 32.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isFetching)
                      Container(
                        margin: EdgeInsets.only(top: 180),
                        child: SpinKitCircle(
                          color: (Colors
                              .deepPurpleAccent), // Customize the color of the indicator
                          size: 50, // Customize the size of the indicator
                        ),
                      )
                    else if (cols.length > 2)
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          source: _data,
                          columns: cols,
                          // header: const Center(child: Text('Daily Attendance')),
                          columnSpacing: 100,
                          horizontalMargin: 60,
                          rowsPerPage: 22,
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Text('No attendance data found'),
                      ),
                  ],
                )
              ],
            ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedAttendance, this.columnNames, this._fetchedOrganization,
      this.updateSelected, this.DailyPayment);

  final List<ActivityAttendance> _fetchedAttendance;
  final List<String?> columnNames;
  final Organization? _fetchedOrganization;
  final Function(int, bool, List<bool>) updateSelected;
  final double? DailyPayment;

  List<String> getDatesFromMondayToToday() {
    DateTime now = DateTime.now();
    DateTime previousMonday = now.subtract(Duration(days: now.weekday - 1));
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    List<String> dates = [];
    for (DateTime date = previousMonday;
        date.isBefore(currentDate);
        date = date.add(Duration(days: 1))) {
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        dates.add(DateFormat('yyyy-MM-dd').format(date));
      }
    }

    return dates;
  }

  @override
  DataRow? getRow(int index) {
    if (index == 0) {
      List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(child: Text("Absent"), color: Colors.red)),
      );
      cells[0] = DataCell(Text(''));
      cells[1] = DataCell(Text(''));
      // cells[columnNames.length - 4] = DataCell(Text(''));
      cells[columnNames.length - 3] = DataCell(Text(''));
      cells[columnNames.length - 2] = DataCell(Text(''));
      cells[columnNames.length - 1] = DataCell(Text(''));

      for (final date in columnNames) {
        if (columnNames.indexOf(date) == 0 ||
            columnNames.indexOf(date) == 1 ||
            // columnNames.indexOf(date) == columnNames.length - 4 ||
            columnNames.indexOf(date) == columnNames.length - 3 ||
            columnNames.indexOf(date) == columnNames.length - 2 ||
            columnNames.indexOf(date) == columnNames.length - 1) {
          continue;
        }

        date == '$date 00:00:00';
        cells[columnNames.indexOf(date)] = DataCell(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Text(DateFormat.EEEE().format(DateTime.parse(date!)),
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ));
      }
      return DataRow(
        cells: cells,
      );
    }
    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty &&
        columnNames.length > 0) {
      var person = _fetchedOrganization!
          .people[index - 1]; // to facilitate additional rows
      List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(
            alignment: Alignment.center,
            child: Text("Absent",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )))),
      );

      cells[0] = DataCell(Text(person.preferred_name!));
      cells[1] = DataCell(Text(person.nic_no.toString()));

      int absentCount = 0;

      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      final dateFormatter = DateFormat('yyyy-MM-dd');

      for (var element in columnNames) {
        if (dateRegex.hasMatch(element!)) {
          try {
            dateFormatter.parseStrict(element);
            absentCount++;
          } catch (e) {
            // Handle the exception or continue to the next element
          }
        }
      }
      cells[columnNames.length - 3] = DataCell(Container(
          alignment: Alignment.center,
          child: Text(
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              '0')));

      cells[columnNames.length - 2] = DataCell(Container(
          alignment: Alignment.center,
          child: Text(
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              absentCount.toString())));

      cells[columnNames.length - 1] = DataCell(Container(
          alignment: Alignment.center,
          child: Text(
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              '0')));

      // cells[columnNames.length - 1] = DataCell(Container(
      //     alignment: Alignment.center,
      //     child: Text(
      //         style: TextStyle(
      //           color: Color.fromARGB(255, 14, 72, 90),
      //           fontSize: 16,
      //           fontWeight: FontWeight.bold,
      //         ),
      //         '0')));

      int presentCount = 0;
      for (final attendance in _fetchedAttendance) {
        if (attendance.person_id == person.id) {
          int newAbsentCount = 0;
          for (final date in columnNames) {
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              presentCount++;
              // print(
              //     'index ${index} date ${date} person_id ${attendance.person_id} sign_in_time ${attendance.sign_in_time} columnNames length ${columnNames.length} columnNames.indexOf(date) ${columnNames.indexOf(date)}');
              cells[columnNames.indexOf(date)] = DataCell(Container(
                  alignment: Alignment.center, child: Text("Present")));
            }
          }

          newAbsentCount = absentCount - presentCount;
          cells[columnNames.length - 3] = DataCell(Container(
              alignment: Alignment.center,
              child: Text(
                  style: TextStyle(
                    color: Color.fromARGB(255, 14, 72, 90),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  presentCount.toString())));
          cells[columnNames.length - 2] = DataCell(Container(
              alignment: Alignment.center,
              child: Text(
                  style: TextStyle(
                    color: Color.fromARGB(255, 14, 72, 90),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  newAbsentCount.toString())));
          double studentPayment = (DailyPayment ?? 0.0) * presentCount;
          cells[columnNames.length - 1] = DataCell(Container(
              alignment: Alignment.center,
              child: Text(
                  style: TextStyle(
                    color: Color.fromARGB(255, 14, 72, 90),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  studentPayment.toDouble().toStringAsFixed(2))));
          // cells[columnNames.length - 1] = DataCell(Container(
          //     alignment: Alignment.center,
          //     child: Text(
          //         style: TextStyle(
          //           color: Color.fromARGB(255, 14, 72, 90),
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //         studentPayment.toDouble().toStringAsFixed(2))));
        }
      }

      int numItems = _fetchedOrganization!.people.length;
      List<bool> selected = List<bool>.generate(numItems, (int index) => false);
      return DataRow(
        cells: cells,
        onSelectChanged: (value) {
          updateSelected(index, value!,
              selected); // Call the callback to update the selected state
        },
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.grey.withOpacity(0.4);
          }
          if (index.isEven) {
            return Colors.grey.withOpacity(0.2);
          }
          return null;
        }),
      );
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    if (_fetchedOrganization != null) {
      count = _fetchedOrganization?.people.length ?? 0;
      count += 1; //to facilitate additional rows
    }
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
