import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/vacancy_list.dart';

class VacancyScreen extends StatefulWidget {
  const VacancyScreen({
    super.key,
  });

  @override
  State<VacancyScreen> createState() => _VacancyScreenState();
}

class _VacancyScreenState extends State<VacancyScreen>
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
    if (newPath.startsWith('/tests/logical')) {
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
          title: const Text('Admission Tests'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Essays and Aptitude Test',
                icon: Icon(Icons.list_alt),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            VacancyList(
              onTap: _handleVacancyTapped,
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     Navigator.of(context)
        //         .push<void>(
        //           MaterialPageRoute<void>(
        //             builder: (context) => AddVacancyPage(),
        //           ),
        //         )
        //         .then((value) => setState(() {}));
        //   },
        //   child: const Icon(Icons.add),
        // ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleVacancyTapped(Vacancy vacancy) {
    _routeState.go('/vacancy/${vacancy.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/tests/logical');
        break;
    }
  }
}
