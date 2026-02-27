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
  bool isDutySectionHovered = false;
  bool isReportSectionHovered = false;
  bool isDashboardHovered = false;
  bool isSelfAttendanceHovered = false;
  bool isBulkAttendanceHovered = false;
  bool isDutyAttendanceHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Campus Attendance Portal",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Logout',
            onPressed: () {
              SMSAuthScope.of(context).signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Signed Out')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
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
                        style: new TextStyle(color: Colors.blueAccent),
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
        width: 270.0,
        backgroundColor: Colors.blueAccent,
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
                          margin: EdgeInsets.only(left: 12.0),
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
              // Self Attendance Marker (hide for foundation users)
              if (!campusAppsPortalInstance.isFoundation)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isSelfAttendanceHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isSelfAttendanceHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelfAttendanceHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.assignment_ind,
                              color: Colors.white, size: 20.0),
                          title: Container(
                            margin: EdgeInsets.only(left: 12.0),
                            transform: Matrix4.translationValues(-25, 0.0, 0.0),
                            child: Text(
                              "View Self Attendance",
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
                  ),
                ),
              // Bulk Attendance Marker (for teachers/security/foundation)
              if (campusAppsPortalInstance.isTeacher ||
                  campusAppsPortalInstance.isSecurity ||
                  campusAppsPortalInstance.isOperations ||
                  campusAppsPortalInstance.isFinance)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isBulkAttendanceHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isBulkAttendanceHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBulkAttendanceHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.fact_check,
                              color: Colors.white, size: 20.0),
                          title: Container(
                            margin: EdgeInsets.only(left: 12.0),
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
                  ),
                ),
              // Duty Attendance Marker (for student leaders)
              if (campusAppsPortalInstance.isStudent &&
                  (campusAppsPortalInstance.getLeaderParticipant().role ==
                          'leader' ||
                      campusAppsPortalInstance.getLeaderParticipant().role ==
                          'assistant-leader'))
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isDutyAttendanceHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isDutyAttendanceHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDutyAttendanceHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.people_outline,
                              color: Colors.white, size: 20.0),
                          title: Container(
                            margin: EdgeInsets.only(left: 12.0),
                            transform: Matrix4.translationValues(-25, 0.0, 0.0),
                            child: Text(
                              "Duty Attendance Marker",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            routeState.go('/duty_attendance_marker');
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              if (campusAppsPortalInstance.isTeacher ||
                  campusAppsPortalInstance.isFoundation ||
                  campusAppsPortalInstance.isOperations ||
                  campusAppsPortalInstance.isFinance)
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
                    decoration: BoxDecoration(
                      color: isReportSectionHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.summarize_outlined,
                              color: Colors.white, size: 20.0),
                          title: Container(
                            margin: EdgeInsets.only(left: 12.0),
                            transform: Matrix4.translationValues(-25, 0.0, 0.0),
                            child: Text(
                              "Attendance Report",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            routeState.go('/monthly_payment_report');
                          },
                        ),
                      ),
                    ),
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
                color: Colors.blueAccent,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2026, Avinya Foundation."),
      ],
    );
  }
}
