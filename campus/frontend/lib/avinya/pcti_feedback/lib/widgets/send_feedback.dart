import 'package:flutter/material.dart';

import '../data.dart';

class SendFeedbackScreen extends StatefulWidget {
  final Evaluation? evaluation;
  const SendFeedbackScreen({super.key, this.evaluation});

  @override
  _SendFeedbackScreenState createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _evaluatee_id_Controller;
  late FocusNode _evaluatee_id_FocusNode;
  late TextEditingController _evaluator_id_Controller;
  late FocusNode _evaluator_id_FocusNode;
  late TextEditingController _evaluation_criteria_id_Controller;
  late FocusNode _evaluation_criteria_id_FocusNode;
  // late TextEditingController _activity_instance_id_Controller;
  // late FocusNode _activity_instance_id_FocusNode;
  // late TextEditingController _updated_Controller;
  // late FocusNode _updated_FocusNode;
  late TextEditingController _response_Controller;
  late FocusNode _response_FocusNode;
  // late TextEditingController _notes_Controller;
  // late FocusNode _notes_FocusNode;
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
    // _activity_instance_id_Controller = TextEditingController();
    // _activity_instance_id_FocusNode = FocusNode();
    // _updated_Controller = TextEditingController();
    // _updated_FocusNode = FocusNode();
    _response_Controller = TextEditingController();
    _response_FocusNode = FocusNode();
    // _notes_Controller = TextEditingController();
    // _notes_FocusNode = FocusNode();
    _grade_Controller = TextEditingController();
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
    // _activity_instance_id_Controller.dispose();
    // _activity_instance_id_FocusNode.dispose();
    // _updated_Controller.dispose();
    // _updated_FocusNode.dispose();
    _response_Controller.dispose();
    _response_FocusNode.dispose();
    // _notes_Controller.dispose();
    // _notes_FocusNode.dispose();
    _grade_Controller.dispose();
    _grade_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Add Evaluation'),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _evaluatee_id_Controller,
                  focusNode: _evaluatee_id_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Evaluatee Id',
                  ),
                  onFieldSubmitted: (_) {
                    _evaluatee_id_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                // TextFormField(
                //   controller: _evaluator_id_Controller,
                //   focusNode: _evaluator_id_FocusNode,
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
                //   decoration: const InputDecoration(
                //     labelText: 'Activity Instance id',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _activity_instance_id_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                TextFormField(
                  controller: _evaluation_criteria_id_Controller,
                  focusNode: _evaluation_criteria_id_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Evaluation_criteria_id',
                  ),
                  onFieldSubmitted: (_) {
                    _evaluation_criteria_id_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _response_Controller,
                  focusNode: _response_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Response',
                  ),
                  onFieldSubmitted: (_) {
                    _response_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                // TextFormField(
                //   controller: _notes_Controller,
                //   focusNode: _notes_FocusNode,
                //   decoration: const InputDecoration(
                //     labelText: 'Notes',
                //   ),
                //   onFieldSubmitted: (_) {
                //     _notes_FocusNode.requestFocus();
                //   },
                //   validator: _mandatoryValidator,
                // ),
                TextFormField(
                  controller: _grade_Controller,
                  focusNode: _grade_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                  ),
                  onFieldSubmitted: (_) {
                    _grade_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _addEvaluation(context);
          },
          child: const Icon(Icons.send),
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
            evaluator_id: campusAppsPortalInstance.getUserPerson().id!,
            evaluation_criteria_id:
                int.parse(_evaluation_criteria_id_Controller.text),
            // activity_instance_id:
            //     int.parse(_activity_instance_id_Controller.text),
            response: _response_Controller.text,
            // notes: _notes_Controller.text,
            grade: int.parse(_grade_Controller.text));
        await createEvaluation([evaluation]);
        Navigator.of(context).pop(true);
      }
    } on Exception {
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Error'),
                content: const Text('There was an error Send a Feedback'),
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
