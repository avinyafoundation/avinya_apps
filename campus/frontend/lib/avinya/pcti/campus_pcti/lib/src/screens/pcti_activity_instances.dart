import 'package:flutter/material.dart';

import '../routing.dart';
import '../widgets/pcti_activity_instance_details.dart';

class PctiActivityInstancesScreen extends StatefulWidget {
  const PctiActivityInstancesScreen({super.key});

  @override
  State<PctiActivityInstancesScreen> createState() => _PctiActivityInstancesScreenState();
}

class _PctiActivityInstancesScreenState extends State<PctiActivityInstancesScreen>
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
    if (newPath.startsWith('/pcti_activity_instances')) {
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
          title: const Text('Activity Instances'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Activity Instances',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SelectPctiActivityInstancePage(),
          ],
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);


  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/avinya_types/all');
        break;
    }
  }
}
