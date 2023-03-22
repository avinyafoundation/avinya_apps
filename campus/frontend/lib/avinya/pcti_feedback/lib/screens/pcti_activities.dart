import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/pcti_activity_details.dart';

class PctiActivitiesScreen extends StatefulWidget {
  const PctiActivitiesScreen({
    super.key,
  });

  @override
  State<PctiActivitiesScreen> createState() => _PctiActivitiesScreenState();
}

class _PctiActivitiesScreenState extends State<PctiActivitiesScreen>
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
    if (newPath.startsWith('/pcti_activities')) {
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
          title: const Text('PCTI Activities'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All PCTI Activities',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SelectPctiActivityPage(
              onTap: _handleActivitySelected,
            ),
          ],
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);


  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/pcti_activities');
        break;
    }
  }

  void _handleActivitySelected(Activity activity) {
    _routeState.go('/pcti_activities/${activity.id}');
  }
}


