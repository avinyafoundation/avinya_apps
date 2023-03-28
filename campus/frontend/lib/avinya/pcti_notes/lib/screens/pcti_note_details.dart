import 'package:flutter/material.dart';

import '../data.dart';
import 'package:pcti_notes/data/person.dart' as person;

class PctiNoteDetail extends StatefulWidget {
  final Evaluation? pctiNote;
  const PctiNoteDetail({super.key, this.pctiNote});

  @override
  State<PctiNoteDetail> createState() => _PctiNoteDetailState(this.pctiNote);
}

class _PctiNoteDetailState extends State<PctiNoteDetail> {
  late Future<Person> futureEvaluator;
  final Evaluation? pctiNote;
  _PctiNoteDetailState(this.pctiNote);

  @override
  void initState() {
    super.initState();
    futureEvaluator =
        person.fetchPerson(pctiNote!.evaluator_id!) as Future<Person>;

    //fetchPctiActivityNotes(pctiActivity!.id!); // for now get notes for activity id 1
  }

  Future<Person> refreshEvaluatorState() async {
    futureEvaluator =
        person.fetchPerson(pctiNote!.evaluator_id!) as Future<Person>;
    return futureEvaluator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PCTI Note Details'),
        ),
        body: FutureBuilder<Person>(
          future: refreshEvaluatorState(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      pctiNote!.updated!.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        tileColor: Colors.black12,
                        title: Text("Evaluator Name"),
                        subtitle: Text(
                          snapshot.data!.preferred_name.toString(),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        tileColor: Colors.black12,
                        title: Text("Note"),
                        subtitle: Text(
                          pctiNote!.notes.toString(),
                        )),
                  ),
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
