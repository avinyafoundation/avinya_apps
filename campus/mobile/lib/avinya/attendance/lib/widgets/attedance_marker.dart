// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/avinya/attendance/lib/data/attendance_data.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
// import 'package:attendance/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/qr_image.dart';
import 'dart:convert';

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

  String sign_in_time = "ee";
  String qrCodeData = "";

  Future<void> _handleCheckIn() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);

    final AttendanceData data = AttendanceData(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      preferred_name: campusAppsPortalInstance.getUserPerson().preferred_name,
      organization:
          campusAppsPortalInstance.getUserPerson().organization!.description,
      sign_in_time: DateTime.now().toString(),
      sign_out_time: '',
      in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    );
    // call the API to check-in
    await createActivityAttendance(ActivityAttendance(
      activity_instance_id: data.activity_instance_id,
      person_id: data.person_id,
      sign_in_time: data.sign_in_time,
      in_marked_by: data.in_marked_by,
    ));
    String dataJson = jsonEncode(data);
    await refreshPersonActivityAttendanceToday();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) {
          return QRImage(dataJson);
        }),
      ),
    );
    setState(() {
      qrCodeData = dataJson;
    });
    print('Checked in for today.');
  }

  Future<void> _handleQr() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    _personAttendanceToday = await getPersonActivityAttendanceToday(
        campusAppsPortalInstance.getUserPerson().id!,
        campusAppsPortalInstance.activityIds['school-day']!);

    final AttendanceData data;
    if (_personAttendanceToday.length == 1) {
      data = AttendanceData(
        activity_instance_id: activityInstance.id,
        person_id: campusAppsPortalInstance.getUserPerson().id,
        preferred_name: campusAppsPortalInstance.getUserPerson().preferred_name,
        organization:
            campusAppsPortalInstance.getUserPerson().organization!.description,
        sign_in_time: _personAttendanceToday[0].sign_in_time.toString(),
        sign_out_time: '',
        in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      );
    } else {
      data = AttendanceData(
        activity_instance_id: activityInstance.id,
        person_id: campusAppsPortalInstance.getUserPerson().id,
        preferred_name: campusAppsPortalInstance.getUserPerson().preferred_name,
        organization:
            campusAppsPortalInstance.getUserPerson().organization!.description,
        sign_in_time: _personAttendanceToday[0].sign_in_time.toString(),
        sign_out_time: _personAttendanceToday[1].sign_out_time.toString(),
        in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      );
    }

    String dataJson = jsonEncode(data);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) {
          return QRImage(dataJson);
        }),
      ),
    );
    setState(() {
      qrCodeData = dataJson;
    });
    print('Checked in for today.');
  }

  Future<void> _handleCheckOut() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckoutActivityInstance(
            campusAppsPortalInstance.activityIds['school-day']);
    final AttendanceData data = AttendanceData(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      preferred_name: campusAppsPortalInstance.getUserPerson().preferred_name,
      organization:
          campusAppsPortalInstance.getUserPerson().organization!.description,
      sign_in_time: '',
      sign_out_time: DateTime.now().toString(),
      in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    );
    // call the API to check-out
    await createActivityAttendance(ActivityAttendance(
      activity_instance_id: activityInstance.id,
      person_id: campusAppsPortalInstance.getUserPerson().id,
      sign_out_time: DateTime.now().toString(),
      out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
    ));
    String dataJson = jsonEncode(data);
    await refreshPersonActivityAttendanceToday();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) {
          return QRImage(dataJson);
        }),
      ),
    );
    setState(() {
      qrCodeData = dataJson;
    });
    // setState(() {
    //   //_isCheckedOut = true;
    // });
    print('Checked out for today.');
  }

  Future<List<ActivityAttendance>>
      refreshPersonActivityAttendanceToday() async {
    _personAttendanceToday = await getPersonActivityAttendanceToday(
        campusAppsPortalInstance.getUserPerson().id!,
        campusAppsPortalInstance.activityIds['school-day']!);
    if (_personAttendanceToday.isNotEmpty) {
      _isCheckedIn = _personAttendanceToday[0].sign_in_time != null;
    }
    if (_personAttendanceToday.length > 1) {
      _isCheckedOut = _personAttendanceToday[1].sign_out_time != null;
    }

    if (!_isCheckedIn) {
      // var activityInstance =
      //     await campusAttendanceSystemInstance.getCheckinActivityInstance(
      //         campusAppsPortalInstance.activityIds['school-day']!);
      var activityInstanceForAbsent =
          await campusAttendanceSystemInstance.getCheckinActivityInstance(
              campusAppsPortalInstance.activityIds['homeroom']!);
      _fechedEvaluations =
          await getActivityInstanceEvaluations(activityInstanceForAbsent.id!);

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
          if (snapshot.data!.isNotEmpty) {
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
                    onPressed: _handleCheckIn,
                    style: ButtonStyle(
                      // increase the fontSize
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 20),
                      ),
                      elevation: MaterialStateProperty.all(
                          20), // increase the elevation
                      // Add outline around button
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: const Text('Check-In'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
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
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 20)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('Absent'),
                  ),
                ]),
              if (_isCheckedOut && !_isAbsent)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Attendance marked for today.'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_personAttendanceToday.isNotEmpty)
                          Text(
                              'Checked in at ${_personAttendanceToday[0].sign_in_time!}'),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.qr_code),
                          onPressed: () {
                            // Navigate to the QR code view screen when the button is clicked
                            _handleQr();
                          },
                          tooltip: 'View QR Code',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_personAttendanceToday.length > 1)
                          Text(
                              'Checked out at ${_personAttendanceToday[1].sign_out_time!}'),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.qr_code),
                          onPressed: () {
                            // Navigate to the QR code view screen when the button is clicked
                            _handleQr();
                          },
                          tooltip: 'View QR Code',
                        ),
                      ],
                    ),
                  ],
                )
              else if (_isAbsent)
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Attendance marked as Absent today.')],
                )
              else if (_isCheckedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_personAttendanceToday.isNotEmpty)
                      Text(
                          'Checked in for today at ${_personAttendanceToday[0].sign_in_time!}'),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () {
                        // Navigate to the QR code view screen when the button is clicked
                        _handleQr();
                      },
                      tooltip: 'View QR Code',
                    ),
                  ],
                ),
              if (_isCheckedIn && !_isCheckedOut)
                ElevatedButton(
                  onPressed: _handleCheckOut,
                  style: ButtonStyle(
                    // increase the fontSize
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(fontSize: 20),
                    ),
                    elevation:
                        MaterialStateProperty.all(20), // increase the elevation
                    // Add outline around button
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orangeAccent),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: const Text('Check-Out'),
                ),
            ],
          ));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return  Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SpinKitCircle(
                          color: (Colors.deepPurpleAccent), // Customize the color of the indicator
                          size: 70, // Customize the size of the indicator
                        ),
            );
      },
    );
    //
  }
}
