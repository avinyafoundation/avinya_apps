import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/consumable_list.dart';

class ConsumableScreen extends StatefulWidget {
  const ConsumableScreen({
    super.key,
  });

  @override
  State<ConsumableScreen> createState() => _ConsumableScreenState();
}

class _ConsumableScreenState extends State<ConsumableScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    )..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/consumables/all')) {
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
          title: const Text('Consumable'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Consumables',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ConsumableList(
              onTap: _handleConsumableTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => AddConsumablePage(),
                  ),
                )
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleConsumableTapped(Consumable consumable) {
    _routeState.go('/consumable/${consumable.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/consumables/all');
        break;
    }
  }
}
