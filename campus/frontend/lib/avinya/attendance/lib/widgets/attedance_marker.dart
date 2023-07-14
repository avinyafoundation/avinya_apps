import 'package:flutter/material.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
// import 'package:attendance/widgets/evaluation_list.dart';
import 'package:gallery/avinya/attendance/lib/widgets/evaluation_list.dart';

class AttendanceMarker extends StatefulWidget {
  @override
  _AttendanceMarkerState createState() => _AttendanceMarkerState();
}

class _AttendanceMarkerState extends State<AttendanceMarker> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isAbsent = false;
  List<ActivityAttendance> _personAttendanceToday = [];
  List<Evaluation> _fechedEvaluations = [];

  Future<void> _handleCheckIn() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    // call the API to check-in
    await createActivityAttendance(ActivityAttendance(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      sign_in_time: DateTime.now().toString(),
      in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    ));
    await refreshPersonActivityAttendanceToday();
    setState(() {
      //_isCheckedIn = true;
    });
    print('Checked in for today.');
  }

  Future<void> _handleCheckOut() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckoutActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    // call the API to check-out
    await createActivityAttendance(ActivityAttendance(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      sign_out_time: DateTime.now().toString(),
      out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    ));
    await refreshPersonActivityAttendanceToday();
    setState(() {
      //_isCheckedOut = true;
    });
    print('Checked out for today.');
  }

  Future<List<ActivityAttendance>>
      refreshPersonActivityAttendanceToday() async {
    _personAttendanceToday = await getPersonActivityAttendanceToday(
        campusAppsPortalInstance.getUserPerson().id!,
        campusAppsPortalInstance.activityIds['school-day']!);
    if (_personAttendanceToday.length > 0) {
      _isCheckedIn = _personAttendanceToday[0].sign_in_time != null;
    }
    if (_personAttendanceToday.length > 1) {
      _isCheckedOut = _personAttendanceToday[1].sign_out_time != null;
    }

    if (!_isCheckedIn) {
      var activityInstance =
          await campusAttendanceSystemInstance.getCheckinActivityInstance(
              campusAppsPortalInstance.activityIds['school-day']!);
      _fechedEvaluations =
          await getActivityInstanceEvaluations(activityInstance.id!);

      if (_fechedEvaluations.indexWhere((element) =>
              element.evaluator_id ==
              campusAppsPortalInstance.getUserPerson().id!) ==
          -1) {
        _isCheckedIn = false;
      } else {
        _isCheckedIn = true;
        _isCheckedOut = true;
        _isAbsent = true;
      }
    }

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
          return SingleChildScrollView(
              child: Column(
            children: [
              if (!_isCheckedIn)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    child: Text('Check-In'),
                    onPressed: _handleCheckIn,
                    style: ButtonStyle(
                      // increase the fontSize
                      textStyle: MaterialStateProperty.all(
                        TextStyle(fontSize: 20),
                      ),
                      elevation: MaterialStateProperty.all(
                          20), // increase the elevation
                      // Add outline around button
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    child: Text('Absent'),
                    onPressed: () async {
                      var activityInstance =
                          await campusAttendanceSystemInstance
                              .getCheckinActivityInstance(
                                  campusAppsPortalInstance
                                      .activityIds['school-day']!);
                      var evaluation = Evaluation(
                        evaluator_id:
                            campusAppsPortalInstance.getUserPerson().id,
                        evaluatee_id:
                            campusAppsPortalInstance.getUserPerson().id,
                        activity_instance_id: activityInstance.id,
                        grade: 0,
                        evaluation_criteria_id: 54,
                        response: "Unexcused absence",
                      );
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEvaluationPage(
                                  evaluation: evaluation,
                                )),
                      );
                      if (result != null) {
                        await refreshPersonActivityAttendanceToday();
                        setState(() {});
                      }
                      // _fetchedEvaluations =
                      //             await getActivityInstanceEvaluations(
                      //                             activityInstance.id!);
                      //             setState(() {});
                    },
                    style: ButtonStyle(
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 20)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ]),
              if (_isCheckedOut && !_isAbsent)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Attendance marked for today.'),
                    if (_personAttendanceToday.length > 0)
                      Text('Checked in at ' +
                          _personAttendanceToday[0].sign_in_time!),
                    if (_personAttendanceToday.length > 1)
                      Text('Checked out at ' +
                          _personAttendanceToday[1].sign_out_time!),
                    SizedBox(width: 20),
                  ],
                )
              else if (_isAbsent)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Attendance marked as Absent today.')],
                )
              else if (_isCheckedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_personAttendanceToday.length > 0)
                      Text('Checked in for today at ' +
                          _personAttendanceToday[0].sign_in_time!),
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
          ));
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
