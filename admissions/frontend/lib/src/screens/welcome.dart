import 'package:ShoolManagementSystem/src/data/prospect.dart';
import 'package:flutter/material.dart';

import '../routing.dart';

class WelcomeScreen extends StatefulWidget {
  static const String route = 'welcome';
  final Prospect? prospect;

  const WelcomeScreen({super.key, this.prospect});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Avinya Academy - Student Admissions'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/light_landing.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to Avinya Academy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Student Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                Column(
                  children: [
                    Text(
                        "Avinya Academy is a school that is dedicated to providing a high quality education to students from all backgrounds."),
                    Text(
                        "We are currently accepting applications for the 2022/2023 academic year. "),
                    Text(
                        "Please fill out the forms to apply for admission to Avinya Academy. "),
                  ],
                ),
                SizedBox(height: 32.0),
                Text(
                  'If you would like to proceed to fill in the application forms, please click below.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    await routeState.go('/apply');
                  },
                  child: Text('Fill in Application Forms'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
