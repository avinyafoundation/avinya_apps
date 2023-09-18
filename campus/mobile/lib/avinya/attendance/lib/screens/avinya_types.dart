import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/avinya_type_list.dart';

class AvinyaTypeScreen extends StatefulWidget {
  const AvinyaTypeScreen({
    super.key,
  });

  @override
  State<AvinyaTypeScreen> createState() => _AvinyaTypeScreenState();
}

class _AvinyaTypeScreenState extends State<AvinyaTypeScreen>
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
    if (newPath.startsWith('/avinya_types/all')) {
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
          title: const Text('AvinyaType'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All AvinyaTypes',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AvinyaTypeList(
              onTap: _handleAvinyaTypeTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => AddAvinyaTypePage(),
              ),
            )
            .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleAvinyaTypeTapped(AvinyaType avinyaType) {
    _routeState.go('/avinya_type/${avinyaType.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/avinya_types/all');
        break;
    }
  }
}
