// ignore_for_file: non_constant_identifier_names, unused_element, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/avinya/attendance/lib/data/attendance_data.dart';
import 'package:mobile/avinya/attendance/lib/widgets/qr_attedance_checkin.dart';
import 'package:mobile/avinya/attendance/lib/widgets/qr_attedance_checkout.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrAttendanceMarker extends StatefulWidget {
  @override
  _QrAttendanceMarkerState createState() => _QrAttendanceMarkerState();
}

class _QrAttendanceMarkerState extends State<QrAttendanceMarker> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isAbsent = false;
  bool markedAttendance = true;
  bool inValidQr = false;
  List<ActivityAttendance> _personAttendanceToday = [];
  List<Evaluation> _fechedEvaluations = [];

  String sign_in_time = "ee";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  AttendanceData qrCodeData = AttendanceData(
    activity_instance_id: 0,
    person_id: 0,
    preferred_name: '',
    organization: '',
    sign_in_time: '',
    sign_out_time: '',
    in_marked_by: '',
  );
  var activityId = 0;
  var afterSchoolActivityId = 0;
  @override
  void initState() {
    super.initState();
    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
    afterSchoolActivityId =
        campusAppsPortalInstance.activityIds['after-school']!;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      try {
        AttendanceData deserializedQrCodeData =
            AttendanceData.fromJson(jsonDecode(scanData.code!));

        setState(() {
          qrCodeData = deserializedQrCodeData;
          inValidQr = false;
        });
      } catch (e) {
        setState(() {
          inValidQr = true;
        });
      }
    });
  }

  Future<void> _handleCheckIn() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['homeroom']);

    _personAttendanceToday = await getPersonActivityAttendanceToday(
        qrCodeData.person_id!,
        campusAppsPortalInstance.activityIds['homeroom']!);
    if (_personAttendanceToday.isEmpty) {
      // call the API to check-in
      await createActivityAttendance(ActivityAttendance(
        activity_instance_id: activityInstance.id,
        person_id: qrCodeData.person_id,
        sign_in_time: DateTime.now().toString(),
        in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      ));
    }

    await refreshPersonActivityAttendanceToday();
    setState(() {
      markedAttendance = true;
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
        qrCodeData.person_id!,
        campusAppsPortalInstance.activityIds['homeroom']!);
    if (_personAttendanceToday.isNotEmpty) {
      _isCheckedIn = _personAttendanceToday[0].sign_in_time != null;
    }
    if (_personAttendanceToday.length > 1) {
      _isCheckedOut = _personAttendanceToday[1].sign_out_time != null;
    }

    // if (!_isCheckedIn) {
    //   var activityInstance =
    //       await campusAttendanceSystemInstance.getCheckinActivityInstance(
    //           campusAppsPortalInstance.activityIds['homeroom']!);
    //   _fechedEvaluations =
    //       await getActivityInstanceEvaluations(activityInstance.id!);

    //   if (_fechedEvaluations.indexWhere((element) =>
    //           element.evaluator_id ==
    //           qrCodeData.person_id!) ==
    //       -1) {
    //     _isCheckedIn = false;
    //   } else {
    //     _isCheckedIn = true;
    //     _isCheckedOut = true;
    //     _isAbsent = true;
    //   }
    // }

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QrAttendanceCheckIn()),
                        );
                      },
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
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      child: const Text('Check-In'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QrAttendanceCheckOut()),
                        );
                      },
                      style: ButtonStyle(
                        // increase the fontSize
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 20),
                        ),
                        elevation: MaterialStateProperty.all(
                            20), // increase the elevation
                        // Add outline around button
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurpleAccent),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      child: const Text('Check-Out'),
                    ),
                  ),
                ]),
              ],
            ),
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
