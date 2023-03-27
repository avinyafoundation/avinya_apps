
import 'package:pcti_feedback/data/evaluation_criteria.dart';
import 'package:pcti_feedback/widgets/evaluation_criteria.dart';

import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';

class EvaluationCriteriaScreen extends StatefulWidget {
  const EvaluationCriteriaScreen({super.key});

  @override
  State<EvaluationCriteriaScreen> createState() =>
      _EvaluationCriteriaScreenState();
}

class _EvaluationCriteriaScreenState extends State<EvaluationCriteriaScreen>
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
    if (newPath.startsWith('/evaluation_criterias/all')) {
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
          title: const Text("Evaluation Criteria"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'Evaluations Criteria',
                icon: Icon(Icons.list_alt),
              ),
              Tab(
                text: 'Evaluations Criteria Details',
                icon: Icon(Icons.list),
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            EvaluationCriteriaList(
              onTap: _handleEvaluationCriteriaTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push<void>(MaterialPageRoute<void>(
                  builder: (context) => AddEvaluationCriteriaPage(),
                ))
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleEvaluationCriteriaTapped(EvaluationCriteria evaluation_criteria) {
    _routeState.go(
        '/evaluation_criteria/${evaluation_criteria.id}/${evaluation_criteria.prompt}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/evaluation_criterias/all');
        break;
    }
  }
}
