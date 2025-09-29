import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/auth.dart';
import 'package:mobile/avinya/alumni/lib/screens/bottom_navigation/bottom_navigation/screens/navigation_menu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/config/app_config.dart';
import '../routing.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatefulWidget {
  @override
  _SMSScaffoldState createState() => _SMSScaffoldState();
}

class _SMSScaffoldState extends State<SMSScaffold> {
  bool isAlumniDashboardSectionHovered = false;
  bool isAlumniAdminSectionHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Avinya Academy - Alumni Portal",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
        ],
      ),
      body: const SMSScaffoldBody(),
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
