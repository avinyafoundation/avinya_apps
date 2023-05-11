// AttendanceMarker screen class

import 'package:attendance/widgets/attedance_marker.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/evaluation.dart';
import 'package:attendance/data/activity_instance.dart';
import 'package:attendance/data/campus_attendance_system.dart';
import 'package:attendance/widgets/student_evaluation.dart';
import 'package:gallery/data/campus_apps_portal.dart';

import '../widgets/person_attendance_report.dart';

class AttendanceMarkerScreen extends StatefulWidget {
  const AttendanceMarkerScreen({Key? key}) : super(key: key);

  @override
  _AttendanceMarkerScreenState createState() => _AttendanceMarkerScreenState();
}

class _AttendanceMarkerScreenState extends State<AttendanceMarkerScreen> {

var activityId = 0;
var activityInstance = ActivityInstance(id: -1);
 List<Evaluation> _fetchedEvaluations = [];

  @override
  void initState() {
    super.initState();

     if (campusAppsPortalInstance.isStudent) {
      activityId = campusAppsPortalInstance.activityIds['school-day']!;

     }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Attendance Marker'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                AttendanceMarker(),
                SizedBox(height: 20),
                 ElevatedButton(
                  child: Text('Absent'),
                  onPressed: () async{  
                        if (activityInstance.id == -1) {
                                            activityInstance =
                                                await campusAttendanceSystemInstance
                                                    .getCheckinActivityInstance(
                                                        activityId);
                        }
                      var evaluation = Evaluation(
                        evaluator_id: campusAppsPortalInstance
                                         .getUserPerson()
                                         .id,
                        evaluatee_id:  campusAppsPortalInstance
                                         .getUserPerson()
                                         .id,
                        activity_instance_id: activityInstance.id,
                        grade: 0,
                        evaluation_criteria_id: 54,
                        response:  "Unexcused absence",
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=>
                           AddStudentEvaluationPage(
                            evaluation: evaluation,
                            )),
                      );
                        // _fetchedEvaluations =
                        //             await getActivityInstanceEvaluations(
                        //                             activityInstance.id!);
                        //             setState(() {});
                  },
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20)),
                    backgroundColor:MaterialStateProperty.all<Color>(Colors.blue) ,
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),               
                  ),
                SizedBox(height: 10),
                Text('Person Attendance Report'),
                SizedBox(height: 5),
                Container(
                  width: 500,
                  height: 500,
                  child: PersonAttendanceMarkerReport(),
                )
              ],
            ),
          ),
        ),
      );
}
