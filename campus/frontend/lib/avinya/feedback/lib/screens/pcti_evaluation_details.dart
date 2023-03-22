// import 'package:feedbacks/src/data/evaluation.dart';
// import 'package:flutter/material.dart';

// import '../data.dart';

// class PctiEvaluationDetailsScreen extends StatelessWidget {
//   final Evaluation? pcti_evaluation;

//   const PctiEvaluationDetailsScreen({
//     super.key,
//     this.pcti_evaluation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (pcti_evaluation == null) {
//       return const Scaffold(
//           body: Center(
//         child: Text('No Evaluation found'),
//       ));
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(pcti_evaluation!.id!.toString()),
//       ),
//       body: Container(
//           padding: EdgeInsets.all(15),
//           child: Table(
//             border: TableBorder.all(
//                 width: 1, color: Colors.black45), //table border,
//             children: [
//               TableRow(children: [
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Evaluatee Id",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Evaluator_Id",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 // TableCell(
//                 //   child: Padding(
//                 //       padding: EdgeInsets.all(10),
//                 //       child: Text("Evaluation Criteria Id",
//                 //           style: TextStyle(fontWeight: FontWeight.bold))),
//                 // ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Activity Instance Id",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Grade",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Response",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text("Notes",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ),
//                 // TableCell(
//                 //   child: Padding(
//                 //       padding: EdgeInsets.all(10),
//                 //       child: Text("Updated",
//                 //           style: TextStyle(fontWeight: FontWeight.bold))),
//                 // ),
//               ]),
//               TableRow(children: [
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(pcti_evaluation!.evaluatee_id!.toString())),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(pcti_evaluation!.evaluator_id!.toString())),
//                 ),
//                 // TableCell(
//                 //   child: Padding(
//                 //       padding: EdgeInsets.all(10),
//                 //       child:
//                 //           Text(pcti_evaluation!.pcti_evaluation_criteria_id!.toString())),
//                 // ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(
//                           pcti_evaluation!.activity_instance_id!.toString())),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(pcti_evaluation!.grade!.toString())),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(pcti_evaluation!.response!.toString())),
//                 ),
//                 TableCell(
//                   child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Text(pcti_evaluation!.notes!.toString())),
//                 ),
//                 // TableCell(
//                 //   child: Padding(
//                 //       padding: EdgeInsets.all(10),
//                 //       child: Text(pcti_evaluation!.updated!.toString())),
//                 // ),
//               ]),
//             ],
//           )),

//       // body: Center(
//       //   child: Column(
//       //     children: [
//       //       Text(
//       //         pcti_evaluation!.evaluatee_id!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.evaluator_id!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.evaluation_criteria_id!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.activity_instance_id!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.grade!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.response!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.notes!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //       Text(
//       //         pcti_evaluation!.updated!.toString(),
//       //         style: Theme.of(context).textTheme.headline4,
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }
