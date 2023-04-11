import 'package:flutter/material.dart';
import 'package:pcti_feedback/data.dart';

class PctiFeedbackList extends StatefulWidget {
  const PctiFeedbackList({super.key, this.onTap, this.pctiActivity});
  final ValueChanged<Evaluation>? onTap;
  final Activity? pctiActivity;

  @override
  // ignore: no_logic_in_create_state
  PctiFeedbackListState createState() => PctiFeedbackListState(onTap, pctiActivity);
}

class PctiFeedbackListState extends State<PctiFeedbackList> {
  late Future<List<Evaluation>> futurePctiNotes;
  final ValueChanged<Evaluation>? onTap;
  final Activity? pctiActivity;

  PctiFeedbackListState(this.onTap, this.pctiActivity);

  @override
  void initState() {
    super.initState();
    futurePctiNotes = fetchPctiActivityNotes(
        pctiActivity!.id!); // for now get notes for activity id 1
  }

  Future<List<Evaluation>> refreshPctiNoteState() async {
    futurePctiNotes = fetchPctiActivityNotes(pctiActivity!.id!);
    return futurePctiNotes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Evaluation>>(
      future: refreshPctiNoteState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusFeedbackSystemInstance.setPctiNotes(snapshot.data);
          if (snapshot.data!.length > 0) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  (snapshot.data![index].updated!.toString()),
                ),
                subtitle: Text(
                  ' ' +
                      (snapshot.data![index].notes ?? '') +
                      ' ' +
                      '' +
                      'Response' +
                      (snapshot.data![index].response ?? '') +
                      ' ',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                ),
                onTap:
                    onTap != null ? () => onTap!(snapshot.data![index]) : null,
              ),
            );
          } else {
            return Center(
                child: Text(
              "No PCTI Notes",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ));
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}


