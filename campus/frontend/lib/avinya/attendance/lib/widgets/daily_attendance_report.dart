import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(
        _fetchedAttendance, columnNames, _fetchedOrganization, updateSelected);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
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

                                      _fetchedAttendance =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              activityId,
                                              10000);
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
                                      setState(() {
                                        _data = MyData(
                                            _fetchedAttendance,
                                            columnNames,
                                            _fetchedOrganization,
                                            updateSelected);
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
                          showCheckboxColumn: false,
                          source: _data,
                          columns: cols,
                          // header: const Center(child: Text('Daily Attendance')),
                          columnSpacing: 100,
                          horizontalMargin: 60,
                          rowsPerPage: 25,
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
