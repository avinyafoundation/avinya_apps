import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import '../app_routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isDashboardSectionHovered = false;
  bool isAddLogWasteSectionHovered = false;
  bool isLogWasteHistorySectionHovered = false;
  bool isAddFoodItemSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    List<Widget> destinations = [
      MouseRegion(
        onEnter: (_) {
          setState(() {
            isDashboardSectionHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isDashboardSectionHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDashboardSectionHovered
                ? Colors.white.withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              child: ListTile(
                leading: Icon(Icons.analytics_outlined,
                    color: Colors.white, size: 20.0),
                title: Container(
                  margin: EdgeInsets.only(left: 12.0),
                  transform: Matrix4.translationValues(-25, 0.0, 0.0),
                  child: Text(
                    "Food Waste Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  routeState.go(AppRoutes.foodWastageDashboardRoute);
                },
              ),
            ),
          ),
        ),
      ),
      MouseRegion(
        onEnter: (_) {
          setState(() {
            isAddLogWasteSectionHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isAddLogWasteSectionHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isAddLogWasteSectionHovered
                ? Colors.white.withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              child: ListTile(
                leading: Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20.0),
                title: Container(
                  margin: EdgeInsets.only(left: 12.0),
                  transform: Matrix4.translationValues(-25, 0.0, 0.0),
                  child: Text(
                    "Add Log Waste",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  routeState.go(AppRoutes.addLogWasteRoute);
                },
              ),
            ),
          ),
        ),
      ),
      MouseRegion(
        onEnter: (_) {
          setState(() {
            isLogWasteHistorySectionHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isLogWasteHistorySectionHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isLogWasteHistorySectionHovered
                ? Colors.white.withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.white, size: 20.0),
                title: Container(
                  margin: EdgeInsets.only(left: 12.0),
                  transform: Matrix4.translationValues(-25, 0.0, 0.0),
                  child: Text(
                    "Log Waste History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  routeState.go(AppRoutes.logWasteHistoryRoute);
                },
              ),
            ),
          ),
        ),
      ),
      MouseRegion(
        onEnter: (_) {
          setState(() {
            isAddFoodItemSectionHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isAddFoodItemSectionHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isAddFoodItemSectionHovered
                ? Colors.white.withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              child: ListTile(
                leading: Icon(Icons.restaurant_menu,
                    color: Colors.white, size: 20.0),
                title: Container(
                  margin: EdgeInsets.only(left: 12.0),
                  transform: Matrix4.translationValues(-25, 0.0, 0.0),
                  child: Text(
                    "Manage Food Items",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  routeState.go(AppRoutes.manageFoodItemsRoute);
                },
              ),
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Food Wastage Management Portal",
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
            children: destinations,
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
