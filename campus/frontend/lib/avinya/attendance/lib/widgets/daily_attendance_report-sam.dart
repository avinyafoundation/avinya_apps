import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';

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
  List<String?> columnNames = [];
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  var afterSchoolActivityId = 0;

  @override
  void initState() {
    super.initState();
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
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, top: 20, bottom: 10),
                                child: Row(children: <Widget>[
                                  Text('Select a class:'),
                                  SizedBox(width: 10),
                                  DropdownButton<Organization>(
                                    value: _selectedValue,
                                    onChanged: (Organization? newValue) async {
                                      _selectedValue = newValue!;
                                      print(newValue.id);
                                      _fetchedOrganization =
                                          await fetchOrganization(newValue.id!);

<<<<<<< HEAD
                                    _fetchedAttendance =
                                        await getClassActivityAttendanceReport(
                                            _fetchedOrganization!.id!,
                                            activityId,
                                            250);
                                    if (_fetchedAttendance.length > 0) {
                                      // Add null check here
                                      // Process attendance data here
                                      List<String?> names = _fetchedAttendance
                                          .map((attendance) => attendance
                                              .sign_in_time
                                              ?.split(" ")[0])
                                          .where((name) =>
                                              name !=
                                              null) // Filter out null values
                                          .toList();
                                      columnNames = [];
                                      columnNames
                                          .addAll(names.toSet().toList());
                                    }

                                    print(
                                        "columnNames.length ${columnNames.length}");
                                    columnNames.sort();
                                    columnNames.insert(0, "Digital ID");
                                    columnNames.insert(0, "Name");
                                    print(
                                        'columnNames[0] ${columnNames[0]} columnNames[last] ${columnNames[columnNames.length - 1]}');

                                    print(columnNames.length);
                                    cols = columnNames
                                        .map((label) =>
                                            DataColumn(label: Text(label!)))
                                        .toList();
                                    print('cols.length ${cols.length}');
                                    _data = MyData(_fetchedAttendance,
                                        columnNames, _fetchedOrganization);
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
=======
                                      _fetchedAttendance =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              activityId,
                                              250);
                                      if (_fetchedAttendance.length > 0) {
                                        // Add null check here
                                        // Process attendance data here
                                        columnNames.clear();
                                        List<String?> names = _fetchedAttendance
                                            .map((attendance) => attendance
                                                .sign_in_time
                                                ?.split(" ")[0])
                                            .where((name) =>
                                                name !=
                                                null) // Filter out null values
                                            .toList();
                                        columnNames.addAll(names);
                                      } else {
                                        columnNames.clear();
>>>>>>> 94c52eff2d4027467669f6162294cc40cb3a10cc
                                      }

                                      columnNames =
                                          columnNames.toSet().toList();
                                      columnNames.sort();
                                      columnNames.insert(0, "Name");
                                      columnNames.insert(1, "Digital ID");
                                      cols = columnNames
                                          .map((label) =>
                                              DataColumn(label: Text(label!)))
                                          .toList();
                                      print(cols.length);
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
                              ),
                          ]),
                  ],
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 32.0),
                Wrap(children: [
                  (cols.length > 2)
                      ? PaginatedDataTable(
                          source: _data,
                          columns: cols,
                          // header: const Center(child: Text('Daily Attendance')),
                          columnSpacing: 100,
                          horizontalMargin: 60,
                          rowsPerPage: 20,
                        )
                      : Container(
                          margin: EdgeInsets.all(20), // Add margin here
                          child: Text('No attendance data found'),
                        ),
                ]),
              ],
            ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedAttendance, this.columnNames, this._fetchedOrganization);

  final List<ActivityAttendance> _fetchedAttendance;
  final List<String?> columnNames;
  final Organization? _fetchedOrganization;

  @override
  DataRow? getRow(int index) {
    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty &&
        columnNames.length > 0) {
      var person = _fetchedOrganization!.people[index];
      List<DataCell> cells = new List.filled(
<<<<<<< HEAD
        columnNames.length,
        new DataCell(Container(child: Text("Absent"), color: Colors.red)),
      );
      cells[0] = DataCell(Text(person.preferred_name!));
      cells[1] = DataCell(Text(person.digital_id.toString()));
      print('person ${person.preferred_name} ${person.digital_id}');
      print(
          'columnsNames.lenght ${columnNames.length} cells.length ${cells.length}');
      // cells.add(DataCell(Text(person.preferred_name!)));
      // for (final date in columnNames) {
=======
        columnNames.toSet().toList().length,
        new DataCell(Text("Absent")),
      );
      cells[0] = DataCell(Text(person.preferred_name!));
      cells[1] = DataCell(Text(person.digital_id.toString()));
>>>>>>> 94c52eff2d4027467669f6162294cc40cb3a10cc
      for (final attendance in _fetchedAttendance) {
        if (attendance.person_id == person.id) {
          for (final date in columnNames) {
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              // print(
              //     'index ${index} date ${date} person_id ${attendance.person_id} sign_in_time ${attendance.sign_in_time} columnNames length ${columnNames.length} columnNames.indexOf(date) ${columnNames.indexOf(date)}');
              cells[columnNames.indexOf(date)] = DataCell(Text("Present"));
            }
          }
        }
      }
<<<<<<< HEAD
      return DataRow(
        cells: cells,
        color: MaterialStateColor.resolveWith((states) {
          const Set<MaterialState> interactiveStates = <MaterialState>{
            MaterialState.pressed,
            MaterialState.hovered,
            MaterialState.focused,
            MaterialState.selected,
          };
          if (states.any(interactiveStates.contains)) {
            return Colors.blue;
          }
          if (index % 2 == 0) {
            return Colors.grey.shade100;
          } else {
            return Colors.grey.shade200;
          }
        }),
      );

      // }
      // rows.add(DataRow(cells: cells));
      // for (DataRow row in rows) {
      //   print("rows: ${row}");
      // }

      //   DataRow? findDesiredRow(List<DataRow> rows, int desiredIndex) {
      //     if (desiredIndex >= 0 && desiredIndex < rows.length) {
      //       List<DataCell> cells = rows[desiredIndex].cells.toList();
      //       return DataRow(cells: cells);
      //     }

      //     return null; // Return null if the desiredIndex is out of bounds
      //   }

      //   if (rows.length == _fetchedOrganization!.people.length) {
      //     return findDesiredRow(rows, index);
      //   }

      //   // DataRow? desiredRow = findDesiredRow(rows, index);

      //   // if (rows.length == 3) {
      //   //   return DataRow(cells: cells);
      //   // }
      //   // if (rows.isNotEmpty) {
      //   //   return rows[index % rows.length];
      //   // }

      //   // print("rows: ${rows}");
      // //}
      // // if (rows.isNotEmpty) {
      // //   return rows[index % rows.length];
      // // }
      // print("Cells: ${rows}");
      // return DataRow(cells: [
      //   DataCell(Text("ss1")),
      //   DataCell(Text("ss2")),
      //   DataCell(Text("ss3")),
      //   DataCell(Text("ss4")),
      // ]);
=======
      return DataRow(cells: cells);
>>>>>>> 94c52eff2d4027467669f6162294cc40cb3a10cc
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _fetchedOrganization?.people.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
