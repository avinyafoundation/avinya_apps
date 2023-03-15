// AttendanceMarker screen class

import 'package:attendance/widgets/bulk_attedance_marker.dart';
import 'package:flutter/material.dart';
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
    if (newPath.startsWith('/bulk_attendance_marker/class1')) {
      _tabController.index = 0;
    } else if (newPath.startsWith('/bulk_attendance_marker/class2')) {
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
        _routeState.go('/bulk_attendance_marker/class2');
        break;
      case 0:
      default:
        _routeState.go('/bulk_attendance_marker/class1');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Bulk Attendance Marker'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Class 1',
                icon: Icon(Icons.list_alt),
              ),
              Tab(
                text: 'Class 2',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BulkAttendanceMarker(),
            BulkAttendanceMarker(),
          ],
        ),
      );
}
