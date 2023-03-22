import 'dart:developer';
// import 'dart:io';

// import 'package:ShoolManagementSystem/src/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // String _clientId = AppConfig.asgardeoClientId;
  // final String _issuerUrl = AppConfig.asgardeoTokenEndpoint;

  // final List<String> _scopes = <String>['openid', 'profile', 'email'];

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Card(
            child: Container(
              constraints: BoxConstraints.loose(const Size(600, 600)),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sign in', style: Theme.of(context).textTheme.headline4),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    controller: _usernameController,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () async {
                        widget.onSignIn(Credentials(
                            _usernameController.value.text,
                            _passwordController.value.text));
                      },
                      child: const Text('Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );


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
