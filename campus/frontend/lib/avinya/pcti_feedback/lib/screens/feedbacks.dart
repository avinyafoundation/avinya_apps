import 'package:flutter/material.dart';
import 'package:pcti_feedback/data.dart';
import 'package:pcti_feedback/widgets/send_feedback.dart';
import 'package:pcti_feedback/widgets/view_feedback.dart';

class FeedbackTabPageScreen extends StatefulWidget {
  final Evaluation? pctiFeedback;
  const FeedbackTabPageScreen({
    super.key,
    this.pctiFeedback,
  });
  @override
  _FeedbackTabPageScreen createState() =>
      _FeedbackTabPageScreen(this.pctiFeedback);
}

class _FeedbackTabPageScreen extends State<FeedbackTabPageScreen>
    with SingleTickerProviderStateMixin {
  late Future<Person> futureEvaluator;
  final Evaluation? pctiFeedback;
  _FeedbackTabPageScreen(this.pctiFeedback);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    futureEvaluator = fetchPersonFromPctiFeedback(pctiFeedback!.evaluator_id!);

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        setState(() {});
      });
  }

  Future<Person> refreshEvaluatorState() async {
    futureEvaluator = fetchPersonFromPctiFeedback(pctiFeedback!.evaluator_id!);
    return futureEvaluator;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 151, 181, 194),
      // title: const Text("Different FAB in Tabbar"),
      appBar: AppBar(
        title: Center(child: const Text("PCTI Feedback Details")),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: "Send Feedback",
            ),
            Tab(
              text: "View Feedback",
            ),
          ],
        ),
      ),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SendFeedbackScreen(),
          ViewFeedbackScreen(
            pctiFeedbackView: pctiFeedback,
          )
        ],
      ),
    );
  }
}
