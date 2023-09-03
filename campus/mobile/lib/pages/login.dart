import 'dart:developer';
import 'dart:io';

import 'package:mobile/auth.dart';
import 'package:mobile/config/app_config.dart';
import 'package:flutter/material.dart';
// import 'package:openid_client/openid_client_browser.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FlutterAppAuth flutterAppAuth = FlutterAppAuth();

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
  final String _redirectUrl = AppConfig.redirectURL;
  final String _discoveryUrl = AppConfig.asgardeoDiscoveryURL;

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
      sleep(const Duration(seconds: 1));
      _clientId = AppConfig.asgardeoClientId;
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Sign in"),
      // ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dark.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    //width: 400,
                    // margin: EdgeInsets.only(left:400.0),
                    alignment: Alignment.center,
                    child: const Wrap(children: [
                      Column(children: [
                        Text(
                          "Avinya Academy Apps Portal",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Google Sans",
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          """To proceed to the Apps Portal, please sign in.""",
                          style: TextStyle(
                            fontFamily: "Google Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Once you sign in, you will be directed to the Apps Portal",
                          style: TextStyle(
                            fontFamily: "Google Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10.0),
                      ]),
                    ]),
                  ),
                ),
              ),
              Container(
                //  margin: EdgeInsets.only(top: 20.0,left: 380.0),
                margin: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.yellowAccent),
                    shadowColor: MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.contain,
                        width: 40,
                      ),
                      const Text(
                        "Login with Asgardeo",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Google Sans",
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await authenticate(Uri.parse(_issuerUrl), _clientId,
                        _scopes, _redirectUrl, _discoveryUrl);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // authenticate(Uri uri, String clientId, List<String> scopes) async {
  //   log("signin authenticate - Client ID :: " + clientId);
  //   // create the client
  //   var issuer = await Issuer.discover(uri);
  //   var client = new Client(issuer, clientId);

  //   // create an authenticator
  //   var authenticator = new Authenticator(client, scopes: scopes);

  //   // starts the authentication
  //   authenticator.authorize();
  // }

  // Future<void> authenticate(
  //     Uri uri, String clientId, List<String> scopes, String redirectURL) async {
  //   try {
  //     AuthorizationTokenRequest(
  //       clientId, redirectURL, // Replace with your redirect URI
  //       issuer: uri.toString(), // Convert the URI to a string
  //       scopes: scopes,
  //     );
  //   } catch (e) {
  //     // Handle authentication errors
  //     print('Authentication error: $e');
  //   }
  // }

  Future<void> authenticate(Uri uri, String clientId, List<String> scopes,
      String redirectURL, String discoveryUrl) async {
    try {
      final AuthorizationTokenResponse? result =
          await flutterAppAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectURL,
          discoveryUrl: discoveryUrl,
          promptValues: ['login'],
          scopes: scopes,
        ),
      );

      print('Access token bla bla bla: ${result?.accessToken}');
      String accessToken = result?.accessToken ?? '';
      String refreshToken = result?.refreshToken ?? '';
      String idToken = result?.idToken ?? '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('id_token', idToken);

      // final _auth = CampusAppsPortalAuth();
      // final signedIn = await _auth.getSignedIn();

      // setState(() {
      //   _isUserLoggedIn = true;
      //   _idToken = result?.idToken;
      //   _accessToken = result?.accessToken;
      //   _pageIndex = 2;
      // });
    } catch (e, s) {
      print('Error while login to the system: $e - stack: $s');
      // setState(() {
      //   _isUserLoggedIn = false;
      // });
    }
  }
}
