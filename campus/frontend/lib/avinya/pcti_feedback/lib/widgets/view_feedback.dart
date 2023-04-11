import 'package:flutter/material.dart';
import '../data.dart';

class ViewFeedbackScreen extends StatefulWidget {
  final Evaluation? pctiFeedbackView;
  const ViewFeedbackScreen({super.key, this.pctiFeedbackView});

  @override
  State<ViewFeedbackScreen> createState() =>
      _ViewFeedbackScreenState(this.pctiFeedbackView);
}

class _ViewFeedbackScreenState extends State<ViewFeedbackScreen> {
  late Future<Person> futureEvaluator;
  final Evaluation? pctiFeedbackView;
  _ViewFeedbackScreenState(this.pctiFeedbackView);

  @override
  void initState() {
    super.initState();
    futureEvaluator =
        fetchPersonFromPctiFeedback(pctiFeedbackView!.evaluator_id!);

    //fetchPctiActivityNotes(pctiActivity!.id!); // for now get notes for activity id 1
  }

  Future<Person> refreshEvaluatorState() async {
    futureEvaluator =
        fetchPersonFromPctiFeedback(pctiFeedbackView!.evaluator_id!);
    return futureEvaluator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<Person>(
      future: refreshEvaluatorState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
              child: Table(
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Updated',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    pctiFeedbackView!.updated!.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Evaluator Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    snapshot.data!.preferred_name.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    pctiFeedbackView!.notes.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Response',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    pctiFeedbackView!.response.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )),
              ]),
            ],
          ));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}
