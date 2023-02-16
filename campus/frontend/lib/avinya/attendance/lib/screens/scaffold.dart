import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../routing.dart';
import '../auth.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatelessWidget {
  static const pageNames = [
    '/avinya_types/popular',
    '/activities/popular',
    '/attendance_marker',
  ];

  const SMSScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);

    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: selectedIndex,
        appBar: AppBar(
          title: const Text('Avinya Academy - Campus Attendance Portal'),
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
        body: const SMSScaffoldBody(),
        onDestinationSelected: (idx) {
          routeState.go(pageNames[idx]);
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Avinya Types',
            icon: Icons.type_specimen,
          ),
          AdaptiveScaffoldDestination(
            title: 'Activities',
            icon: Icons.list_alt,
          ),
          AdaptiveScaffoldDestination(
            title: 'Attendance Marker',
            icon: Icons.qr_code_scanner,
          ),
          AdaptiveScaffoldDestination(
            title: 'Tests',
            icon: Icons.text_snippet,
          ),
        ],
      ),
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

  int _getSelectedIndex(String pathTemplate) {
    int index = pageNames.indexOf(pathTemplate);
    if (index >= 0)
      return index;
    else
      return 0;
  }
}
