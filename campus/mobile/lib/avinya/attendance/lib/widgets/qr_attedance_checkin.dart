// ignore_for_file: non_constant_identifier_names, unused_element, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/avinya/attendance/lib/data/attendance_data.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
// import 'package:attendance/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/qr_image.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrAttendanceCheckIn extends StatefulWidget {
  @override
  _QrAttendanceCheckInState createState() => _QrAttendanceCheckInState();
}

class _QrAttendanceCheckInState extends State<QrAttendanceCheckIn> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isAbsent = false;
  bool markedAttendance = false;
  bool inValidQr = false;
  bool isFirstTime = true;
  List<ActivityAttendance> _personAttendanceToday = [];
  List<Evaluation> _fechedEvaluations = [];

  String sign_in_time = "ee";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  AttendanceData qrCodeData = AttendanceData(
    activity_instance_id: 0,
    person_id: 0,
    preferred_name: '',
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
        if (qrCodeData.person_id != 0) {
          _handleCheckIn();
        }
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
    } else {
      setState(() {
        markedAttendance = true;
        isFirstTime = false;
      });
    }

    await refreshPersonActivityAttendanceToday();
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
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                  'Check-In by (QR)'), // Customize your app title here
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!inValidQr) ...[
                      // if (!isFirstTime) ...[
                      //   Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //           'Checked in for today at ${_personAttendanceToday[0].sign_in_time!}'),
                      //       const SizedBox(width: 20),
                      //     ],
                      //   ),
                      // ]
                      if (qrCodeData.person_id != 0) ...[
                        Column(
                          children: [
                            // Text(
                            //   'QR Code Data:',
                            //   style: TextStyle(
                            //       fontSize: 18, fontWeight: FontWeight.bold),
                            // ),
                            // Text(
                            //   'Person ID: ${qrCodeData.person_id}',
                            //   style: const TextStyle(fontSize: 18),
                            // ),
                            Text(
                              'Student Name: ${qrCodeData.preferred_name}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Check-In Time: ${qrCodeData.sign_in_time}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            if (markedAttendance) const SizedBox(height: 20),
                            const Text(
                              'Check-In completed successfully!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // if (_isCheckedOut && _isCheckedIn) ...[
                      //   Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       const Text('Attendance Marked for Today.'),
                      //       if (_personAttendanceToday.isNotEmpty)
                      //         Text(
                      //             'Checked in at ${_personAttendanceToday[0].sign_in_time!}'),
                      //       if (_personAttendanceToday.length > 1)
                      //         Text(
                      //             'Checked out at ${_personAttendanceToday[1].sign_out_time!}'),
                      //       const SizedBox(width: 20),
                      //     ],
                      //   ),
                      // ],
                      ...[
                        if (qrCodeData.person_id == 0 && isFirstTime)
                          const Text(
                            'Scan QR Code to Mark Attendance',
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ] else ...[
                      const Text(
                        'Invalid QR Code',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
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
