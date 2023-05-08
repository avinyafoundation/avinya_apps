import 'package:gallery/avinya/attendance/lib/data/evaluation.dart';
import 'package:flutter/material.dart';

class EvaluationList extends StatefulWidget {
  const EvaluationList({super.key, this.onTap});
  final ValueChanged<Evaluation>? onTap;

  @override
  EvaluationListState createState() => EvaluationListState(onTap);
}

class EvaluationListState extends State<EvaluationList> {
  late Future<List<Evaluation>> futureEvaluations;
  final ValueChanged<Evaluation>? onTap;

  EvaluationListState(this.onTap);
  String _selectedType = 'All Evaluation Criteria IDs';

  @override
  void initState() {
    super.initState();
    futureEvaluations = fetchEvaluations();
  }

  Future<List<Evaluation>> refreshEvaluationState() async {
    futureEvaluations = fetchEvaluations();
    return futureEvaluations;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Evaluation>>(
      future: refreshEvaluationState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // log(snapshot.data!.toString());
          //campusFeedbackSystemInstance.setEvaluations(snapshot.data);

          final evaluation_ID = Set<String>.from(
              snapshot.data!.map((e) => e.evaluation_criteria_id.toString()));
          final options = ['All Evaluation Criteria IDs', ...evaluation_ID];
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                items: options
                    .map((String option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final evaluation = snapshot.data![index];
                    if (_selectedType == 'All Evaluation Criteria IDs' ||
                        _selectedType ==
                            evaluation.evaluation_criteria_id.toString()) {
                      return ListTile(
                        title: Text(
                            (evaluation.evaluation_criteria_id.toString())),
                        subtitle: Text(
                            style: TextStyle(fontWeight: FontWeight.bold),
                            // 'Evaluatee Id: ' +
                            //     (snapshot.data![index].evaluatee_id!
                            //         .toString()) +
                            'Evaluator Id: ' +
                                (snapshot.data![index].evaluator_id!
                                    .toString()) +
                                'Evaluation Criteria Id: ' +
                                (snapshot.data![index].evaluation_criteria_id!
                                    .toString()) +
                                'Activity Instance Id: ' +
                                (snapshot.data![index].activity_instance_id!
                                    .toString()) +
                                // 'Response: ' +
                                // (snapshot.data![index].response ?? '') +
                                'Notes: ' +
                                (snapshot.data![index].notes ?? '')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  Navigator.of(context)
                                      .push<void>(
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              EditEvaluationPage(
                                                  evaluation:
                                                      snapshot.data![index]),
                                        ),
                                      )
                                      .then((value) => setState(() {}));
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () async {
                                  await _deleteEvaluation(
                                      snapshot.data![index]);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                        onTap: widget.onTap != null
                            ? () => widget.onTap!(evaluation)
                            : null,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> _deleteEvaluation(Evaluation evaluation) async {
    try {
      await deleteEvaluation(evaluation.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Evaluation'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
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

class DeleteEvaluationPage extends StatefulWidget {
  static const String route = '/evaluations/delete';
  final Evaluation? evaluation;
  const DeleteEvaluationPage({super.key, required this.evaluation});

  @override
  _DeleteEvaluationPageState createState() => _DeleteEvaluationPageState();
}

class _DeleteEvaluationPageState extends State<DeleteEvaluationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Evaluation'),
      ),
      body: AlertDialog(actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _deleteEvaluation(widget.evaluation!);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ]),
    );
  }

  Future<void> _deleteEvaluation(Evaluation evaluation) async {
    try {
      await deleteEvaluation(evaluation.id!.toString());
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to delete the Evaluation'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
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

class AddEvaluationPage extends StatefulWidget {
  static const String route = '/evaluations/add';
  final Evaluation? evaluation;
  const AddEvaluationPage({super.key, required this.evaluation});

  @override
  _AddEvaluationPageState createState() => _AddEvaluationPageState();
}

class _AddEvaluationPageState extends State<AddEvaluationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _evaluatee_id_Controller;
  late FocusNode _evaluatee_id_FocusNode;
  late TextEditingController _evaluator_id_Controller;
  late FocusNode _evaluator_id_FocusNode;
  late TextEditingController _evaluation_criteria_id_Controller;
  late FocusNode _evaluation_criteria_id_FocusNode;
  late TextEditingController _activity_instance_id_Controller;
  late FocusNode _activity_instance_id_FocusNode;
  // late TextEditingController _updated_Controller;
  // late FocusNode _updated_FocusNode;
  late TextEditingController _response_Controller;
  late FocusNode _response_FocusNode;
  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;
  late TextEditingController _grade_Controller;
  late FocusNode _grade_FocusNode;

  @override
  void initState() {
    super.initState();
    _evaluatee_id_Controller = TextEditingController();
    _evaluatee_id_FocusNode = FocusNode();
    _evaluator_id_Controller = TextEditingController();
    _evaluator_id_FocusNode = FocusNode();
    _evaluation_criteria_id_Controller = TextEditingController();
    _evaluation_criteria_id_FocusNode = FocusNode();
    _activity_instance_id_Controller = TextEditingController();
    _activity_instance_id_FocusNode = FocusNode();
    // _updated_Controller = TextEditingController();
    // _updated_FocusNode = FocusNode();
    _response_Controller = TextEditingController();
    _response_FocusNode = FocusNode();
    _notes_Controller = TextEditingController();
    _notes_FocusNode = FocusNode();
    _grade_Controller = TextEditingController();
    _grade_FocusNode = FocusNode();
    _evaluatee_id_Controller.text = widget.evaluation!.evaluatee_id != null
        ? widget.evaluation!.evaluatee_id!.toString()
        : '';
    _evaluator_id_Controller.text = widget.evaluation!.evaluator_id != null
        ? widget.evaluation!.evaluator_id!.toString()
        : '';
    _evaluation_criteria_id_Controller.text =
        widget.evaluation!.evaluation_criteria_id != null
            ? widget.evaluation!.evaluation_criteria_id!.toString()
            : '';
    _activity_instance_id_Controller.text =
        widget.evaluation!.activity_instance_id != null
            ? widget.evaluation!.activity_instance_id!.toString()
            : '';
    // _updated_Controller.text = widget.evaluation!.updated != null ? widget.evaluation!.updated!.toString() : '';
    _response_Controller.text = widget.evaluation!.response != null
        ? widget.evaluation!.response!.toString()
        : '';
    _notes_Controller.text = widget.evaluation!.notes != null
        ? widget.evaluation!.notes!.toString()
        : '';
    _grade_Controller.text = widget.evaluation!.grade != null
        ? widget.evaluation!.grade!.toString()
        : '';
  }

  @override
  void dispose() {
    _evaluatee_id_Controller.dispose();
    _evaluatee_id_FocusNode.dispose();
    _evaluator_id_Controller.dispose();
    _evaluator_id_FocusNode.dispose();
    _evaluation_criteria_id_Controller.dispose();
    _evaluation_criteria_id_FocusNode.dispose();
    _activity_instance_id_Controller.dispose();
    _activity_instance_id_FocusNode.dispose();
    // _updated_Controller.dispose();
    // _updated_FocusNode.dispose();
    _response_Controller.dispose();
    _response_FocusNode.dispose();
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();
    _grade_Controller.dispose();
    _grade_FocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Evaluation'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                const Text(
                    'Fill in the details of the Evaluation you want to add'),
                // TextFormField(
                //   controller: _evaluatee_id_Controller,
                //   focusNode: _evaluatee_id_FocusNode,
                //   readOnly: true,
                //   decoration: const InputDecoration(
                //     labelText: 'Evaluatee Id',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _evaluatee_id_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                // TextFormField(
                //   controller: _evaluator_id_Controller,
                //   focusNode: _evaluator_id_FocusNode,
                //   readOnly: true,
                //   decoration: const InputDecoration(
                //     labelText: 'Evaluator Id',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _evaluator_id_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                // TextFormField(
                //   controller: _activity_instance_id_Controller,
                //   focusNode: _activity_instance_id_FocusNode,
                //   readOnly: true,
                //   decoration: const InputDecoration(
                //     labelText: 'Activity Instance id',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _activity_instance_id_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                // TextFormField(
                //   controller: _evaluation_criteria_id_Controller,
                //   focusNode: _evaluation_criteria_id_FocusNode,
                //   readOnly: true,
                //   decoration: const InputDecoration(
                //     labelText: 'Evaluation_criteria_id',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _evaluation_criteria_id_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                DropdownButton<String>(
                  items: <String>[
                    'Unexcused absence',
                    'Illness',
                    'Medical appointment',
                    'Family emergency',
                    'Bereavement',
                    'Mental health',
                    'Religious observance',
                    'School-related activities',
                    'Personal or family vacation',
                    'Transportation issues',
                    'Weather-related issues',
                    'Suspensions or disciplinary actions',
                    'Lack of parental supervision or support',
                    'Childcare responsibilities',
                    'Work or financial commitments',
                    'Educational neglect',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: _response_Controller.text,
                  onChanged: (String? newValue) {
                    setState(() {
                      _response_Controller.text = newValue!;
                    });
                  },
                ),
                // TextFormField(
                //   controller: _response_Controller,
                //   focusNode: _response_FocusNode,
                //   decoration: const InputDecoration(
                //     labelText: 'Response',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _response_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                TextFormField(
                  controller: _notes_Controller,
                  focusNode: _notes_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                  onFieldSubmitted: (_) {
                    _notes_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                // TextFormField(
                //   controller: _grade_Controller,
                //   focusNode: _grade_FocusNode,
                //   decoration: const InputDecoration(
                //     labelText: 'Grade',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _grade_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _addEvaluation(context);
          },
          child: const Icon(Icons.save),
        ));
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _addEvaluation(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Evaluation evaluation = Evaluation(
            evaluatee_id: int.parse(_evaluatee_id_Controller.text),
            evaluator_id: int.parse(_evaluator_id_Controller.text),
            evaluation_criteria_id:
                int.parse(_evaluation_criteria_id_Controller.text),
            activity_instance_id:
                int.parse(_activity_instance_id_Controller.text),
            response: _response_Controller.text,
            notes: _notes_Controller.text,
            grade: int.parse(_grade_Controller.text));
        await createEvaluation([evaluation]);
        Navigator.of(context).pop();
      }
    } on Exception {
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Error'),
                content: const Text('There was an error adding the Evaluation'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  )
                ],
              ));
    }
  }
}

// class AddEvaluationPage extends StatefulWidget {
//   static const String route = '/pcti_evaluation/new';
//   const AddEvaluationPage({super.key});
//   @override
//   _AddEvaluationPageState createState() => _AddEvaluationPageState();
// }

// class _AddEvaluationPageState extends State<AddEvaluationPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late TextEditingController _evaluatee_id_Controller;
//   late FocusNode _evaluatee_id_FocusNode;
//   late TextEditingController _evaluator_id_Controller;
//   late FocusNode _evaluator_id_FocusNode;
//   late TextEditingController _evaluation_criteria_id_Controller;
//   late FocusNode _evaluation_criteria_id_FocusNode;
//   late TextEditingController _activity_instance_id_Controller;
//   late FocusNode _activity_instance_id_FocusNode;
//   late TextEditingController _response_Controller;
//   late FocusNode _response_FocusNode;
//   late TextEditingController _notes_Controller;
//   late FocusNode _notes_FocusNode;
//   late TextEditingController _grade_Controller;
//   late FocusNode _grade_FocusNode;

//   @override
//   void initState() {
//     super.initState();
//     _evaluatee_id_Controller = TextEditingController();
//     _evaluatee_id_FocusNode = FocusNode();
//     _evaluator_id_Controller = TextEditingController();
//     _evaluator_id_FocusNode = FocusNode();
//     _evaluation_criteria_id_Controller = TextEditingController();
//     _evaluation_criteria_id_FocusNode = FocusNode();
//     _activity_instance_id_Controller = TextEditingController();
//     _activity_instance_id_FocusNode = FocusNode();
//     _response_Controller = TextEditingController();
//     _response_FocusNode = FocusNode();
//     _notes_Controller = TextEditingController();
//     _notes_FocusNode = FocusNode();
//     _grade_Controller = TextEditingController();
//     _grade_FocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _evaluatee_id_Controller.dispose();
//     _evaluatee_id_FocusNode.dispose();
//     _evaluator_id_Controller.dispose();
//     _evaluator_id_FocusNode.dispose();
//     _evaluation_criteria_id_Controller.dispose();
//     _evaluation_criteria_id_FocusNode.dispose();
//     _activity_instance_id_Controller.dispose();
//     _activity_instance_id_FocusNode.dispose();
//     _response_Controller.dispose();
//     _response_FocusNode.dispose();
//     _notes_Controller.dispose();
//     _notes_FocusNode.dispose();
//     _grade_Controller.dispose();
//     _grade_FocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PCTI Evaluation'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             children: <Widget>[
//               const Text(
//                   'Fill in the details of the Pcti Evaluation you want to add'),
//               TextFormField(
//                 controller: _evaluatee_id_Controller,
//                 focusNode: _evaluatee_id_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Evaluatee Id',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _evaluatee_id_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//               TextFormField(
//                 controller: _evaluator_id_Controller,
//                 focusNode: _evaluator_id_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Evaluator Id',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _evaluator_id_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//               TextFormField(
//                 controller: _activity_instance_id_Controller,
//                 focusNode: _activity_instance_id_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Activity Instance Id',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _activity_instance_id_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//               TextFormField(
//                 controller: _grade_Controller,
//                 focusNode: _grade_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Grade',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _grade_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//               TextFormField(
//                 controller: _response_Controller,
//                 focusNode: _response_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Response',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _response_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//               TextFormField(
//                 controller: _notes_Controller,
//                 focusNode: _notes_FocusNode,
//                 decoration: const InputDecoration(
//                   labelText: 'Notes',
//                 ),
//                 onFieldSubmitted: (_) {
//                   _notes_FocusNode.requestFocus();
//                 },
//                 validator: _mandatoryValidator,
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await _addEvaluation(context);
//         },
//         child: const Icon(Icons.save_sharp),
//       ),
//     );
//   }

//   String? _mandatoryValidator(String? text) {
//     return (text!.isEmpty) ? 'Required' : null;
//   }

//   Future<void> _addEvaluation(BuildContext context) async {
//     try {
//       if (_formKey.currentState!.validate()) {
//         final Evaluation evaluation = Evaluation(
//             evaluatee_id: int.parse(_evaluatee_id_Controller.text),
//             evaluator_id: int.parse(_evaluator_id_Controller.text),
//             // evaluation_criteria_id:
//             //     int.parse(_evaluation_criteria_id_Controller.text),
//             activity_instance_id:
//                 int.parse(_activity_instance_id_Controller.text),
//             grade: int.parse(_grade_Controller.text),
//             notes: _notes_Controller.text,
//             response: _response_Controller.text);
//         await createEvaluation([evaluation]);
//         Navigator.of(context).pop(true);
//       }
//     } on Exception {
//       await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           content: const Text('Failed to add Evaluations'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             )
//           ],
//         ),
//       );
//     }
//   }
// }

class EditEvaluationPage extends StatefulWidget {
  static const String route = 'evaluation/edit';
  final Evaluation evaluation;
  const EditEvaluationPage({super.key, required this.evaluation});
  @override
  _EditEvaluationPageState createState() => _EditEvaluationPageState();
}

class _EditEvaluationPageState extends State<EditEvaluationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _evaluatee_id_Controller;
  late FocusNode _evaluatee_id_FocusNode;
  late TextEditingController _evaluator_id_Controller;
  late FocusNode _evaluator_id_FocusNode;
  late TextEditingController _evaluation_criteria_id_Controller;
  late FocusNode _evaluation_criteria_id_FocusNode;
  late TextEditingController _activity_instance_id_Controller;
  late FocusNode _activity_instance_id_FocusNode;
  late TextEditingController _response_Controller;
  late FocusNode _response_FocusNode;
  late TextEditingController _notes_Controller;
  late FocusNode _notes_FocusNode;
  late TextEditingController _grade_Controller;
  late FocusNode _grade_FocusNode;

  @override
  void initState() {
    super.initState();
    final Evaluation evaluation = widget.evaluation;
    _evaluatee_id_Controller =
        TextEditingController(text: evaluation.evaluatee_id.toString());
    _evaluatee_id_FocusNode = FocusNode();
    _evaluator_id_Controller =
        TextEditingController(text: evaluation.evaluator_id.toString());
    _evaluator_id_FocusNode = FocusNode();
    _evaluation_criteria_id_Controller = TextEditingController(
        text: evaluation.evaluation_criteria_id.toString());
    _evaluation_criteria_id_FocusNode = FocusNode();
    _activity_instance_id_Controller =
        TextEditingController(text: evaluation.activity_instance_id.toString());
    _activity_instance_id_FocusNode = FocusNode();
    _response_Controller = TextEditingController(text: evaluation.response);
    _response_FocusNode = FocusNode();
    _notes_Controller = TextEditingController(text: evaluation.notes);
    _notes_FocusNode = FocusNode();
    _grade_Controller =
        TextEditingController(text: evaluation.grade.toString());
    _grade_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _evaluatee_id_Controller.dispose();
    _evaluatee_id_FocusNode.dispose();
    _evaluator_id_Controller.dispose();
    _evaluator_id_FocusNode.dispose();
    _evaluation_criteria_id_Controller.dispose();
    _evaluation_criteria_id_FocusNode.dispose();
    _activity_instance_id_Controller.dispose();
    _activity_instance_id_FocusNode.dispose();
    _response_Controller.dispose();
    _response_FocusNode.dispose();
    _notes_Controller.dispose();
    _notes_FocusNode.dispose();
    _grade_Controller.dispose();
    _grade_FocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evaluation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text(
                  'Fill in the details of the Evaluation you want to edit'),
              DropdownButton<String>(
                items: <String>[
                  'Unexcused absence',
                  'Illness',
                  'Medical appointment',
                  'Family emergency',
                  'Bereavement',
                  'Mental health',
                  'Religious observance',
                  'School-related activities',
                  'Personal or family vacation',
                  'Transportation issues',
                  'Weather-related issues',
                  'Suspensions or disciplinary actions',
                  'Lack of parental supervision or support',
                  'Childcare responsibilities',
                  'Work or financial commitments',
                  'Educational neglect',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: _response_Controller.text,
                onChanged: (String? newValue) {
                  setState(() {
                    _response_Controller.text = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _notes_Controller,
                decoration: const InputDecoration(labelText: 'Notes'),
                onFieldSubmitted: (_) {
                  _notes_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _editEvaluation(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  Future<void> _editEvaluation(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Evaluation evaluation = Evaluation(
            id: widget.evaluation.id,
            evaluatee_id: int.parse(_evaluatee_id_Controller.text),
            evaluator_id: int.parse(_evaluator_id_Controller.text),
            evaluation_criteria_id:
                int.parse(_evaluation_criteria_id_Controller.text),
            activity_instance_id:
                int.parse(_activity_instance_id_Controller.text),
            grade: int.parse(_grade_Controller.text),
            response: _response_Controller.text,
            notes: _notes_Controller.text);

        await updateEvaluation(evaluation);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: const Text('Failed to edit evaluation'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  )
                ],
              ));
    }
  }
}
