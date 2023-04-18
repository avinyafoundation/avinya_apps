import 'package:flutter/material.dart';
import '../data.dart';
import '../data/activity_attendance.dart';

class AttendanceMarker extends StatefulWidget {
  @override
  _AttendanceMarkerState createState() => _AttendanceMarkerState();
}

class _AttendanceMarkerState extends State<AttendanceMarker> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  List<ActivityAttendance> _personAttendanceToday = [];

  Future<void> _handleCheckIn() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    // call the API to check-in
    createActivityAttendance(ActivityAttendance(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      sign_in_time: DateTime.now().toString(),
      in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    ));
    setState(() {
      _isCheckedIn = true;
    });
    print('Checked in for today.');
  }

  Future<void> _handleCheckOut() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckoutActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    // call the API to check-out
    createActivityAttendance(ActivityAttendance(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      sign_out_time: DateTime.now().toString(),
      out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    ));
    setState(() {
      _isCheckedOut = true;
    });
    print('Checked out for today.');
  }

  Future<List<ActivityAttendance>>
      refreshPersonActivityAttendanceToday() async {
    _personAttendanceToday = await getPersonActivityAttendanceToday(
        campusAppsPortalInstance.getUserPerson().id!,
        campusAppsPortalInstance.activityIds['school-day']!);

    return _personAttendanceToday;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityAttendance>>(
      future: refreshPersonActivityAttendanceToday(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length > 0) {
            _isCheckedIn = snapshot.data![0].sign_in_time != null;
          }
          if (snapshot.data!.length > 1) {
            _isCheckedOut = snapshot.data![1].sign_out_time != null;
          }
          return Column(
            children: [
              if (!_isCheckedIn)
                ElevatedButton(
                  child: Text('Check-In'),
                  onPressed: _handleCheckIn,
                  style: ButtonStyle(
                    // increase the fontSize
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 20),
                    ),
                    elevation:
                        MaterialStateProperty.all(20), // increase the elevation
                    // Add outline around button
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              if (_isCheckedOut)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Attendance marked for today.'),
                    Text('Checked in at ' + snapshot.data![0].sign_in_time!),
                    Text('Checked out at ' + snapshot.data![1].sign_out_time!),
                    SizedBox(width: 20),
                  ],
                )
              else if (_isCheckedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Checked in for today at ' +
                        snapshot.data![0].sign_in_time!),
                    SizedBox(width: 20),
                  ],
                ),
              if (_isCheckedIn && !_isCheckedOut)
                ElevatedButton(
                  child: Text('Check-Out'),
                  onPressed: _handleCheckOut,
                  style: ButtonStyle(
                    // increase the fontSize
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 20),
                    ),
                    elevation:
                        MaterialStateProperty.all(20), // increase the elevation
                    // Add outline around button
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orangeAccent),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
    //
  }
}
