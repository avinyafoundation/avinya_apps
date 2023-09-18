import 'dart:convert';
import 'dart:developer';
// import 'dart:html';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';

import 'package:mobile/data/campus_apps_portal.dart';
import 'package:flutter/widgets.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import './config/app_config.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

/// A mock authentication service
class CampusAppsPortalAuth extends ChangeNotifier {
  bool _signedIn = false;

  Future<bool> getSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('access_token') ?? '';
    String refreshToken = prefs.getString('refresh_token') ?? '';
    String idToken = prefs.getString('id_token') ?? '';

    log("_guard signed in uuuuuu");
    if (_signedIn)
      return _signedIn; // already signed in -- todo - remove before production release
    // var tokens = window.localStorage['openid_client:tokens'];

    if (accessToken.isNotEmpty && idToken.isNotEmpty) {
      log("_guard signed in truetrue");
      // _openid_tokens = json.decode(tokens);

      // if (_openid_tokens != null && _openid_tokens['access_token'] != null) {
      _signedIn = true;
      print('OpenID tokens ##################');
      // _openid_tokens.forEach((key, value) =>
      //     print("Access token -- Key : $key, Value : $value"));
      Map<String, dynamic> decodedAccessToken = JwtDecoder.decode(accessToken);
      decodedAccessToken.forEach(
          (key, value) => print("access_token -- Key : $key, Value : $value"));

      // capture token information to help map the sing in user to Avinya person
      campusAppsPortalInstance.setJWTSub(decodedAccessToken["sub"]);
      campusAppsPortalInstance.setJWTEmail(decodedAccessToken["email"]);
      campusAppsPortalInstance.setDigitalId(decodedAccessToken["email"]);
      campusAppsPortalPersonMetaDataInstance
          .setGroups(decodedAccessToken["groups"] as List<dynamic>);
      campusAppsPortalPersonMetaDataInstance
          .setScopes(decodedAccessToken["scope"] as String);

      bool isTokenExpired = JwtDecoder.isExpired(idToken);
      print("Open ID token is expired $isTokenExpired");

      Map<String, dynamic> decodedIDToken = JwtDecoder.decode(idToken);
      decodedIDToken.forEach(
          (key, value) => print("id_token -- Key : $key, Value : $value"));
      print('email :: ' + decodedIDToken["email"]);

      if (isTokenExpired) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(accessToken);
        prefs.remove(refreshToken);
        prefs.remove(idToken);
        // window.localStorage.remove('openid_client:tokens');
        // window.localStorage.clear();
        _signedIn = false;
        return _signedIn;
      }

      bool isAccessTokenExpired = JwtDecoder.isExpired(accessToken);
      print("Access token is expired $isAccessTokenExpired");
      if (AppConfig.apiTokens != null && isAccessTokenExpired) {
        // Use refresh token
        String refreshToken = AppConfig.refreshToken;
        String clientId = AppConfig.choreoSTSClientID;

        final response = await http.post(
          Uri.parse(AppConfig.asgardeoTokenEndpoint),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          encoding: Encoding.getByName('utf-8'),
          body: {
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            'client_id': clientId,
          },
        );

        if (response.statusCode == 200) {
          var refreshedTokens = json.decode(response.body);
          AppConfig.apiTokens = refreshedTokens;
          AppConfig.campusBffApiKey = refreshedTokens["access_token"];
          AppConfig.refreshToken = refreshedTokens["refresh_token"];
          print('Access token refreshed successfully');
        } else {
          print('Failed to refresh access token');
          // Handle the error case appropriately
        }
      } else {
        log("in Auth -- choreoSTSClientID is :" + AppConfig.choreoSTSClientID);
        int count = 0;
        while (AppConfig.choreoSTSClientID.isEmpty && count < 10) {
          log(count.toString() + " in Auth -- choreoSTSClientID is empty");
          count++;
          if (count > 10) {
            break;
          }
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await http.post(
          Uri.parse(AppConfig.choreoSTSEndpoint),
          headers: <String, String>{
            //'Content-Type': 'application/x-www-form-urlencoded',
            //'Authorization': 'Bearer ${_openid_tokens["access_token"]}',
            //'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
          },
          encoding: Encoding.getByName('utf-8'),
          body: {
            "client_id": AppConfig.choreoSTSClientID,
            "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
            "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
            "subject_token": idToken,
          },
        );
        if (response.statusCode == 200) {
          print(response.body.toString());
          var _api_tokens = json.decode(response.body);
          AppConfig.apiTokens = _api_tokens;
          print('API tokens ##################');
          _api_tokens
            ..forEach(
                (key, value) => print("API tokens Key : $key, Value : $value"));
          AppConfig.campusBffApiKey = _api_tokens["access_token"];
          AppConfig.refreshToken = _api_tokens["refresh_token"];
          print('Fetch API tokens success');
        } else {
          print('Failed to fetch API key');
          print('Fetch API tokens error :: ' + response.body.toString());
          print(response.statusCode);
          _signedIn = false;
        }
      }
      // }
    } else {
      log("_guard _signedIn_signedIn in");
      _signedIn = false;
      window.localStorage.clear();
    }

    if (_signedIn) {
      campusAppsPortalInstance.fetchPersonForUser();
    }

    return _signedIn;
  }

  Future<void> logout() async {
    String logoutUrl = AppConfig.asgardeoLogoutUrl;
    if (await canLaunchUrl(Uri.parse(logoutUrl))) {
      await launchUrl(Uri.parse(logoutUrl), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $logoutUrl';
    }
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    window.localStorage.clear();
    _signedIn = false;
    try {
      await logout();
    } catch (error) {
      log(error.toString());
    }
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is CampusAppsPortalAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

Future<void> authenticate(Uri uri, String clientId, List<String> scopes,
    String redirectURL, String discoveryUrl) async {
  const FlutterAppAuth flutterAppAuth = FlutterAppAuth();

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

class SMSAuthScope extends InheritedNotifier<CampusAppsPortalAuth> {
  const SMSAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static CampusAppsPortalAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SMSAuthScope>()!.notifier!;
}
