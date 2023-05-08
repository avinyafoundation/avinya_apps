import 'dart:math';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:collection/collection.dart';

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

  late DataTableSource _data;

  //  final List<Map<String, dynamic>> _fetchedAttendance = []; // First data set
  // final List<Map<String, dynamic>> _fetchedOrganization = []; // Second data set
  // final DataTableSource _data = MyData(_fetchedAttendance, _fetchedOrganization);

  // DataTableSource? _attendanceDataSource;
  List<String?> columnNames = [];

  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  var afterSchoolActivityId = 0;

  @override
  void initState() {
    super.initState();
    // _data = MyData(_fetchedAttendance, columnNames, _fetchedOrganization);
    if (campusAppsPortalInstance.isTeacher) {
      activityId = campusAppsPortalInstance.activityIds['homeroom']!;
      afterSchoolActivityId =
          campusAppsPortalInstance.activityIds['after-school']!;
    } else if (campusAppsPortalInstance.isSecurity)
      activityId = campusAppsPortalInstance.activityIds['arrival']!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedAttendance, columnNames, _fetchedOrganization);
  }

  @override
  Widget build(BuildContext context) {
    // var cols = [
    //   DataColumn(label: Text('ID')),
    //   DataColumn(label: Text('Name')),
    //   DataColumn(label: Text('Price'))
    // ];
    // if (_fetchedOrganization != null &&
    //     _fetchedOrganization!.people.isNotEmpty) {
    //   _fetchedOrganization!.people.forEach((person) {
    //   _fetchedAttendance
    //         .asMap()
    //         .map((i, element) {
    //           String? columnName = element.sign_in_time;
    //           if (columnName != null) {
    //             columnName = columnName.split(" ")[0];
    //             // _attendanceDataSource!._sort<String>(
    //             //   (d) => columnName!,
    //             //   _sortAscending.value,
    //             // );
    //             // return MapEntry(
    //             //     i, _attendanceDataSource!._fetchedAttendance[i]);
    //           }
    //           return MapEntry(i, element);
    //         })
    //         .values
    //         .toList();
    //   });
    // }

    // List<String> columnNames = _fetchedAttendance
    //     .map((attendance) => attendance.sign_in_time!.split(" ")[0])
    //     .toList();

    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty) {
      _fetchedOrganization!.people.forEach((person) {
        if (_fetchedAttendance.length > 0) {
          // Add null check here
          // Process attendance data here
          List<String?> names = _fetchedAttendance
              .map((attendance) => attendance.sign_in_time?.split(" ")[0])
              .where((name) => name != null) // Filter out null values
              .toList();
          columnNames.addAll(names);
        }
      });
      columnNames = columnNames.toSet().toList(); // Remove duplicates
    }

    // Get unique sign-in dates from signInData
// var uniqueDates = _fetchedAttendance.map((data) => data.sign_in_time.split(" ")[0]).toSet().toList();

// Sort dates in ascending order
    columnNames.sort();

// Combine person_id and unique dates into header labels array
    var headerLabels = ["person", ...columnNames];
    // var headerLabels = ['ID2', 'Name', 'Price'];
    var cols =
        headerLabels.map((label) => DataColumn(label: Text(label!))).toList();

    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Column(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (var org in campusAppsPortalInstance
                        .getUserPerson()
                        .organization!
                        .child_organizations)
                      // create a text widget with some padding
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (org.child_organizations.length > 0)
                              Row(children: <Widget>[
                                Text('Select a class:'),
                                SizedBox(width: 10),
                                DropdownButton<Organization>(
                                  value: _selectedValue,
                                  onChanged: (Organization? newValue) async {
                                    _selectedValue = newValue!;
                                    print(newValue.id);
                                    _fetchedOrganization =
                                        await fetchOrganization(newValue.id!);

                                    _fetchedAttendance =
                                        await getClassActivityAttendanceReport(
                                            _fetchedOrganization!.id!,
                                            activityId,
                                            250);
                                    if (_fetchedAttendance.length == 0)
                                      _fetchedAttendance = new List.filled(
                                          _fetchedOrganization!.people.length,
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
                                    if (campusAppsPortalInstance.isTeacher) {
                                      _fetchedAttendanceAfterSchool =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              afterSchoolActivityId,
                                              250);
                                      _fetchedAttendanceAfterSchool =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              afterSchoolActivityId,
                                              250);
                                      if (_fetchedAttendanceAfterSchool
                                              .length ==
                                          0)
                                        _fetchedAttendanceAfterSchool =
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
                                          if (_fetchedAttendanceAfterSchool
                                                  .indexWhere((attendance) =>
                                                      attendance.person_id ==
                                                      _fetchedOrganization!
                                                          .people[i].id) ==
                                              -1) {
                                            _fetchedAttendanceAfterSchool.add(
                                                new ActivityAttendance(
                                                    person_id: -1));
                                          }
                                        }
                                      }
                                    }
                                    // Pass the fetched data to the constructor of the new class
                                    // DataTableSource(_fetchedAttendance);
                                    // MyData(_fetchedAttendance, columnNames,
                                    //     _fetchedOrganization);

                                    // setState(() {});
                                    setState(() {
                                      _data = MyData(_fetchedAttendance,
                                          columnNames, _fetchedOrganization);
                                    });
                                  },
                                  items: org.child_organizations
                                      .map((Organization value) {
                                    return DropdownMenuItem<Organization>(
                                      value: value,
                                      child: Text(value.description!),
                                    );
                                  }).toList(),
                                ),
                              ]),
                          ]),
                  ],
                ),
                Column(
                  children: <Widget>[
                    if (cols.length > 0)
                      PaginatedDataTable(
                        source: _data,
                        columns: cols,
                        header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 100,
                        horizontalMargin: 60,
                        rowsPerPage: 8,
                      ),
                  ],
                )
              ],
            ),
    );
  }
}

class MyData extends DataTableSource {
  // final List<Map<String, dynamic>> _data = List.generate(
  //     200,
  //     (index) => {
  //           "id": index,
  //           "title": "Item $index",
  //           "price": Random().nextInt(10000)
  //         });

  MyData(this._fetchedAttendance, this.columnNames, this._fetchedOrganization);

  final List<ActivityAttendance> _fetchedAttendance;
  final List<String?> columnNames;
  final Organization? _fetchedOrganization;

// final List<Map<String, dynamic>> data1;
//   final List<Map<String, dynamic>> data2;

//   MyData(this.data1, this.data2);

  // @override
  // DataRow? getRow(int index) {
  //   return DataRow(cells: [
  //     DataCell(Text(_data[index]['sign_in_time'].toString())),
  //     DataCell(Text(_data[index]["title"])),
  //     DataCell(Text(_data[index]["price"].toString())),
  //   ]);
  // }

  // @override
  // DataRow? getRow(int index) {
  //   return DataRow(cells: [
  //     DataCell(Text(_data[index]['sign_in_time'].toString())),
  //     DataCell(Text(_data[index]["title"])),
  //     DataCell(Text(_data[index]["price"].toString())),
  //   ]);
  // }

  @override
  DataRow? getRow(int index) {
    final List<DataRow> rows = [];

    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty) {
      for (final person in _fetchedOrganization!.people) {
        final List<DataCell> cells = [];
        cells.add(DataCell(Text(person.preferred_name!)));
        for (final date in columnNames) {
          for (final attendance in _fetchedAttendance) {
            if (attendance.person == person.id) {
              if (attendance.sign_in_time != null &&
                  attendance.sign_in_time!.split(" ")[0] == date) {
                // print('Present');
                cells.add(DataCell(Text("Present")));
              } else if (attendance.sign_in_time != null &&
                  attendance.sign_in_time!.split(" ")[0] != date) {
                // print('Absent');
                cells.add(DataCell(Text("Absent")));
              }
            }
          }
          return DataRow(cells: cells);
          // rows.add(DataRow(cells: cells));
        }
        // rows.add(DataRow(cells: cells));
        // if (rows.length == 3) {
        //   return DataRow(cells: cells);
        // }
        // if (rows.isNotEmpty) {
        //   return rows[index % rows.length];
        // }

        // print("Cells: ${cells}");
      }
      // if (rows.isNotEmpty) {
      //   return rows[index % rows.length];
      // }
      print("Cells: ${rows}");
      // return DataRow(cells: [
      //   DataCell(Text("ss1")),
      //   DataCell(Text("ss2")),
      //   DataCell(Text("ss3")),
      //   DataCell(Text("ss4")),
      // ]);
    }
    return null;
  }

  // @override
  // DataRow? getRow(int index) {
  //   final List<DataRow> rows = [];

  //   if (_fetchedOrganization != null &&
  //       _fetchedOrganization!.people.isNotEmpty) {
  //     for (final person in _fetchedOrganization!.people) {
  //       final List<DataCell> cells = [];
  //       cells.add(DataCell(Text(person.preferred_name!)));
  //       for (final date in columnNames) {
  //         bool isPresent = false;
  //         for (final attendance in _fetchedAttendance) {
  //           if (attendance.person == person.id &&
  //               attendance.sign_in_time != null &&
  //               attendance.sign_in_time!.split(" ")[0] == date) {
  //             cells.add(DataCell(Text("Present")));
  //             isPresent = true;
  //             break; // Stop checking attendance records for this date
  //           }
  //           if (!isPresent) {
  //             cells.add(DataCell(Text("Absent")));
  //           }
  //         }

  //         // final List<DataCell> row = cells;
  //       }
  //       return DataRow(cells: cells);

  //       // print("Cells: ${cells}");
  //       // rows.add(DataRow(cells: cells));
  //       // final row = cells;
  //       // DataRow(cells: cells); // Create a new DataRow for each person
  //       // print("Cells: ${row}");
  //       // return DataRow(cells: row);

  //       // rows.add(row);
  //     }
  //     // var row;

  //     // if (rows.isNotEmpty) {
  //     //   return rows[index % rows.length];
  //     // }
  //   }
  //   return null;
  // }

  // @override
  // DataRow? getRow(int index) {
  //   final List<DataRow> rows = [];

  //   if (_fetchedOrganization != null &&
  //       _fetchedOrganization!.people.isNotEmpty) {
  //     for (final person in _fetchedOrganization!.people) {
  //       final List<DataCell> cells = [];

  //       for (final date in columnNames) {
  //         final attendance = _fetchedAttendance.firstWhere(
  //           (attendance) =>
  //               attendance.person_id == person.id &&
  //               attendance.sign_in_time?.split(" ")[0] == date,
  //           orElse: () => ActivityAttendance(person_id: -1),
  //         );

  //         String cellContent = 'Absent';

  //         if (attendance.person_id != -1 && attendance.sign_in_time != null) {
  //           cellContent = 'Present';
  //         }

  //         cells.add(DataCell(Text(cellContent)));
  //       }

  //       rows.add(DataRow(cells: cells));
  //       print("Cells: $cells");
  //     }

  //     if (rows.isNotEmpty) {
  //       return rows[index % rows.length];
  //     }
  //   }

  //   return null;
  // }

  // DataRow? getRow(int index) {
  //   print("_fetchedAttendance: ${_fetchedAttendance.length}");

  //   // print('getRow called');
  //   if (_fetchedOrganization != null &&
  //       _fetchedOrganization!.people.isNotEmpty) {
  //     final List<DataCell> cells = [];

  //     // Loop over each person
  //     for (final person in _fetchedOrganization!.people) {
  //       // cells.add(DataCell(Text(person.preferred_name!)));

  //       // Loop over each date
  //       for (final date in columnNames) {
  //         final attendance = _fetchedAttendance.firstWhereOrNull(
  //           (attendance) =>
  //               attendance.person_id == person.id &&
  //               attendance.sign_in_time?.split(" ")[0] == date,
  //         );
  //         final bool isChecked = attendance != null &&
  //             attendance.person_id != -1 &&
  //             attendance.sign_in_time != null;

  //         // Add a checkbox cell for the person and date combination
  //         cells.add(DataCell(
  //           isChecked ? Icon(Icons.check) : Icon(Icons.close),
  //         ));
  //         print(
  //             "Person: ${person.preferred_name!},Att: ${attendance?.sign_in_time}, Date: $date, Attendance: $attendance, isChecked: $isChecked");
  //       }
  //       // print("Cells: $cells");
  //       // print("Cells: ${cells.length}");
  //     }
  //     // print("Hello, world!");
  //     window.console.log("Hello, world from console!");
  //     return DataRow(cells: cells);
  //   }
  //   return null;
  // }

  // DataRow? getRow(int index) {
  //   if (_fetchedOrganization != null) if (_fetchedOrganization!.people.length >
  //       0)
  //     _fetchedOrganization!.people.map((person) {
  //       return DataRow(cells: [
  //         DataCell(Text(person.preferred_name!)),
  //         DataCell(Text(person.digital_id!)),
  //         // sign in
  //         if (_fetchedAttendance.length > 0)
  //           if (columnNames.length > 0)
  //             for (int i = 0; i < columnNames.length; i++)
  //               if (_fetchedAttendance
  //                       .firstWhere(
  //                         (attendance) =>
  //                             attendance.person_id == person.id &&
  //                             attendance.sign_in_time != null,
  //                       )
  //                       .person_id !=
  //                   -1)
  //                 DataCell(
  //                   Checkbox(
  //                     value: _fetchedAttendance
  //                             .firstWhere(
  //                               (attendance) =>
  //                                   attendance.person_id == person.id &&
  //                                   attendance.sign_in_time != null,
  //                             )
  //                             .sign_in_time !=
  //                         null,
  //                     onChanged: (bool? value) async {
  //                       await toggleAttendance(person.id!, value!, true, false);
  //                       // setState(() {});
  //                     },
  //                   ),
  //                 )
  //               else
  //                 DataCell(
  //                   Checkbox(
  //                     value: false,
  //                     onChanged: (bool? value) async {
  //                       await toggleAttendance(person.id!, value!, true, false);
  //                     },
  //                   ),
  //                 ),
  //       ]);
  //     }).toList();
  //   return null;
  // }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _fetchedOrganization?.people.length ?? 0;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

toggleAttendance(int i, bool bool, bool bool2, bool bool3) {}
