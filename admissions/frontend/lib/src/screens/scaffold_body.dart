import 'package:ShoolManagementSystem/src/screens/application.dart';
import 'package:ShoolManagementSystem/src/screens/vacancys.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import '../screens/settings.dart';
import '../widgets/fade_transition_page.dart';
import 'authors.dart';
import 'books.dart';
import 'employees.dart';
import 'address_types.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [SMSScaffold]
class SMSScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const SMSScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.pathTemplate.startsWith('/tests'))
          const FadeTransitionPage<void>(
            key: ValueKey('tests'),
            child: VacancyScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/application'))
          const FadeTransitionPage<void>(
            key: ValueKey('application'),
            child: ApplicationScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/authors'))
          const FadeTransitionPage<void>(
            key: ValueKey('authors'),
            child: AuthorsScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/settings'))
          const FadeTransitionPage<void>(
            key: ValueKey('settings'),
            child: SettingsScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/books') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('books'),
            child: BooksScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/employees') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('employees'),
            child: EmployeesScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/address_types') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('address_types'),
            child: AddressTypeScreen(),
          )

        // Avoid building a Navigator with an empty `pages` list when the
        // RouteState is set to an unexpected path, such as /signin.
        //
        // Since RouteStateScope is an InheritedNotifier, any change to the
        // route will result in a call to this build method, even though this
        // widget isn't built when those routes are active.
        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
