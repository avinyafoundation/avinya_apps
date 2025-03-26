import 'package:flutter/material.dart';

class UnderDevelopmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Coming Soon"),
      //   backgroundColor: Colors.blueGrey[900],
      //   elevation: 0,
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_suggest_rounded,
                size: 100,
                color: Colors.blueGrey[700],
              ),
              SizedBox(height: 24),
              Text(
                "Feature in Progress",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "We're working on this feature to enhance your experience. Stay tuned for updates!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              // ElevatedButton(
              //   onPressed: () => Navigator.pop(context),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blueGrey[900],
              //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //   ),
              //   child: Text(
              //     "Back to Home",
              //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
