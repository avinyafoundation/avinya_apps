import 'package:flutter/material.dart';
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


  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = const ValueKey('App scaffold');

    return Navigator(
      key: widget.navigatorKey,
      // ignore: deprecated_member_use
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /books or /authors tab in SMSScaffold.
        return route.didPop(result);
      },
      pages: [
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: SMSScaffold(),
          ),
      ],
    );
  }
}
