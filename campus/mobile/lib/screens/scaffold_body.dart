// import 'package:attendance/screens/activities.dart';
// import 'package:attendance/screens/avinya_types.dart';
import 'package:mobile/screens/attendance_marker.dart';
// import 'package:attendance/screens/bulk_attendance_marker.dart';
// import 'package:attendance/screens/daily_attendance_report.dart';

import 'package:flutter/material.dart';
// import 'package:attendance/screens/weekly_payment_report.dart';
import 'package:mobile/screens/person_attendance_report.dart';
import 'package:mobile/screens/qr_attendance_marker.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
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
        // if (currentRoute.pathTemplate.startsWith('/avinya_types'))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('avinya_types'),
        //     child: AvinyaTypeScreen(),
        //   )
        // else if (currentRoute.pathTemplate.startsWith('/activities'))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('activites'),
        //     child: ActivityScreen(),
        //   )
        if (currentRoute.pathTemplate.startsWith('/attendance_marker') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('attendance_marker'),
            child: AttendanceMarkerScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/qr_attendance_marker'))
          const FadeTransitionPage<void>(
            key: ValueKey('qr_attendance_marker'),
            child: QrAttendanceMarkerScreen(),
          )
        // else if (currentRoute.pathTemplate
        //     .startsWith('/bulk_attendance_marker'))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('bulk_attendance_marker'),
        //     child: BulkAttendanceMarkerScreen(),
        //   )
        // else if (currentRoute.pathTemplate
        //     .startsWith('/daily_attendance_report'))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('daily_attendance_report'),
        //     child: DailyAttendanceReportScreen(),
        //   )
        // else if (currentRoute.pathTemplate.startsWith('/weekly_payment_report'))
        //   const FadeTransitionPage<void>(
        //     key: ValueKey('weekly_payment_report'),
        //     child: WeeklyPaymentReportScreen(),
        //   )
        else if (currentRoute.pathTemplate
            .startsWith('/person_attendance_report'))
          const FadeTransitionPage<void>(
            key: ValueKey('person_attendance_report'),
            child: PersonAttendanceReportScreen(),
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
