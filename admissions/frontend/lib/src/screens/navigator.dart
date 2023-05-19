import 'dart:developer';

import 'package:ShoolManagementSystem/src/screens/apply.dart';
import 'package:ShoolManagementSystem/src/screens/preconditions.dart';
import 'package:ShoolManagementSystem/src/screens/subscribe.dart';
import 'package:ShoolManagementSystem/src/screens/subscribed_thankyou.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'author_details.dart';
import 'book_details.dart';
import 'employee_details.dart';
import 'address_type_details.dart';
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
  final _applyKey = const ValueKey('Apply');
  final _subscribeKey = const ValueKey('Subscribe');
  final _subscribedThankyouKey = const ValueKey('Subscribed Thankyou');
  final _preconditionsKey = const ValueKey('Preconditions');
  final _signInKey = const ValueKey('Sign in');
  final _testsKey = const ValueKey('Tests');
  final _applicationKey = const ValueKey('Application');
  final _scaffoldKey = const ValueKey('App scaffold');
  final _bookDetailsKey = const ValueKey('Book details screen');
  final _authorDetailsKey = const ValueKey('Author details screen');
  final _employeeDetailsKey = const ValueKey('Employee details screen');
  final _addressTypeDetailsKey = const ValueKey('Adress Type details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = SMSAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Book? selectedBook;
    if (pathTemplate == '/book/:bookId') {
      selectedBook = admissionSystemInstance.allBooks.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['bookId']);
    }

    Author? selectedAuthor;
    if (pathTemplate == '/author/:authorId') {
      selectedAuthor = admissionSystemInstance.allAuthors.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['authorId']);
    }

    Employee? selectedEmployee;
    if (pathTemplate == '/employee/:employeeId') {
      selectedEmployee = admissionSystemInstance.allEmployees?.firstWhereOrNull(
          (e) =>
              e.employee_id.toString() ==
              routeState.route.parameters['employeeId']);
    }

    AddressType? selectedAddressType;
    if (pathTemplate == '/address_type/:id') {
      selectedAddressType = admissionSystemInstance.addressTypes
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
        // the /books or /authors tab in SMSScaffold.
        if (route.settings is Page &&
            (route.settings as Page).key == _bookDetailsKey) {
          routeState.go('/books/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _authorDetailsKey) {
          routeState.go('/authors');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _employeeDetailsKey) {
          routeState.go('/employees/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _addressTypeDetailsKey) {
          routeState.go('/address_types/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _testsKey) {
          routeState.go('/tests/logical');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _applicationKey) {
          routeState.go('/application');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/apply')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _applyKey,
            child: ApplyScreen(
                // onApply: (credentials) async {
                //   var signedIn = await authState.signIn(
                //       credentials.username, credentials.password);
                //   if (signedIn) {
                //     await routeState.go('/books/popular');
                //   }
                // },
                ),
          )
        else if (routeState.route.pathTemplate == '/subscribe')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _subscribeKey,
            child: SubscribeScreen(),
          )
        else if (routeState.route.pathTemplate == '/subscribed_thankyou')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _subscribedThankyouKey,
            child: SubscribedThankyouScreen(),
          )
        else if (routeState.route.pathTemplate == '/preconditions')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _preconditionsKey,
            child: PreconditionsScreen(
                // onApply: (credentials) async {
                //   var signedIn = await authState.signIn(
                //       credentials.username, credentials.password);
                //   if (signedIn) {
                //     await routeState.go('/books/popular');
                //   }
                // },
                ),
          )
        else if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/books/popular');
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
          if (selectedBook != null)
            MaterialPage<void>(
              key: _bookDetailsKey,
              child: BookDetailsScreen(
                book: selectedBook,
              ),
            )
          else if (selectedAuthor != null)
            MaterialPage<void>(
              key: _authorDetailsKey,
              child: AuthorDetailsScreen(
                author: selectedAuthor,
              ),
            )
          else if (selectedEmployee != null)
            MaterialPage<void>(
              key: _employeeDetailsKey,
              child: EmployeeDetailsScreen(
                employee: selectedEmployee,
              ),
            )
          else if (selectedAddressType != null)
            MaterialPage<void>(
              key: _addressTypeDetailsKey,
              child: AddressTypeDetailsScreen(
                addressType: selectedAddressType,
              ),
            ),
        ],
      ],
    );
  }
}
