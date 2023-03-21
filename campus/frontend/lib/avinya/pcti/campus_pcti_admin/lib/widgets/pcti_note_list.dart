import 'package:flutter/material.dart';

import '../data.dart';

class PctiNoteList extends StatefulWidget {
  const PctiNoteList({super.key, this.onTap, this.pctiActivity});
  final ValueChanged<Evaluation>? onTap;
  final Activity? pctiActivity;

  @override
  // ignore: no_logic_in_create_state
  PctiNoteListState createState() => PctiNoteListState(onTap, pctiActivity);
}


class PctiNoteListState extends State<PctiNoteList> {
  late Future<List<Evaluation>> futurePctiNotes;
  final ValueChanged<Evaluation>? onTap;
  final Activity? pctiActivity;

  PctiNoteListState(this.onTap, this.pctiActivity);

  @override
  void initState() {
    super.initState();
    futurePctiNotes = fetchPctiActivityNotes(pctiActivity!.id!); // for now get notes for activity id 1
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
          campusConfigSystemInstance.setPctiNotes(snapshot.data);
          if (snapshot.data!.length > 0){
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  (snapshot.data![index].updated!.toString()),
                ),
                subtitle: Text(
                  ' ' +
                      (snapshot.data![index].notes ?? '') +
                      ' ',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                ),
                onTap: onTap != null ? () => onTap!(snapshot.data![index]) : null,
              ),
            );
          } else {
            return Center(
              child: Text("No PCTI Notes",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
              )
            );
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
