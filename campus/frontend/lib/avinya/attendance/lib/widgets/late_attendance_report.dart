import 'package:flutter/material.dart';
// import 'package:attendance/widgets/week_picker.dart';
import 'package:attendance/widgets/date_range_picker.dart';
import 'package:attendance/widgets/excel_export.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'daily_late_attendance_excel_report_export.dart';

class LateAttendanceReport extends StatefulWidget {
  const LateAttendanceReport({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LateAttendanceReport> createState() => _LateAttendanceReportState();
}

class _LateAttendanceReportState extends State<LateAttendanceReport> {
  List<ActivityAttendance> _fetchedAttendance = [];
  List<Person> _fetchedStudentList = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;

  //calendar specific variables
  DateTime? _selectedDay;

  late DataTableSource _data;
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;

  List<DataColumn> ColumnNames = [];

  late String formattedStartDate;
  late String formattedEndDate;
  var today = DateTime.now();

  List<Organization> _batchData = [];
  Organization? _selectedOrganizationValue;
  List<Organization> _fetchedOrganizations = [];
  late Future<List<Organization>> _fetchBatchData;

  void selectWeek(DateTime today, activityId) async {
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
    _fetchBatchData = _loadBatchData();
    var today = DateTime.now();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    selectWeek(today, activityId);
  }

  void updateExcelState() {
    DailyLateAttendanceExcelReportExport(
      fetchedDailyLateAttendanceData: _fetchedAttendance,
      updateExcelState: updateExcelState,
      isFetching: _isFetching,
      selectedValue: _selectedValue,
      formattedStartDate: this.formattedStartDate,
      formattedEndDate: this.formattedEndDate,
    );
  }

  Future<List<Organization>> _loadBatchData() async {
    // _batchData = await fetchActiveOrganizationsByAvinyaType();
    _batchData = await fetchOrganizationsByAvinyaTypeAndStatus(null, 1);
    _selectedOrganizationValue = _batchData.isNotEmpty ? _batchData.last : null;

    if (_selectedOrganizationValue != null) {
      int orgId = _selectedOrganizationValue!.id!;
      _fetchedOrganization = await fetchOrganization(orgId);
      _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      setState(() {
        _fetchedOrganizations = _fetchedOrganizations;
      });
    }
    // this.updateDateRange(today, today);
    return _batchData;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _data = MyData(_fetchedAttendance, _selectedValue, updateSelected);
    DateRangePicker(updateDateRange, formattedStartDate);
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
      try {
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedStudentList = _fetchedStudentList;
          refreshState(this._selectedValue);
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
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    _selectedValue = newValue ?? null;

    if (_selectedValue == null) {
      //_fetchedStudentList = await fetchOrganizationForAll(parentOrgId!);
      if (_fetchedOrganization != null) {
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      } else {
        _fetchedOrganization = Organization();
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      }
      // print("Parent Org Id:${parentOrgId}");
      // _fetchedAttendance = await getLateAttendanceReportByParentOrg(
      //     parentOrgId,
      //     activityId,
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
    } else {
      _fetchedOrganization = await fetchOrganization(newValue!.id!);
      _fetchedAttendance = await getLateAttendanceReportByDate(
          _fetchedOrganization!.id!,
          activityId,
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
    }

    String? newSelectedVal;
    if (_selectedValue != null) {
      newSelectedVal = _selectedValue.description;
    }

    setState(() {
      _fetchedOrganization;
      this._isFetching = false;
      _data = MyData(_fetchedAttendance, newSelectedVal, updateSelected);
    });
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> ColumnNames = [];

    if (_selectedValue == null) {
      ColumnNames.add(DataColumn(
          label: Text('Date',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Name',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Digital ID',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Class',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('In Time',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Late By',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    } else {
      ColumnNames.add(DataColumn(
          label: Text('Date',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Name',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Digital ID',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('In Time',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
      ColumnNames.add(DataColumn(
          label: Text('Late By',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    }
    return ColumnNames;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Wrap(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // for (var org in campusAppsPortalInstance
                        //     .getUserPerson()
                        //     .organization!
                        //     .child_organizations)
                        // create a text widget with some padding
                        SizedBox(width: 10),
                        Text('Select a Batch:'),
                        SizedBox(width: 10),
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

                                  _fetchedOrganization =
                                      await fetchOrganization(newValue!.id!);
                                  _fetchedOrganizations = _fetchedOrganization
                                          ?.child_organizations ??
                                      [];

                                  setState(() {
                                    _fetchedOrganizations;
                                    _selectedValue = null;
                                    _selectedOrganizationValue = newValue;
                                    // batchStartDate = DateFormat('MMM d, yyyy')
                                    //     .format(DateTime.parse(
                                    //         _selectedOrganizationValue!
                                    //             .organization_metadata[0].value
                                    //             .toString()));

                                    // batchEndDate = DateFormat('MMM d, yyyy')
                                    //     .format(DateTime.parse(
                                    //         _selectedOrganizationValue!
                                    //             .organization_metadata[1].value
                                    //             .toString()));
                                  });
                                });
                          },
                        ),
                        SizedBox(width: 20),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (_fetchedOrganizations.length > 0)
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 20, top: 20, bottom: 10),
                                  child: Row(children: <Widget>[
                                    Text('Select a class:'),
                                    SizedBox(width: 10),
                                    DropdownButton<Organization>(
                                      value: _selectedValue,
                                      onChanged:
                                          (Organization? newValue) async {
                                        _selectedValue = newValue ?? null;
                                        int? parentOrgId =
                                            campusAppsPortalInstance
                                                .getUserPerson()
                                                .organization!
                                                .id;
                                        if (_selectedValue == null) {
                                          // _fetchedOrganization = null;
                                          _fetchedStudentList =
                                              await fetchOrganizationForAll(
                                                  parentOrgId!);
                                        } else {
                                          // _fetchedStudentList = <Person>[];
                                          _fetchedOrganization =
                                              await fetchOrganization(
                                                  newValue!.id!);
                                        }

                                        if (_selectedValue == null) {
                                          _fetchedAttendance =
                                              await getLateAttendanceReportByParentOrg(
                                                  parentOrgId!,
                                                  activityId,
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(DateFormat(
                                                              'MMM d, yyyy')
                                                          .parse(this
                                                              .formattedStartDate)),
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(DateFormat(
                                                              'MMM d, yyyy')
                                                          .parse(this
                                                              .formattedEndDate)));
                                        } else {
                                          _fetchedAttendance =
                                              await getLateAttendanceReportByDate(
                                                  _fetchedOrganization!.id!,
                                                  activityId,
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(DateFormat(
                                                              'MMM d, yyyy')
                                                          .parse(this
                                                              .formattedStartDate)),
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(DateFormat(
                                                              'MMM d, yyyy')
                                                          .parse(this
                                                              .formattedEndDate)));
                                        }

                                        if (_selectedValue == null) {
                                          setState(() {
                                            if (_fetchedOrganization != null) {
                                              _fetchedOrganization!.people =
                                                  _fetchedStudentList;
                                              _fetchedOrganization!.id =
                                                  parentOrgId;
                                              _fetchedOrganization!
                                                  .description = "Select All";
                                            } else {
                                              _fetchedOrganization =
                                                  Organization();
                                              _fetchedOrganization!.people =
                                                  _fetchedStudentList;
                                              _fetchedOrganization!.id =
                                                  parentOrgId;
                                              _fetchedOrganization!
                                                  .description = "Select All";
                                            }
                                            _fetchedStudentList;
                                            _data = MyData(_fetchedAttendance,
                                                _selectedValue, updateSelected);
                                          });
                                        } else {
                                          setState(() {
                                            _fetchedOrganization;
                                            _fetchedStudentList;
                                            _data = MyData(
                                                _fetchedAttendance,
                                                _selectedValue.description,
                                                updateSelected);
                                          });
                                        }
                                      },
                                      items:
                                          // Add "Select All" option
                                          // DropdownMenuItem<Organization>(
                                          //   value: null,
                                          //   child: Text("Select All"),
                                          // ),
                                          // Add other organization options
                                          _fetchedOrganizations
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
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                          TextStyle(fontSize: 20),
                        ),
                        elevation: MaterialStateProperty.all(20),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.greenAccent),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      onPressed: _isFetching
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DateRangePicker(
                                        updateDateRange, formattedStartDate)),
                              ),
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
                              Icon(Icons.calendar_today, color: Colors.black),
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
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(right: 20.0),
                        width: 25.0,
                        height: 30.0,
                        child: this._isFetching
                            ? null
                            : DailyLateAttendanceExcelReportExport(
                                fetchedDailyLateAttendanceData:
                                    _fetchedAttendance,
                                updateExcelState: updateExcelState,
                                isFetching: _isFetching,
                                selectedValue: _selectedValue,
                                formattedStartDate: this.formattedStartDate,
                                formattedEndDate: this.formattedEndDate,
                              ),
                      ),
                    )
                     ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 32.0),
                Wrap(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
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
                    else if (_fetchedAttendance.length > 0)
                      PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: _buildDataColumns(),
                        // header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 100,
                        horizontalMargin: 60,
                        rowsPerPage: _fetchedAttendance.length + 1,
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
  MyData(this._fetchedAttendance, this._selectedValue, this.updateSelected);

  final List<ActivityAttendance> _fetchedAttendance;
  final String? _selectedValue;
  final Function(int, bool, List<bool>) updateSelected;

  List<int?> selectedPersonIds = [];
  String? lastProcessedDate;
  int? lastProcessedPersonId;
  List<String?> lastProcessedDates = [];
  @override
  DataRow? getRow(int index) {
    if (index == 0 && _selectedValue == null) {
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);
      return DataRow(
        cells: cells,
      );
    } else if (index == 0 && _selectedValue != null) {
      List<DataCell> cells = List<DataCell>.filled(5, DataCell.empty);
      return DataRow(
        cells: cells,
      );
    }

    if (_fetchedAttendance.length > 0 && index <= _fetchedAttendance.length) {
      var date = _fetchedAttendance[index - 1].sign_in_time!.split(" ")[0];
      List<DataCell> cells = [];
      if (_selectedValue == null) {
        cells = List<DataCell>.filled(6, DataCell.empty);
      } else {
        cells = List<DataCell>.filled(5, DataCell.empty);
      }
      var lateSignInTime =
          DateTime.parse(_fetchedAttendance[index - 1].sign_in_time!);
      var officeStartTime = DateTime.parse("$date 08:30:00");
      var lateBy = lateSignInTime.difference(officeStartTime).inMinutes;

      if (lateBy > 0) {
        if (_selectedValue == null) {
          cells[0] = DataCell(
              Text(_fetchedAttendance[index - 1].sign_in_time!.split(" ")[0]));
          cells[1] =
              DataCell(Text(_fetchedAttendance[index - 1].preferred_name!));
          cells[2] = DataCell(
              Text(_fetchedAttendance[index - 1].digital_id.toString()));
          cells[3] = DataCell(
              Text(_fetchedAttendance[index - 1].description.toString()));
          var formattedTime = DateFormat('hh:mm a').format(lateSignInTime);
          cells[4] = DataCell(Text(formattedTime));
          cells[5] = DataCell(Text(lateBy.toString() + " minutes"));
        } else {
          cells[0] = DataCell(
              Text(_fetchedAttendance[index - 1].sign_in_time!.split(" ")[0]));
          cells[1] =
              DataCell(Text(_fetchedAttendance[index - 1].preferred_name!));
          cells[2] = DataCell(
              Text(_fetchedAttendance[index - 1].digital_id.toString()));
          var formattedTime = DateFormat('hh:mm a').format(lateSignInTime);
          cells[3] = DataCell(Text(formattedTime));
          cells[4] = DataCell(Text(lateBy.toString() + " minutes"));
        }

        return DataRow(cells: cells);
      }

      print(cells.length);
    }

    return null; // Return null for invalid index values
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    count = _fetchedAttendance.length + 1;
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
