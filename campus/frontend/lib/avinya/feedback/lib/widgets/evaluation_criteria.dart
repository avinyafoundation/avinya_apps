import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../data.dart';
import '../data/evaluation_criteria.dart';

class EvaluationCriteriaList extends StatefulWidget {
  const EvaluationCriteriaList({super.key, this.onTap});

  final ValueChanged<EvaluationCriteria>? onTap;

  @override
  _EvaluationCriteriaListState createState() =>
      _EvaluationCriteriaListState(onTap);
}

class _EvaluationCriteriaListState extends State<EvaluationCriteriaList> {
  late Future<List<EvaluationCriteria>> _futureEvaluationCriteria;
  final ValueChanged<EvaluationCriteria>? onTap;
  _EvaluationCriteriaListState(this.onTap);

  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _futureEvaluationCriteria = fetchEvaluationCriterias();
  }

  Future<List<EvaluationCriteria>> refreshEvaluationCriteriaState() async {
    _futureEvaluationCriteria = fetchEvaluationCriterias();
    return _futureEvaluationCriteria;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EvaluationCriteria>>(
      future: refreshEvaluationCriteriaState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          campusFeedbackSystemInstance.setEvaluationCriteria(snapshot.data!);
          // log(snapshot.data!.toString());
          final evaluationTypes =
              Set<String>.from(snapshot.data!.map((e) => e.evaluation_type));
          final options = ['All', ...evaluationTypes];
          return Column(
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
                    final evaluationCriteria = snapshot.data![index];
                    if (_selectedType == 'All' ||
                        _selectedType == evaluationCriteria.evaluation_type) {
                      return ListTile(
                        title: Text(evaluationCriteria.id.toString()),
                        subtitle:
                            Text(evaluationCriteria.evaluation_type ?? ''),
                        onTap: widget.onTap != null
                            ? () => widget.onTap!(evaluationCriteria)
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
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class AddEvaluationCriteriaPage extends StatefulWidget {
  static const String route = 'evaluationCriteria/add';
  const AddEvaluationCriteriaPage({super.key});

  @override
  _AddEvaluationCriteriaPageState createState() =>
      _AddEvaluationCriteriaPageState();
}

// create class _AddEvaluationCriteriaPageState
class _AddEvaluationCriteriaPageState extends State<AddEvaluationCriteriaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _prompt_Controller;
  late FocusNode _prompt_FocusNode;
  late TextEditingController _descritpion_Controller;
  late FocusNode _descritpion_FocusNode;
  late TextEditingController _expected_answer_Controller;
  late FocusNode _expected_answer_FocusNode;
  late TextEditingController _evaluation_type_Controller;
  late FocusNode _evaluation_type_FocusNode;
  late TextEditingController _difficulty_Controller;
  late FocusNode _difficulty_FocusNode;
  late TextEditingController _rating_Controller;
  late FocusNode _rating_FocusNode;

  @override
  void initState() {
    super.initState();
    _prompt_Controller = TextEditingController();
    _prompt_FocusNode = FocusNode();
    _descritpion_Controller = TextEditingController();
    _descritpion_FocusNode = FocusNode();
    _expected_answer_Controller = TextEditingController();
    _expected_answer_FocusNode = FocusNode();
    _evaluation_type_Controller = TextEditingController();
    _evaluation_type_FocusNode = FocusNode();
    _difficulty_Controller = TextEditingController();
    _difficulty_FocusNode = FocusNode();
    _rating_Controller = TextEditingController();
    _rating_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _prompt_Controller.dispose();
    _prompt_FocusNode.dispose();
    _descritpion_Controller.dispose();
    _descritpion_FocusNode.dispose();
    _expected_answer_Controller.dispose();
    _expected_answer_FocusNode.dispose();
    _evaluation_type_Controller.dispose();
    _evaluation_type_FocusNode.dispose();
    _difficulty_Controller.dispose();
    _difficulty_FocusNode.dispose();
    _rating_Controller.dispose();
    _rating_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Evaluation Criteria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                const Text(
                  'Fill in the details of the Evaluation Criteria',
                ),
                TextFormField(
                  controller: _prompt_Controller,
                  focusNode: _prompt_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Prompt',
                  ),
                  onFieldSubmitted: (_) {
                    _prompt_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _descritpion_Controller,
                  focusNode: _descritpion_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Descritpion',
                  ),
                  onFieldSubmitted: (_) {
                    _descritpion_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _expected_answer_Controller,
                  focusNode: _expected_answer_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Expected Answer',
                  ),
                  onFieldSubmitted: (_) {
                    _expected_answer_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _evaluation_type_Controller,
                  focusNode: _evaluation_type_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Evaluation Type',
                  ),
                  onFieldSubmitted: (_) {
                    _evaluation_type_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _difficulty_Controller,
                  focusNode: _difficulty_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                  ),
                  onFieldSubmitted: (_) {
                    _difficulty_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                TextFormField(
                  controller: _rating_Controller,
                  focusNode: _rating_FocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                  ),
                  onFieldSubmitted: (_) {
                    _rating_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
              ],
            )),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }
}
