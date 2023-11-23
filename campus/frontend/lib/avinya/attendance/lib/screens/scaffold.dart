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

class SMSScaffold extends StatelessWidget {
  static const pageNames = [
    '/attendance_marker',
    '/bulk_attendance_marker/classes',
    '/daily_attendance_report',
    '/late_attendance_report',
    '/weekly_payment_report',
    '/duty_participants',
    '/daily_duty_attendance_report',
  ];

  static const studentPageNames = [
    '/attendance_marker',
    '/person_attendance_report',
  ];

  static const leaderParticipantPageNames = [
     '/attendance_marker',
     '/person_attendance_report',
     '/duty_attendance_marker',
  ];

  const SMSScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
   // final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);
    var currentRoute = RouteStateScope.of(context).route;


    List<ListTile> attendanceMarkerDestinations = [];
    List<ListTile> dutyDestinations = [];
    List<ListTile> reportDestinations = [];

     if (campusAppsPortalInstance.isTeacher ||
        campusAppsPortalInstance.isSecurity ||
        campusAppsPortalInstance.isFoundation) {

      attendanceMarkerDestinations = [
          ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      "Self Attendance Marker"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/attendance_marker');
                    },
          ),
          ListTile(
                    leading: Icon(Icons.people),
                    title: Text(
                      "Bulk Attendance Marker"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/bulk_attendance_marker/classes');
                    },
          ),   
      ];

      reportDestinations = [
          ListTile(
                    leading: Icon(Icons.summarize),
                    title: Text(
                      "Daily Attendance Report"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/daily_attendance_report');
                    },
          ),
          ListTile(
                    leading: Icon(Icons.watch_later),
                    title: Text(
                      "Late Attendance Report"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/late_attendance_report');
                    },
          ),
          ListTile(
                    leading: Icon(Icons.paid),
                    title: Text(
                      "Weekly Payment Report"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/weekly_payment_report');
                    },
          ),
          ListTile(
                    leading: Icon(Icons.work_history),
                    title: Text(
                      "Daily Duty Attendance Report"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/daily_duty_attendance_report');
                    },
          ),
      ];

      dutyDestinations = [
            ListTile(
                    leading: Icon(Icons.person_add_alt_1),
                    title: Text(
                      "Assign duties"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/duty_participants');
                    },
            ),
      ];

    }else if(campusAppsPortalInstance.isStudent 
      && campusAppsPortalInstance.getLeaderParticipant().role == 'leader'){

       
       attendanceMarkerDestinations = [
          ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      "Self Attendance Marker"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/attendance_marker');
                    },
          ),
          ListTile(
                    leading: Icon(Icons.people),
                    title: Text(
                      "Duty Attendance Marker"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/duty_attendance_marker');
                    },
          ),

       ];

    }else{

      attendanceMarkerDestinations = [
         ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      "Self Attendance Marker"
                    ),
                    onTap: (){
                      Navigator.pop(context);// Close the drawer
                      routeState.go('/attendance_marker');
                    },
        ),
      ];


    }

    // List<AdaptiveScaffoldDestination> destinations = [];
    // if (campusAppsPortalInstance.isTeacher ||
    //     campusAppsPortalInstance.isSecurity ||
    //     campusAppsPortalInstance.isFoundation) {
    //   destinations = const [
    //     AdaptiveScaffoldDestination(
    //       title: 'Self Attendance Marker',
    //       icon: Icons.person_outline,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Bulk Attendance Marker',
    //       icon: Icons.people,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Daily Attendance Report',
    //       icon: Icons.summarize,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Late Attendance Report',
    //       icon: Icons.watch_later,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Weekly Payment Report',
    //       icon: Icons.paid,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Assign duties',
    //       icon: Icons.work,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Daily Duty Attendance Report',
    //       icon: Icons.work_history,
    //     ),
    //   ];
    // }else if(campusAppsPortalInstance.isStudent 
    //   && campusAppsPortalInstance.getLeaderParticipant().role == 'leader'){
         
    //   destinations = const[
    //     AdaptiveScaffoldDestination(
    //       title: 'Attendance Marker',
    //       icon: Icons.person_outline,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Payment Report',
    //       icon: Icons.summarize,
    //     ),
    //     AdaptiveScaffoldDestination(
    //        title: 'Duty Attendance Marker',
    //        icon: Icons.people,
    //     ),
         
    //    ];  
    //   }else {
    //   destinations = const [
    //     AdaptiveScaffoldDestination(
    //       title: 'Attendance Marker',
    //       icon: Icons.person_outline,
    //     ),
    //     AdaptiveScaffoldDestination(
    //       title: 'Person Payment Report',
    //       icon: Icons.summarize,
    //     ),
    //   ];
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Campus Attendance Portal"),
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
                      style: new TextStyle(color: Colors.blue),
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
        child: SafeArea(
          child: 
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ExpansionTile(
                title: Text("Attendance Marker"),
                leading: Icon(Icons.person),
                childrenPadding: EdgeInsets.only(left: 60.0),
                children: attendanceMarkerDestinations, 
              ),
            if(campusAppsPortalInstance.isTeacher ||
              campusAppsPortalInstance.isSecurity ||
              campusAppsPortalInstance.isFoundation)

              ExpansionTile(
                title: Text("Duty"),
                leading: Icon(Icons.work),
                childrenPadding: EdgeInsets.only(left: 60.0),
                children:dutyDestinations,
              ),

            if(campusAppsPortalInstance.isTeacher ||
              campusAppsPortalInstance.isSecurity ||
              campusAppsPortalInstance.isFoundation)

              ExpansionTile(
                title: Text("Reports"),
                leading: Icon(Icons.summarize),
                childrenPadding: EdgeInsets.only(left: 60.0),
                children: reportDestinations
              ),
            ],
          ),
        )
        ),
      ),
      // body: AdaptiveNavigationScaffold(
      //   bottomNavigationOverflow: 10,
      //   selectedIndex: selectedIndex,
      //   appBar: AppBar(
      //     //title: const Text('Avinya Academy - Campus Attendance Portal'),
      //     actions: <Widget>[
      //       IconButton(
      //         icon: const Icon(Icons.logout),
      //         tooltip: 'Logout',
      //         onPressed: () {
      //           SMSAuthScope.of(context).signOut();
      //           ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(content: Text('User Signed Out')));
      //         },
      //       ),
      //       IconButton(
      //         icon: const Icon(Icons.info),
      //         tooltip: 'Help',
      //         onPressed: () {
      //           Navigator.push(context, MaterialPageRoute<void>(
      //             builder: (BuildContext context) {
      //               return Scaffold(
      //                 appBar: AppBar(
      //                   title: const Text('Help'),
      //                 ),
      //                 body: Align(
      //                   alignment: Alignment.center,
      //                   child: SelectableText.rich(TextSpan(
      //                     text:
      //                         "If you need help, write to us at admissions-help@avinyafoundation.org",
      //                     style: new TextStyle(color: Colors.blue),
      //                     recognizer: new TapGestureRecognizer()
      //                       ..onTap = () {
      //                         launchUrl(Uri(
      //                           scheme: 'mailto',
      //                           path: 'admissions-help@avinyafoundation.org',
      //                           query:
      //                               'subject=Avinya Academy Admissions - Bandaragama&body=Question on my application', //add subject and body here
      //                         ));
      //                       },
      //                   )),
      //                 ),
      //               );
      //             },
      //           ));
      //         },
      //       ),
      //     ],
      //   ),
          body: const SMSScaffoldBody(),
      //   onDestinationSelected: (idx) {
      //     if (campusAppsPortalInstance.isTeacher ||
      //         campusAppsPortalInstance.isSecurity ||
      //         campusAppsPortalInstance.isFoundation) {
      //       routeState.go(pageNames[idx]);
      //     }else if(campusAppsPortalInstance.isStudent 
      //       && campusAppsPortalInstance.getLeaderParticipant().role == 'leader'){

      //       routeState.go(leaderParticipantPageNames[idx]);

      //     }else {
      //       routeState.go(studentPageNames[idx]);
      //     }
      //   },
      //   destinations: destinations,
      // ),
      persistentFooterButtons: [
        new OutlinedButton(
            child: Text('About'),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2023, Avinya Foundation."),
      ],
    );
  }

  // int _getSelectedIndex(String pathTemplate) {
  //   int index;

  //   if (campusAppsPortalInstance.isTeacher ||
  //       campusAppsPortalInstance.isSecurity ||
  //       campusAppsPortalInstance.isFoundation) {
  //     index = pageNames.indexOf(pathTemplate);
  //   }else if(campusAppsPortalInstance.isStudent 
  //           && campusAppsPortalInstance.getLeaderParticipant().role == 'leader'){
      
  //     index = leaderParticipantPageNames.indexOf(pathTemplate);
  //   }else {
  //     index = studentPageNames.indexOf(pathTemplate);
  //   }

  //   if (index >= 0)
  //     return index;
  //   else
  //     return 0;
  // }
}
