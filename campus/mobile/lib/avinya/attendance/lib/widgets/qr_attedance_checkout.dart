// ignore_for_file: non_constant_identifier_names, unused_element, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile/avinya/attendance/lib/data/attendance_data.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
// import 'package:attendance/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/evaluation_list.dart';
import 'package:mobile/avinya/attendance/lib/widgets/qr_image.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrAttendanceCheckOut extends StatefulWidget {
  @override
  _QrAttendanceCheckOutState createState() => _QrAttendanceCheckOutState();
}

class _QrAttendanceCheckOutState extends State<QrAttendanceCheckOut> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isAbsent = false;
  bool markedAttendance = false;
  bool inValidQr = false;
  bool isFirstTime = true;
  bool isFetching = false;
  List<ActivityAttendance> _personAttendanceToday = [];
  List<Evaluation> _fechedEvaluations = [];

  String sign_in_time = "ee";
  Timer? _debounceTimer;
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
        if (!isFetching) {
          setState(() {
            qrCodeData = deserializedQrCodeData;
            inValidQr = false;
            isFetching = true;
          });
          if (qrCodeData.person_id != 0) _performCheckOut();
        }
      } catch (e) {
        setState(() {
          inValidQr = true;
        });
      }
    });
  }

  Future<void> _performCheckOut() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      // If a timer is already active, cancel it to reset the debounce period
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _handleCheckOut();
    });
  }

  Future<void> _handleCheckOut() async {
    var activityInstance =
        await campusAttendanceSystemInstance.getCheckinActivityInstance(
            campusAppsPortalInstance.activityIds['homeroom']);

    _personAttendanceToday = await getPersonActivityAttendanceToday(
        qrCodeData.person_id!,
        campusAppsPortalInstance.activityIds['homeroom']!);

    // Get the current date and time
    DateTime today = DateTime.now();

// Format the date as a string
    String dateOnlyString = DateFormat('yyyy-MM-dd').format(today);
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    if (qrCodeData.sign_out_time != '') {
      DateTime dateTime = DateTime.parse(qrCodeData.sign_out_time);
      dateOnlyString = DateFormat('yyyy-MM-dd').format(dateTime);
    } else {
      dateOnlyString = '';
    }
    if (_personAttendanceToday.length == 1 &&
        qrCodeData.sign_out_time != '' &&
        dateOnlyString == formattedDate) {
      setState(() {
        isFirstTime = true;
        isFetching = false;
      });
      // call the API to check-out
      await createActivityAttendance(ActivityAttendance(
        activity_instance_id: activityInstance.id,
        person_id: qrCodeData.person_id,
        sign_out_time: DateTime.now().toString(),
        out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      ));
      // await refreshPersonActivityAttendanceToday();
      setState(() {
        markedAttendance = true;
        isFirstTime = false;
        isFetching = false;
      });
    } else {
      setState(() {
        markedAttendance = true;
        isFirstTime = false;
        isFetching = false;
      });
    }

    await refreshPersonActivityAttendanceToday();

    print('Checked in for today.');
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
          // Get the current date and time
          DateTime today = DateTime.now();

// Format the date as a string
          String dateOnlyString = DateFormat('yyyy-MM-dd').format(today);
          String formattedDate = DateFormat('yyyy-MM-dd').format(today);
          if (qrCodeData.sign_out_time != '') {
            DateTime dateTime = DateTime.parse(qrCodeData.sign_out_time);
            dateOnlyString = DateFormat('yyyy-MM-dd').format(dateTime);
          } else {
            dateOnlyString = '';
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                  'Check-Out by (QR)'), // Customize your app title here
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
                    if (isFetching)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: const SpinKitCircle(
                          color: (Colors
                              .blue), // Customize the color of the indicator
                          size: 50, // Customize the size of the indicator
                        ),
                      ),
                    if (!inValidQr) ...[
                      if (qrCodeData.preferred_name != '' &&
                          qrCodeData.sign_out_time != '' &&
                          markedAttendance) ...[
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15), // Add padding
                              color: Colors.lightBlue, // Add a background color
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Name: ${qrCodeData.preferred_name}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Change text color to contrast with background
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Class: ${qrCodeData.organization}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Check-Out Time: ${DateFormat('MMM d, y, h:mm a').format(DateTime.parse(qrCodeData.sign_out_time))}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (markedAttendance)
                              if (dateOnlyString == formattedDate) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  color: Colors.green,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 32.0,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Check-Out completed successfully!',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  color: Colors.red,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 32.0,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Check-Out failed!',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                          ],
                        ),
                      ],
                      ...[
                        if (qrCodeData.person_id == 0 && isFirstTime)
                          Container(
                            width: double.infinity,
                            color: Colors.blue,
                            padding: const EdgeInsets.all(16.0),
                            child: const Center(
                              child: Text(
                                'Scan QR Code to Mark Attendance',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                      ],
                    ] else ...[
                      Container(
                        width: double.infinity,
                        color: Colors.red,
                        padding: const EdgeInsets.all(16.0),
                        child: const Center(
                          child: Text(
                            'Invalid QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
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
