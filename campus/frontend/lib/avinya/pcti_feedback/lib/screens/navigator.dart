import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:gallery/auth.dart';
import 'package:pcti_feedback/screens/evaluation_details.dart';
import 'package:pcti_feedback/screens/pcti_notes.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class SMSNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SMSNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<SMSNavigator> createState() => _SMSNavigatorState();
}

class _SMSNavigatorState extends State<SMSNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');
  // final _pctiNoteDetailsKey = const ValueKey('PCTI Note details screen');
  final _pctiActivityDetailsKey =
      const ValueKey('PCTI Activity details screen');
  final _evaluationDetailsKey = const ValueKey('Evaluations details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = SMSAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Activity? selectedPctiActivity;
    if (pathTemplate == '/pcti_activities/:id') {
      selectedPctiActivity = campusFeedbackSystemInstance.activities
          ?.firstWhereOrNull(
              (at) => at.id.toString() == routeState.route.parameters['id']);
    }

    Evaluation? selectedEvaluation;
    if (pathTemplate == '/evaluation/:id') {
      selectedEvaluation = campusFeedbackSystemInstance.evaluations
          ?.firstWhereOrNull(
              (at) => at.id.toString() == routeState.route.parameters['id']);
    }

    if (pathTemplate == '/#access_token') {
      log('Navigator $routeState.route.parameters.toString()');
      log('Navigator $routeState.route.queryParameters.toString()');
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /avinya_types tab in SMSScaffold.

        // if (route.settings is Page &&
        //     (route.settings as Page).key == _pctiNoteDetailsKey) {
        //   routeState.go('/pcti_notes');
        // }

        if (route.settings is Page &&
            (route.settings as Page).key == _pctiActivityDetailsKey) {
          // routeState.go('/pcti_notes/popular');
          routeState.go('/pcti_activities');
        }

        // if (route.settings is Page &&
        //     (route.settings as Page).key == _evaluationDetailsKey) {
        //   // routeState.go('/pcti_notes/popular');
        //   routeState.go('/evaluations');
        // }

        return route.didPop(result);
      },
      pages: [
        // if (routeState.route.pathTemplate == '/apply')
        //   // Display the sign in screen.
        //   FadeTransitionPage<void>(
        //     key: _applyKey,
        //     child: ApplyScreen(
        //         ),
        //   )
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  // await routeState.go('/pcti_notes/popular');
                  await routeState.go('/pcti_activities');
                }
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const SMSScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a book
          // or an author
          if (selectedPctiActivity != null)
            MaterialPage<void>(
              key: _pctiActivityDetailsKey,
              child: PctiNoteScreen(
                pctiActivity: selectedPctiActivity,
              ),
            )
          else if (selectedEvaluation != null)
            MaterialPage<void>(
              key: _evaluationDetailsKey,
              child: EvaluationDetailsScreen(
                evaluation: selectedEvaluation,
              ),
            )
        ],
      ],
    );
  }
}
