import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Classes",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  TableCell(child: Text("Name")),
                  ...classes
                      .map((className) => TableCell(child: Text(className)))
                      .toList()
                ]),
                ...students.map((studentName) {
                  return TableRow(children: [
                    TableCell(child: Text(studentName)),
                    ...classes
                        .map((className) => TableCell(
                              child: Checkbox(
                                value:
                                    attendanceList[classes.indexOf(className)]
                                        [studentName],
                                onChanged: (bool? value) {
                                  toggleAttendance(className, studentName);
                                },
                              ),
                            ))
                        .toList()
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
