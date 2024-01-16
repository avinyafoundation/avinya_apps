import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/attendance/lib/screens/attendance_marker.dart';
import 'package:gallery/avinya/attendance/lib/screens/bulk_attendance_marker.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isAttendanceSectionHovered = false;
  bool isDutySectionHovered = false;
  bool isReportSectionHovered = false;
  bool isDashboardHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    List<Material> attendanceMarkerDestinations = [];
    List<Material> dutyDestinations = [];
    List<Material> reportDestinations = [];

    if (campusAppsPortalInstance.isTeacher ||
        campusAppsPortalInstance.isSecurity ||
        campusAppsPortalInstance.isFoundation) {
      attendanceMarkerDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.person_2_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Self Attendance Marker",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/attendance_marker');
              },
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading:
                  Icon(Icons.people_outline, color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Bulk Attendance Marker",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/bulk_attendance_marker/classes');
              },
            ),
          ),
        ),
      ];

      reportDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.summarize_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Daily Attendance Report",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/daily_attendance_report');
              },
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.watch_later_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Late Attendance Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/late_attendance_report');
              },
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading:
                  Icon(Icons.paid_outlined, color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Weekly Payment Report",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/weekly_payment_report');
              },
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.work_history_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Duty Attendance Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/daily_duty_attendance_report');
              },
            ),
          ),
        ),
      ];

      dutyDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.person_add_alt_1_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Assign duties",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/duty_participants');
              },
            ),
          ),
        ),
      ];
    } else if (campusAppsPortalInstance.isStudent &&
        (campusAppsPortalInstance.getLeaderParticipant().role == 'leader' ||
            campusAppsPortalInstance.getLeaderParticipant().role ==
                'assistant-leader')) {
      attendanceMarkerDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.person_2_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Self Attendance Marker",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/attendance_marker');
              },
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading:
                  Icon(Icons.people_outline, color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Duty Attendance Marker",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/duty_attendance_marker');
              },
            ),
          ),
        ),
      ];
    } else {
      attendanceMarkerDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.person_2_outlined,
                  color: Colors.white, size: 20.0),
              title: Container(
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Self Attendance Marker",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go('/attendance_marker');
              },
            ),
          ),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Campus Attendance Portal"),
        backgroundColor: Colors.deepPurpleAccent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              SMSAuthScope.of(context).signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Signed Out')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Help'),
                    ),
                    body: Align(
                      alignment: Alignment.center,
                      child: SelectableText.rich(TextSpan(
                        text:
                            "If you need help, write to us at admissions-help@avinyafoundation.org",
                        style: new TextStyle(color: Colors.deepPurpleAccent),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri(
                              scheme: 'mailto',
                              path: 'admissions-help@avinyafoundation.org',
                              query:
                                  'subject=Avinya Academy Admissions - Bandaragama&body=Question on my application', //add subject and body here
                            ));
                          },
                      )),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: 260.0,
        backgroundColor: Colors.deepPurpleAccent,
        child: SafeArea(
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isDashboardHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isDashboardHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDashboardHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.dashboard,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Attendance Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go('/attendance_dashboard');
                        },
                      ),
                    ),
                  ),
                  // ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isAttendanceSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAttendanceSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAttendanceSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                    backgroundColor: Colors.deepPurple.shade600,
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    title: Container(
                      transform: Matrix4.translationValues(-21, 0.0, 0.0),
                      child: Text(
                        "Attendance Marker",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    leading: Icon(
                      Icons.person_2_outlined,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    //childrenPadding: EdgeInsets.only(left: 25.0),
                    children: attendanceMarkerDestinations,
                  ),
                  //),
                ),
              ),
              if (campusAppsPortalInstance.isTeacher ||
                  campusAppsPortalInstance.isSecurity ||
                  campusAppsPortalInstance.isFoundation)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isDutySectionHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isDutySectionHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDutySectionHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                      backgroundColor: Colors.deepPurple.shade600,
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Container(
                        transform: Matrix4.translationValues(-21, 0.0, 0.0),
                        child: Text(
                          "Duty",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      leading: Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      //childrenPadding: EdgeInsets.only(left: 25.0),
                      children: dutyDestinations,
                    ),
                    // ),
                  ),
                ),
              if (campusAppsPortalInstance.isTeacher ||
                  campusAppsPortalInstance.isSecurity ||
                  campusAppsPortalInstance.isFoundation)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isReportSectionHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isReportSectionHovered = false;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isReportSectionHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ExpansionTile(
                        trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                        backgroundColor: Colors.deepPurple.shade600,
                        collapsedIconColor: Colors.white,
                        iconColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Container(
                          transform: Matrix4.translationValues(-21, 0.0, 0.0),
                          child: Text(
                            "Reports",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        leading: Icon(
                          Icons.summarize_outlined,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        //childrenPadding: EdgeInsets.only(left: 25.0),
                        children: reportDestinations),
                  ),
                ),
            ],
          ),
        )),
      ),
      body: const SMSScaffoldBody(),
      persistentFooterButtons: [
        new OutlinedButton(
            child: Text(
              'About',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2024, Avinya Foundation."),
      ],
    );
  }
}
