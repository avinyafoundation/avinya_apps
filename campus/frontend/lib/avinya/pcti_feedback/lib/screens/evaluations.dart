import 'package:pcti_feedback/widgets/evaluation_list.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen>
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
    if (newPath.startsWith('/evaluations/all')) {
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
          title: const Text("Evaluations"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'All Evaluations data',
                icon: Icon(Icons.list_alt),
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            EvaluationList(
              onTap: _handleEvaluationTapped,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push<void>(MaterialPageRoute<void>(
                  builder: (context) => AddEvaluationPage(), //change this
                ))
                .then((value) => setState(() {}));
          },
          child: const Icon(Icons.plus_one_sharp),
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleEvaluationTapped(Evaluation evaluation) {
    _routeState.go('/evaluation/${evaluation.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 0:
      default:
        _routeState.go('/evaluations/all');
        break;
    }
  }
}
