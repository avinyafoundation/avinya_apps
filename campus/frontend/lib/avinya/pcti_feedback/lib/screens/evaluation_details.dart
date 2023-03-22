import 'package:flutter/material.dart';

import '../data.dart';

class EvaluationDetailsScreen extends StatelessWidget {
  final Evaluation? evaluation;

  const EvaluationDetailsScreen({
    super.key,
    this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    if (evaluation == null) {
      return const Scaffold(
          body: Center(
        child: Text('No Evaluation found'),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(evaluation!.id!.toString()),
      ),
      // body: Container(
      //   padding: EdgeInsets.all(5),
      //   child: Column(children: [
      //     Text(
      //       evaluation!.notes!.toString(),
      //       style: Theme.of(context).textTheme.headline4,
      //     ),
      //     Text("oook")
      //   ]),
      // ),
      body: Container(
          padding: EdgeInsets.all(5),
          child: Table(
            border: TableBorder.all(
                width: 1.5, color: Colors.black45), //table border,
            children: [
              TableRow(children: [
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(2),
                //       child: Text("Evaluatee Id",
                //           style: TextStyle(fontWeight: FontWeight.bold))),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("Evaluator_Id",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(10),
                //       child: Text("Evaluation Criteria Id",
                //           style: TextStyle(fontWeight: FontWeight.bold))),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Activity Instance Id",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Grade",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(10),
                //       child: Text("Response",
                //           style: TextStyle(fontWeight: FontWeight.bold))),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Notes",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Updated",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ]),
              TableRow(children: [
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(10),
                //       child: Text(evaluation!.evaluatee_id!.toString())),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(evaluation!.evaluator_id!.toString())),
                ),
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(10),
                //       child:
                //           Text(evaluation!.evaluation_criteria_id!.toString())),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child:
                          Text(evaluation!.activity_instance_id!.toString())),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(evaluation!.grade!.toString())),
                ),
                // TableCell(
                //   child: Padding(
                //       padding: EdgeInsets.all(10),
                //       child: Text(evaluation!.response!.toString())),
                // ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(evaluation!.notes!.toString())),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(evaluation!.updated!.toString())),
                ),
              ]),
            ],
          )),

      // body: Center(
      //   child: Column(
      //     children: [
      //       Text(
      //         evaluation!.evaluatee_id!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.evaluator_id!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.evaluation_criteria_id!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.activity_instance_id!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.grade!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.response!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.notes!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       Text(
      //         evaluation!.updated!.toString(),
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
