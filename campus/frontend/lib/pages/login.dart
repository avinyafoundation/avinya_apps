import 'dart:developer';
import 'dart:io';

import 'package:gallery/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class LoginPage extends StatefulWidget {
  // final ValueChanged<Credentials> onSignIn;

  const LoginPage({
    // required this.onSignIn,
    super.key,
  });

  @override
  State<LoginPage> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginPage> {
  String _clientId = AppConfig.asgardeoClientId;
  final String _issuerUrl = AppConfig.asgardeoTokenEndpoint;

  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'groups',
    'address',
    'phone'
  ];

  @override
  Widget build(BuildContext context) {
    log("in signin build -- asgardeoClientId is :" +
        AppConfig.asgardeoClientId);
    int count = 0;
    while (_clientId.isEmpty && count < 10) {
      log(count.toString() + " in Auth -- asgardeoClientId is empty");
      count++;
      if (count > 10) {
        break;
      }
      sleep(Duration(seconds: 1));
      _clientId = AppConfig.asgardeoClientId;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF6), // very light quiet green
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If width is greater than 800 -> show row layout
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                // LEFT SIDE - IMAGE
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Image.asset(
                      'assets/images/education_students.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // RIGHT SIDE - CONTENT
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LOGO AND NAME
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                child: Image.asset(
                                  'assets/images/avinya_logo.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Avinya',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 0.9,
                                    ),
                                  ),
                                  Text(
                                    'Foundation',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CAPTION
                        const Text(
                          'A non-profit philanthropic organization dedicated to assisting underprivileged students',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // LOGIN BUTTON
                        SizedBox(
                          width: 200,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await authenticate(
                                  Uri.parse(_issuerUrl), _clientId, _scopes);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF388E3C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // MOBILE / NARROW SCREEN - STACKED COLUMN
            return SingleChildScrollView(
              child: Column(
                children: [
                  // IMAGE
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/education_students.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // CONTENT
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LOGO AND NAME
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                child: Image.asset(
                                  'assets/images/avinya_logo.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Avinya',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 0.9,
                                    ),
                                  ),
                                  Text(
                                    'Foundation',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CAPTION
                        const Text(
                          'A non-profit philanthropic organization dedicated to assisting underprivileged students',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // LOGIN BUTTON
                        SizedBox(
                          width: 200,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await authenticate(
                                  Uri.parse(_issuerUrl), _clientId, _scopes);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF388E3C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  authenticate(Uri uri, String clientId, List<String> scopes) async {
    log("signin authenticate - Client ID :: " + clientId);
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);

    // create an authenticator
    var authenticator = new Authenticator(client, scopes: scopes);

    // starts the authentication
    authenticator.authorize();
  }
}
