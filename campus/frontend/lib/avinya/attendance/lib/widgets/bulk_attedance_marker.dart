import 'dart:html';

import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';
import 'package:gallery/data/campus_apps_portal.dart';
// import '../data.dart';
// import '../data/activity_attendance.dart';

// class BulkAttendanceMarker extends StatefulWidget {
//   @override
//   _BulkAttendanceMarkerState createState() => _BulkAttendanceMarkerState();
// }

// class _BulkAttendanceMarkerState extends State<BulkAttendanceMarker> {
//   bool _isCheckedIn = false;
//   bool _isCheckedOut = false;

//   void _handleCheckIn() {
//     // call the API to check-in
//     createActivityAttendance(ActivityAttendance(
//       activity_instance_id:
//           campusAttendanceSystemInstance.getCheckinActivityInstance().id,
//       person_id: campusAppsPortalInstance.getUserPerson().id,
//       sign_in_time: DateTime.now().toString(),
//     ));
//     setState(() {
//       _isCheckedIn = true;
//     });
//     print('Checked in for today.');
//   }

//   void _handleCheckOut() {
//     // call the API to check-out
//     createActivityAttendance(ActivityAttendance(
//       activity_instance_id:
//           campusAttendanceSystemInstance.getCheckoutActivityInstance().id,
//       person_id: campusAppsPortalInstance.getUserPerson().id,
//       sign_out_time: DateTime.now().toString(),
//     ));
//     setState(() {
//       _isCheckedOut = true;
//     });
//     print('Checked out for today.');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (!_isCheckedIn)
//           ElevatedButton(
//             child: Text('Check-In'),
//             onPressed: _handleCheckIn,
//             style: ButtonStyle(
//               // increase the fontSize
//               textStyle: MaterialStateProperty.all(
//                 TextStyle(fontSize: 20),
//               ),
//               elevation:
//                   MaterialStateProperty.all(20), // increase the elevation
//               // Add outline around button
//               backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
//               foregroundColor: MaterialStateProperty.all(Colors.black),
//             ),
//           )
//         else if (_isCheckedIn && !_isCheckedOut)
//           ElevatedButton(
//             child: Text('Check-Out'),
//             onPressed: _handleCheckOut,
//             style: ButtonStyle(
//               // increase the fontSize
//               textStyle: MaterialStateProperty.all(
//                 TextStyle(fontSize: 20),
//               ),
//               elevation:
//                   MaterialStateProperty.all(20), // increase the elevation
//               // Add outline around button
//               backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
//               foregroundColor: MaterialStateProperty.all(Colors.black),
//             ),
//           )
//         else if (_isCheckedOut)
//           Text('Attendance marked for today.'),
//       ],
//     );
//   }
// }

class BulkAttendanceMarker extends StatefulWidget {
  const BulkAttendanceMarker({super.key});
  @override
  _BulkAttendanceMarkerState createState() => _BulkAttendanceMarkerState();
}

class _BulkAttendanceMarkerState extends State<BulkAttendanceMarker> {
  List<String> classes = [
    "Class A",
    "Class B",
    "Class C",
  ];

  List<String> students = [
    "Alice",
    "Bob",
    "Charlie",
    "Dave",
    "Eve",
    "Frank",
    "Grace",
    "Henry",
    "Ivy",
    "Jane",
  ];

  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  Organization? _fetchedOrganization;
  List<ActivityAttendance> _fetchedAttendance = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < classes.length; i++) {
      attendanceList.add({});
      for (int j = 0; j < students.length; j++) {
        attendanceList[i][students[j]] = false;
      }
    }
  }

  void toggleAttendance(String? className, String? studentName) {
    int classIndex = classes.indexOf(className!);
    setState(() {
      attendanceList[classIndex][studentName!] =
          !attendanceList[classIndex][studentName]!;
    });
  }

  // get the state of attenance for the set of students in a given class
  // void getAttendance(int classId) {
  //   int activityId = 0;
  //   if (campusAppsPortalInstance.isTeacher)
  //     activityId = campusAppsPortalInstance.activityIds['homeroom']!;
  //   else if (campusAppsPortalInstance.isSecurity)
  //     activityId = campusAppsPortalInstance.activityIds['arrival']!;
  //   // fetch attendance data for the given class
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              // Text(org.name!.name_en == null
                              //     ? 'N/A'
                              //     : org.name!.name_en!),
                              // Row(
                              //   children: <Widget>[
                              //     for (var suborg in org.child_organizations)
                              //       Text(suborg.description == null
                              //           ? 'N/A'
                              //           : suborg.description!),
                              //   ],
                              // ),

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
                                      var activityId = 0;
                                      if (campusAppsPortalInstance.isTeacher)
                                        activityId = campusAppsPortalInstance
                                            .activityIds['homeroom']!;
                                      else if (campusAppsPortalInstance
                                          .isSecurity)
                                        activityId = campusAppsPortalInstance
                                            .activityIds['arrival']!;
                                      _fetchedAttendance =
                                          await getClassActivityAttendanceToday(
                                              _fetchedOrganization!.id!,
                                              activityId);
                                      setState(() {});
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
                  Text(
                      campusAppsPortalInstance.activityIds['school-day']
                          .toString(),
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  Text(campusAppsPortalInstance.getUserPerson().preferred_name!,
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  Text(
                    "Classes",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Wrap(
                    spacing: 16.0,
                    children: classes
                        .map((className) => ChoiceChip(
                              label: Text(className),
                              selected: classes.indexOf(className) == 0,
                              onSelected: (bool selected) {},
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 32.0),
                  Text(
                    "Students",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      // TableRow(children: [
                      //   TableCell(child: Text("Name")),
                      //   ...classes
                      //       .map((className) =>
                      //           TableCell(child: Text(className)))
                      //       .toList()
                      // ]),
                      // ...students.map((studentName) {
                      //   return TableRow(children: [
                      //     TableCell(child: Text(studentName)),
                      //     ...classes
                      //         .map((className) => TableCell(
                      //               child: Checkbox(
                      //                 value: attendanceList[classes
                      //                     .indexOf(className)][studentName],
                      //                 onChanged: (bool? value) {
                      //                   toggleAttendance(
                      //                       className, studentName);
                      //                 },
                      //               ),
                      //             ))
                      //         .toList()
                      //   ]);
                      // }).toList(),
                      if (_fetchedOrganization != null)
                        if (_fetchedOrganization!.people.length > 0)
                          ..._fetchedOrganization!.people.map((person) {
                            return TableRow(children: [
                              TableCell(child: Text(person.preferred_name!)),
                              TableCell(child: Text(person.digital_id!)),

                              if (_fetchedAttendance.length > 0)
                                TableCell(
                                  child: Checkbox(
                                    value: _fetchedAttendance
                                            .firstWhere((attendance) =>
                                                attendance.person_id ==
                                                person.id)
                                            .sign_in_time !=
                                        null,
                                    onChanged: (bool? value) {},
                                  ),
                                )
                              else
                                TableCell(
                                  child: Checkbox(
                                    value: false,
                                    onChanged: (bool? value) {},
                                  ),
                                ),

                              // ...classes
                              //     .map((className) => TableCell(
                              //           child: Checkbox(
                              //             value: attendanceList[classes
                              //                 .indexOf(className)][studentName],
                              //             onChanged: (bool? value) {
                              //               toggleAttendance(
                              //                   className, studentName);
                              //             },
                              //           ),
                              //         ))
                              //     .toList()
                            ]);
                          }).toList()
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
