import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../auth.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatelessWidget {
  
  const SMSScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Avinya Academy - Maintenance Management Portal",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
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
                  );
                },
              ));
            },
          ),
        ],
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
