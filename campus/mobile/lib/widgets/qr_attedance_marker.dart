import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../data/activity_attendance.dart';
import 'package:mobile/data/evaluation.dart';
// import 'package:attendance/widgets/evaluation_list.dart';
import 'package:mobile/widgets/evaluation_list.dart';
import 'package:mobile/widgets/qr_image.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrAttendanceMarker extends StatefulWidget {
  @override
  _QrAttendanceMarkerState createState() => _QrAttendanceMarkerState();
}

class _QrAttendanceMarkerState extends State<QrAttendanceMarker> {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isAbsent = false;
  List<ActivityAttendance> _personAttendanceToday = [];
  List<Evaluation> _fechedEvaluations = [];

  String sign_in_time = "ee";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrCodeData = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeData = scanData.code!;
      });
    });
  }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) {
          return QRImage(sign_in_time);
        }),
      ),
    );
    setState(() {
      qrCodeData = sign_in_time;
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
                  // ElevatedButton(
                  //   child: Text('Check-In'),
                  //   onPressed: _handleCheckIn,
                  //   style: ButtonStyle(
                  //     // increase the fontSize
                  //     textStyle: MaterialStateProperty.all(
                  //       TextStyle(fontSize: 20),
                  //     ),
                  //     elevation: MaterialStateProperty.all(
                  //         20), // increase the elevation
                  //     // Add outline around button
                  //     backgroundColor:
                  //         MaterialStateProperty.all(Colors.greenAccent),
                  //     foregroundColor: MaterialStateProperty.all(Colors.black),
                  //   ),
                  // ),
                  Expanded(
                    flex: 5,
                    child:
                        QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Text(
                        'Scan Result: $qrCodeData',
                        style: TextStyle(fontSize: 18),
                      ))),
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                if (qrCodeData.isNotEmpty) {
                                  Clipboard.setData(
                                      ClipboardData(text: qrCodeData));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Copied to Clipboard')));
                                  // _handleCheckIn();
                                }
                              },
                              child: Text('Copy')),
                        ],
                      )),
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
                    IconButton(
                      icon: Icon(Icons.qr_code),
                      onPressed: () {
                        // Navigate to the QR code view screen when the button is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return QRImage(qrCodeData);
                            },
                          ),
                        );
                      },
                      tooltip: 'View QR Code',
                    ),
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
