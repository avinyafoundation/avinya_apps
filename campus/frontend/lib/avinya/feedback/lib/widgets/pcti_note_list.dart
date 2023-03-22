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
                  ' ' + (snapshot.data![index].notes ?? '') + ' ',
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

class AddPctiNotePage extends StatefulWidget {
  static const String route = '/pcti_note/add';
  final ActivityInstance? pctiActivityInstance;

  const AddPctiNotePage({super.key, this.pctiActivityInstance});
  @override
  _AddPctiNotePageState createState() =>
      _AddPctiNotePageState(this.pctiActivityInstance);
}

class _AddPctiNotePageState extends State<AddPctiNotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ActivityInstance? pctiActivityInstance;

  late TextEditingController _note_Controller;
  late FocusNode _note_FocusNode;
  _AddPctiNotePageState(this.pctiActivityInstance);

  @override
  void initState() {
    super.initState();
    _note_Controller = TextEditingController();
    _note_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _note_Controller.dispose();
    _note_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add PCTI Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Type your PCTI Note below'),
              TextFormField(
                controller: _note_Controller,
                decoration: const InputDecoration(labelText: 'PCTI Note'),
                onFieldSubmitted: (_) {
                  _note_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addPctiNote(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addPctiNote(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Evaluation pctiNote = Evaluation(
            notes: _note_Controller.text, //evaluator_id:
            activity_instance_id: pctiActivityInstance!.id!);
        await createPctiNote(pctiNote);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add PctiNote'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }
}
