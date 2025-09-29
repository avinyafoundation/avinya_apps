import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/alumni/lib/app_routes/app_routes.dart';
import 'package:gallery/avinya/consumable/lib/data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isAlumniDashboardSectionHovered = false;
  bool isAlumniAdminSectionHovered = false;
  bool isJobPortalSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    List<Material> jobPortalDestinations = [];

    if (campusAppsPortalInstance.isTeacher ||
        campusAppsPortalInstance.isFoundation) {
      jobPortalDestinations = [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
            child: ListTile(
              hoverColor: Colors.white.withOpacity(0.3),
              leading: Icon(Icons.post_add, color: Colors.white, size: 20.0),
              title: Container(
                margin: EdgeInsets.only(left: 12.0),
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Post a Job",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go(AppRoutes.createJobPostRoute);
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
              leading: Icon(Icons.list_alt, color: Colors.white, size: 20.0),
              title: Container(
                margin: EdgeInsets.only(left: 12.0),
                transform: Matrix4.translationValues(-25, 0.0, 0.0),
                child: Text(
                  "Manage Job Posts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                routeState.go(AppRoutes.jobPostListRoute);
              },
            ),
          ),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Alumni Portal",
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
                        style: new TextStyle(color: Colors.blueGrey[400]),
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
              if (campusAppsPortalInstance.isFoundation ||
                  campusAppsPortalInstance.isTeacher)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isAlumniDashboardSectionHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isAlumniDashboardSectionHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAlumniDashboardSectionHovered
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
                              "Alumni Dashboard",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            routeState.go(AppRoutes.alumniDashboardRoute);
                          },
                        ),
                      ),
                    ),
                    // ),
                  ),
                ),
              if (campusAppsPortalInstance.isFoundation ||
                  campusAppsPortalInstance.isTeacher)
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isAlumniAdminSectionHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isAlumniAdminSectionHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAlumniAdminSectionHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.people,
                              color: Colors.white, size: 20.0),
                          title: Container(
                            margin: EdgeInsets.only(left: 12.0),
                            transform: Matrix4.translationValues(-25, 0.0, 0.0),
                            child: Text(
                              "Alumni Admin",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            routeState.go(AppRoutes.alumniAdminRoute);
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
                      isJobPortalSectionHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isJobPortalSectionHovered = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isJobPortalSectionHovered
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      trailing: Icon(Icons.keyboard_arrow_down, size: 20.0),
                      backgroundColor: Colors.blueGrey[400],
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Container(
                        margin: EdgeInsets.only(left: 12.0),
                        transform: Matrix4.translationValues(-21, 0.0, 0.0),
                        child: Text(
                          "Career Center",
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
                      children: jobPortalDestinations,
                    ),
                    //),
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
                color: Colors.blueGrey[400],
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
