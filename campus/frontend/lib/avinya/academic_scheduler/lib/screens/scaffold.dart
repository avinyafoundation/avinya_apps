import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isAcademicSchedulerDashboardSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Academic Scheduler Portal",
            style: TextStyle(color: Colors.white)),
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
                        style:
                            new TextStyle(color: Colors.lightBlueAccent[400]),
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
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isAcademicSchedulerDashboardSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAcademicSchedulerDashboardSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAcademicSchedulerDashboardSectionHovered
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
                            "Academic Scheduler Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go('/academic_scheduler_dashboard');
                        },
                      ),
                    ),
                  ),
                  // ),
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
                color: Colors.lightBlueAccent[400],
                fontSize: 12,
              ),
            ),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2025, Avinya Foundation."),
      ],
    );
  }
}
