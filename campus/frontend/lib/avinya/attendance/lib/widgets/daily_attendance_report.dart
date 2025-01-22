import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:attendance/widgets/date_range_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DailyAttendanceReport extends StatefulWidget {
  const DailyAttendanceReport({Key? key, required this.title})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DailyAttendanceReport> createState() => _DailyAttendanceReportState();
}

class _DailyAttendanceReportState extends State<DailyAttendanceReport> {
  List<ActivityAttendance> _fetchedAttendance = [];
  List<ActivityAttendance> _fetchedAttendanceAfterSchool = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;
  List<Person> _fetchedStudentList = [];

  //calendar specific variables
  DateTime? _selectedDay;

  late DataTableSource _data;
  List<String?> columnNames = [];
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  bool _isDisplayErrorMessage = false;

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

  Future<List<Organization>> _loadBatchData() async {
    _batchData = await fetchActiveOrganizationsByAvinyaType(86);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(
        _fetchedAttendance, columnNames, _fetchedOrganization, updateSelected);
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
      _fetchedStudentList = await fetchOrganizationForAll(parentOrgId!);
      if (_fetchedOrganization != null) {
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
      } else {
        _fetchedOrganization = Organization();
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
      }
    } else {
      var cols =
          columnNames.map((label) => DataColumn(label: Text(label!))).toList();

      _fetchedOrganization = await fetchOrganization(newValue!.id!);
      _fetchedAttendance = await getClassActivityAttendanceReportForPayment(
          _fetchedOrganization!.id!,
          activityId,
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));

      if (_fetchedAttendance.length > 0) {
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
      columnNames.insert(1, "Digital ID");
      cols =
          columnNames.map((label) => DataColumn(label: Text(label!))).toList();
      print(cols.length);
      if (_fetchedAttendance.length == 0)
        _fetchedAttendance = new List.filled(
            _fetchedOrganization!.people.length,
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
    }

    String? newSelectedVal;
    if (_selectedValue != null) {
      newSelectedVal = _selectedValue.description;
    }

    setState(() {
      _fetchedOrganization;
      this._isFetching = false;
      _data = MyData(_fetchedAttendance, columnNames, _fetchedOrganization,
          updateSelected);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
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
                        // for (var org in campusAppsPortalInstance
                        //     .getUserPerson()
                        //     .organization!
                        //     .child_organizations)
                        // create a text widget with some padding
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
                                      onChanged: _isFetching
                                          ? null
                                          : (Organization? newValue) async {
                                              _selectedValue = newValue!;
                                              print(newValue.id);

                                              _fetchedOrganization =
                                                  await fetchOrganization(
                                                      newValue.id!);

                                              _fetchedAttendance =
                                                  await getClassActivityAttendanceReportForPayment(
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

                                              if (_fetchedAttendance.length >
                                                  0) {
                                                // Add null check here
                                                // Process attendance data here
                                                columnNames.clear();
                                                List<String?> names =
                                                    _fetchedAttendance
                                                        .map((attendance) =>
                                                            attendance
                                                                .sign_in_time
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
                                              columnNames.insert(
                                                  1, "Digital ID");
                                              cols = columnNames
                                                  .map((label) => DataColumn(
                                                      label: Text(label!)))
                                                  .toList();
                                              print(cols.length);
                                              if (_fetchedAttendance.length ==
                                                  0)
                                                _fetchedAttendance =
                                                    new List.filled(
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
                                                              attendance
                                                                  .person_id ==
                                                              _fetchedOrganization!
                                                                  .people[i]
                                                                  .id) ==
                                                      -1) {
                                                    _fetchedAttendance.add(
                                                        new ActivityAttendance(
                                                            person_id: -1));
                                                  }
                                                }
                                              }
                                              setState(() {
                                                _fetchedOrganization;
                                                _fetchedStudentList;
                                                _data = MyData(
                                                    _fetchedAttendance,
                                                    columnNames,
                                                    _fetchedOrganization,
                                                    updateSelected);
                                              });
                                              _isDisplayErrorMessage = false;
                                            },
                                      items: _fetchedOrganizations
                                          .map((Organization value) {
                                        return DropdownMenuItem<Organization>(
                                          value: value,
                                          child: Text(value.description!),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(width: 20),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all(
                                          TextStyle(fontSize: 20),
                                        ),
                                        elevation:
                                            MaterialStateProperty.all(20),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.greenAccent),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black),
                                      ),
                                      onPressed: _isFetching
                                          ? null
                                          : () {
                                              if (_selectedValue == null) {
                                                setState(() {
                                                  _isDisplayErrorMessage = true;
                                                });
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          DateRangePicker(
                                                              updateDateRange,
                                                              formattedStartDate)),
                                                );
                                                setState(() {
                                                  _isDisplayErrorMessage =
                                                      false;
                                                });
                                              }
                                            },
                                      child: Container(
                                        height:
                                            50, // Adjust the height as needed
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_isFetching)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
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
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: _isDisplayErrorMessage
                      ? Text(
                          'Please select a value from the dropdown',
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox(),
                ),
                SizedBox(height: 32.0),
                SizedBox(height: 32.0),
                Wrap(children: [
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
                        rowsPerPage: 25,
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Text('No attendance data found'),
                    ),
                  // (cols.length > 2 && _fetchedAttendance.length > 0)
                  //     ? PaginatedDataTable(
                  //         showCheckboxColumn: false,
                  //         source: _data,
                  //         columns: cols,
                  //         // header: const Center(child: Text('Daily Attendance')),
                  //         columnSpacing: 100,
                  //         horizontalMargin: 60,
                  //         rowsPerPage: 25,
                  //       )
                  //     : Container(
                  //         margin: EdgeInsets.all(20), // Add margin here
                  //         child: Text('No attendance data found'),
                  //       ),
                ]),
              ],
            ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedAttendance, this.columnNames, this._fetchedOrganization,
      this.updateSelected) {
    columnNames.sort((a, b) => b!.compareTo(a!));
  }

  final List<ActivityAttendance> _fetchedAttendance;
  final List<String?> columnNames;
  final Organization? _fetchedOrganization;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    if (index == 0 || index == 1 || index == 2) {
      List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(child: Text("Absent"), color: Colors.red)),
      );

      if (index == 0) {
        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Text(''));
        for (final date in columnNames) {
          print("date ${date}");
          if (columnNames.indexOf(date) == 0 ||
              columnNames.indexOf(date) == 1) {
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
      } else if (index == 1) {
        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(8),
          child: Text('Present Count',
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ));
        for (final date in columnNames) {
          int presentCount = 0;
          if (columnNames.indexOf(date) == 0 ||
              columnNames.indexOf(date) == 1) {
            continue;
          }
          for (final attendance in _fetchedAttendance) {
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              presentCount++;
            }
          }
          cells[columnNames.indexOf(date)] = DataCell(Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text(presentCount.toString(),
                style: TextStyle(
                  color: Color.fromARGB(255, 14, 72, 90),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ));
        }
      } else if (index == 2) {
        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(8),
          child: Text('Absent Count',
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ));
        for (final date in columnNames) {
          int absentCount = 0;
          int presentCount = 0;
          if (columnNames.indexOf(date) == 0 ||
              columnNames.indexOf(date) == 1) {
            continue;
          }
          for (final attendance in _fetchedAttendance) {
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              presentCount++;
            }
          }
          absentCount = _fetchedOrganization!.people.length - presentCount;
          cells[columnNames.indexOf(date)] = DataCell(Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text(absentCount.toString(),
                style: TextStyle(
                  color: Color.fromARGB(255, 14, 72, 90),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ));
        }
      }

      return DataRow(
        cells: cells,
      );
    }
    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty &&
        columnNames.length > 0) {
      var person = _fetchedOrganization!
          .people[index - 3]; // to facilitate additional rows
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
      cells[1] = DataCell(Text(person.digital_id.toString()));
      for (final attendance in _fetchedAttendance) {
        if (attendance.person_id == person.id) {
          for (final date in columnNames) {
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              // print(
              //     'index ${index} date ${date} person_id ${attendance.person_id} sign_in_time ${attendance.sign_in_time} columnNames length ${columnNames.length} columnNames.indexOf(date) ${columnNames.indexOf(date)}');
              cells[columnNames.indexOf(date)] = DataCell(Container(
                  alignment: Alignment.center, child: Text("Present")));
            }
          }
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
      count += 3; //to facilitate additional rows
    }
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
