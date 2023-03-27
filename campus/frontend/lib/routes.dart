// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:developer';

import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/deferred_widget.dart';
import 'package:gallery/main.dart';
import 'package:gallery/pages/home.dart';
import 'package:gallery/pages/login.dart';
import 'package:attendance/app.dart' deferred as attendance;
import 'package:gallery/avinya/pcti_notes/lib/app.dart' deferred as campus_pcti;
import 'package:gallery/avinya/pcti_notes/lib/routes.dart'
    as campus_pcti_routes;
import 'package:gallery/avinya/pcti_notes_admin/lib/app.dart'
    deferred as campus_pcti_admin;
import 'package:gallery/avinya/pcti_notes_admin/lib/routes.dart'
    as campus_pcti_admin_routes;
import 'package:gallery/avinya/asset/lib/routes.dart' as asset;
import 'package:attendance/routes.dart' as routes;
import 'package:gallery/pages/profile.dart' as profile;

import 'package:pcti_feedback/app.dart' deferred as feedback;
import 'package:pcti_feedback/routes.dart' as feedback_routes;

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

class Path {
  const Path(this.pattern, this.builder, {this.openInSecondScreen = false});

  /// A RegEx string for route matching.
  final String pattern;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument a RegEx match if that is included
  /// in the pattern.
  ///
  /// ```dart
  /// Path(
  ///   'r'^/demo/([\w-]+)$',
  ///   (context, matches) => Page(argument: match),
  /// )
  /// ```
  final PathWidgetBuilder builder;

  /// If the route should open on the second screen on foldables.
  final bool openInSecondScreen;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + routes.attendanceRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(
            attendance.loadLibrary,
            () => attendance
                .CampusAttendanceManagementSystem()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      //block added lahiru-2023-03-10
      r'^' + campus_pcti_routes.campuspctiRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(
            campus_pcti.loadLibrary,
            () => campus_pcti
                .CampusPctiSystem()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      //block added lahiru-2023-03-10
      r'^' + campus_pcti_admin_routes.campuspctiadminRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(
            campus_pcti_admin.loadLibrary,
            () => campus_pcti_admin
                .CampusPctiSystem()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^' + feedback_routes.feedbackRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(
            feedback.loadLibrary,
            () => feedback
                .CampusFeedbackSystem()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^' + asset.assetRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(
            asset.loadLibrary,
            () => asset
                .CampusAttendanceManagementSystem()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^' + routes.profileRoute,
      (context, match) => StudyWrapper(
        study: DeferredWidget(attendance.loadLibrary,
            () => profile.ProfileScreen()), // ignore: prefer_const_constructors
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^/',
      (context, match) => const RootPage(),
      openInSecondScreen: false,
    ),
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    for (final path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (regExpPattern.hasMatch(settings.name!)) {
        final firstMatch = regExpPattern.firstMatch(settings.name!)!;
        final match = (firstMatch.groupCount == 1) ? firstMatch.group(1) : null;
        if (kIsWeb) {
          return NoAnimationMaterialPageRoute<void>(
            builder: (context) => FutureBuilder<bool>(
              future: isAuthorized(settings),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return path.builder(context, match);
                }
                return LoginPage();
              },
            ),
            settings: settings,
          );
        }
        if (path.openInSecondScreen) {
          return TwoPanePageRoute<void>(
            builder: (context) => FutureBuilder<bool>(
              future: isAuthorized(settings),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return path.builder(context, match);
                }
                return LoginPage();
              },
            ),
            settings: settings,
          );
        } else {
          return MaterialPageRoute<void>(
            builder: (context) => FutureBuilder<bool>(
              future: isAuthorized(settings),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return path.builder(context, match);
                }
                return LoginPage();
              },
            ),
            settings: settings,
          );
        }
      }
    }
    return null;
  }
}

class RouteGuard extends StatelessWidget {
  final Widget child;
  final Function guard;

  const RouteGuard({required this.child, required this.guard});

  @override
  Widget build(BuildContext context) {
    if (guard()) {
      return child;
    }
    return Scaffold(
      body: Center(
        child: Text('You are not authorized to access this page'),
      ),
    );
  }
}

Future<bool> isAuthorized(RouteSettings settings) async {
  bool signedIn = await campusAppsPortalInstance.getSignedIn();
  //log signedIn
  log("signedIn $signedIn");
  if (settings.name == '/signin') {
    return Future.value(true);
  } else {
    log("signedIsignedInn $signedIn");
    if (signedIn) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class TwoPanePageRoute<T> extends OverlayRoute<T> {
  TwoPanePageRoute({
    required this.builder,
    super.settings,
  });

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(builder: (context) {
      final hinge = MediaQuery.of(context).hinge?.bounds;
      if (hinge == null) {
        return builder.call(context);
      } else {
        return Positioned(
            top: 0,
            left: hinge.right,
            right: 0,
            bottom: 0,
            child: builder.call(context));
      }
    });
  }
}
