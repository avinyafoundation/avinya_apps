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

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
          )
        else if (_isCheckedIn && !_isCheckedOut)
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
              backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
          )
        else if (_isCheckedOut)
          Text('Attendance marked for today.'),
      ],
    );
  }
}
