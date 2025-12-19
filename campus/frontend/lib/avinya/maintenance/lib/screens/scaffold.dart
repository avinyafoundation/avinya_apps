import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/maintenance/lib/app_routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isMaintenanceDashboardSectionHovered = false;
  bool isAddLocationSectionHovered = false;
  bool isKanbanBoardSectionHovered = false;
  bool isTaskDetailsSectionHovered = false;
  bool isDirectorDashboardSectionHovered = false;
  bool isAddTaskSectionHovered = false;
  bool isFinanceApprovalsSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Maintenance Management Portal",
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
                    isMaintenanceDashboardSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isMaintenanceDashboardSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isMaintenanceDashboardSectionHovered
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
                            "Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.maintenanceDashboardRoute);
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
                    isAddLocationSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAddLocationSectionHovered = false;
                    //isAddTaskSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAddLocationSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.add_location,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Add Academy Location",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.addLocationRoute);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isKanbanBoardSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isKanbanBoardSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isKanbanBoardSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.view_kanban,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Kanban Board",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.kanbanBoardRoute);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isAddTaskSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isAddTaskSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isAddTaskSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.add_task,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Add Task",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.addTaskRoute);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isTaskDetailsSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isTaskDetailsSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isTaskDetailsSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.info_rounded,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Task Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.taskDetailsRoute);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isFinanceApprovalsSectionHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isFinanceApprovalsSectionHovered = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isFinanceApprovalsSectionHovered
                        ? Colors.white.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      child: ListTile(
                        leading: Icon(Icons.approval,
                            color: Colors.white, size: 20.0),
                        title: Container(
                          margin: EdgeInsets.only(left: 12.0),
                          transform: Matrix4.translationValues(-25, 0.0, 0.0),
                          child: Text(
                            "Finance Approvals",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          routeState.go(AppRoutes.financeApprovalsRoute);
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
        new Text("© 2026, Avinya Foundation."),
      ],
    );
  }
}
