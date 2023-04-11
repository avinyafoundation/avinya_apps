// AttendanceMarker screen class

import 'package:consumable/widgets/bulk_attedance_marker.dart';
import 'package:flutter/material.dart';
import 'package:consumable/screens/consumable_feedback.dart';
import '../routing.dart';

class BulkAttendanceMarkerScreen extends StatefulWidget {
  const BulkAttendanceMarkerScreen({Key? key}) : super(key: key);

  @override
  _BulkAttendanceMarkerScreenState createState() =>
      _BulkAttendanceMarkerScreenState();
}

class _BulkAttendanceMarkerScreenState extends State<BulkAttendanceMarkerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RouteState get _routeState => RouteStateScope.of(context);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/consumable_feedback_breakfast')) {
      _tabController.index = 0;
    } else if (newPath.startsWith('/consumable_feedback_lunch')) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        _routeState.go('/consumable_feedback_lunch');
        break;
      case 0:
      default:
        _routeState.go('/consumable_feedback_breakfast');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Food Feedback'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Breakfast',
                icon: Icon(Icons.breakfast_dining),
              ),
              Tab(
                text: 'Lunch',
                icon: Icon(Icons.lunch_dining),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ConsumableFeedbackScreen(),
            BulkAttendanceMarker(),
          ],
        ),
      );
}
