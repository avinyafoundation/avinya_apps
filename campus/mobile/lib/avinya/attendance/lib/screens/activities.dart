import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/activity_list.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({
    super.key,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/activitys/all')) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Activities',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ActivityList(
              onTap: _handleActivityTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => AddActivityPage(),
                  ),
                )
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleActivityTapped(Activity avinyaType) {
    _routeState.go('/activity/${avinyaType.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/activitys/all');
        break;
    }
  }
}
