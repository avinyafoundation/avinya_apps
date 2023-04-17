import 'package:flutter/material.dart';

import '../data/prospect.dart';
import '../routing.dart';

class SubscribedThankyouScreen extends StatefulWidget {
  static const String route = 'subscribed_thankyou';
  final Prospect? prospect;

  const SubscribedThankyouScreen({super.key, this.prospect});
  @override
  _SubscribedThankyouScreenState createState() =>
      _SubscribedThankyouScreenState();
}

class _SubscribedThankyouScreenState extends State<SubscribedThankyouScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Wrap(children: [
                        Column(children: [
                          const Text(
                            "Avinya Academy - Prospective Student Subscription",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                              """ You have successfully subscribed to our prospective student list.
                            We will contact you shortly.."""),
                          // SizedBox(height: 10.0),
                          // Text(
                          //     "Thank you for your interest in Avinya Academy."),
                          const SizedBox(height: 10.0),
                          const Text(
                              "If you would like to proceed to fill in the application forms, please click below."),
                          const SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () async {
                              await routeState.go('/preconditions');
                            },
                            child: const Text('Fill in Application Forms'),
                          ),
                        ]),
                      ]),
                    ),
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
