import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/person_list.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({
    super.key,
  });

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen>
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
    if (newPath.startsWith('/persons/all')) {
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
          title: const Text('Person'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Persons',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            PersonList(
              onTap: _handlePersonTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => AddPersonPage(),
              ),
            )
            .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handlePersonTapped(Person person) {
    _routeState.go('/person/${person.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/persons/all');
        break;
    }
  }
}
