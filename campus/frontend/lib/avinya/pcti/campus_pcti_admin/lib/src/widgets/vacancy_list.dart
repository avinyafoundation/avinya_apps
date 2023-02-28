import 'dart:developer';

import 'package:ShoolManagementSystem/src/data/evaluation.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';

class VacancyList extends StatefulWidget {
  const VacancyList({super.key, this.onTap});
  final ValueChanged<Vacancy>? onTap;

  @override
  // ignore: no_logic_in_create_state
  VacancyListState createState() => VacancyListState(onTap);
}

class VacancyListState extends State<VacancyList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Vacancy>>? futureVacancys;
  final ValueChanged<Vacancy>? onTap;
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  var lengths = [0, 0];
  var answers = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
  var criteriaIds = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool doneOL = false;

  _onChanged0(String value) {
    setState(() {
      lengths[0] = value.length;
      answers[0] = value;
    });
  }

  _onChanged1(String value) {
    setState(() {
      lengths[1] = value.length;
      answers[1] = value;
    });
  }

  VacancyListState(this.onTap);

  @override
  void initState() {
    super.initState();
    try {
      futureVacancys = fetchVacancies();
      campusConfigSystemInstance.setVacancies(futureVacancys!);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<Vacancy>> refreshVacancyState() async {
    //futureVacancys = fetchVacancies();
    futureVacancys = campusConfigSystemInstance.getVacancies();
    if (futureVacancys == null) {
      futureVacancys = fetchVacancies();
      campusConfigSystemInstance.setVacancies(futureVacancys!);
    }
    return futureVacancys!;
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    return FutureBuilder<List<Vacancy>>(
      future: refreshVacancyState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //admissionSystemInstance.setVacancies(snapshot.data);
          List<Vacancy>? vacancies = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Please answer all questions below',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vacancies!
                              .map((vacancy) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: vacancy.evaluation_criteria
                                      .map((ec) => Row(children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if ((criteriaIds[vacancy
                                                          .evaluation_criteria
                                                          .indexOf(
                                                              ec)] = ec.id!) >
                                                      0)
                                                    Container(
                                                      width: 250,
                                                      child: Wrap(children: [
                                                        Text(
                                                          ec.prompt!,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          // softWrap: true,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  if (ec.evalualtion_type ==
                                                      'Essay')
                                                    if (vacancy.evaluation_criteria
                                                                .indexOf(ec) %
                                                            2 ==
                                                        0)
                                                      Container(
                                                          width: 380,
                                                          height: 300,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: TextField(
                                                            controller:
                                                                textController1,
                                                            autocorrect: true,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Type your essay here'),
                                                            onChanged:
                                                                _onChanged0,
                                                            maxLength: 640,
                                                            maxLines: 10,
                                                          )),
                                                  if (ec.evalualtion_type ==
                                                      'Essay')
                                                    if (vacancy.evaluation_criteria
                                                                .indexOf(ec) %
                                                            2 ==
                                                        1)
                                                      Container(
                                                          width: 380,
                                                          height: 300,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: TextField(
                                                            controller:
                                                                textController2,
                                                            autocorrect: true,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Type your essay here'),
                                                            onChanged:
                                                                _onChanged1,
                                                            maxLength: 640,
                                                            maxLines: 10,
                                                          )),
                                                  if (ec.evalualtion_type ==
                                                      'Multiple Choice')
                                                    Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: ec
                                                                  .answer_options
                                                                  .map((option) =>
                                                                      Row(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8),
                                                                              child: SizedBox(
                                                                                width: 10,
                                                                                //height: 10,
                                                                                child: Radio(
                                                                                  value: option.answer!,
                                                                                  groupValue: answers[vacancy.evaluation_criteria.indexOf(ec)],
                                                                                  activeColor: Colors.orange,
                                                                                  onChanged: (ans) {
                                                                                    //value may be true or false
                                                                                    setState(() {
                                                                                      answers[vacancy.evaluation_criteria.indexOf(ec)] = '${option.answer!}';
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            // SizedBox(
                                                                            //   height: 40.0,
                                                                            // child:
                                                                            Text(option.answer!),
                                                                            //),
                                                                          ]))
                                                                  .toList()),
                                                          SizedBox(
                                                              width: 10.0,
                                                              height: 10.0),
                                                        ]),
                                                ]),
                                          ]))
                                      .toList()))
                              .toList(),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                                bool successPostingEvaluation =
                                    await addSudentApplicantEvaluation(context);
                                if (successPostingEvaluation) {
                                  await routeState.go('/application');
                                } else {
                                  routeState.go('/signin');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Some of the data you entred on this form ' +
                                          'does not meet the eligibility criteria.\r\n' +
                                          'The errors are shown inline on the form.\r\n' +
                                          'Please check and correct the data and try again.',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                        left: 100.0,
                                        right: 100.0,
                                        bottom: 100.0),
                                    duration: Duration(seconds: 5),
                                    backgroundColor: Colors.yellow,
                                  ),
                                );
                              }
                            },
                            child: Text('Submit'))
                      ]),
                )),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<bool> addSudentApplicantEvaluation(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        campusConfigSystemInstance
            .fetchPersonForUser(); // do a fetch to help cross check
        Person person = campusConfigSystemInstance.getStudentPerson();
        if (campusConfigSystemInstance.getJWTSub() != person.jwt_sub_id) {
          // the person has not logged in to the system
          // we can record the test responses against that person
          return false;
        }
        log('addSudentApplicantEvaluation valid');
        log(answers.toString());
        log(criteriaIds.toString());
        List<Evaluation> evaluations = [];
        answers.forEach((element) {
          if (element != '') {
            evaluations.add(Evaluation(
                evaluation_criteria_id: criteriaIds[answers.indexOf(element)],
                response: element,
                evaluatee_id: person.id,
                evaluator_id: person.id,
                notes: 'Student Test Evaluation',
                grade: -1));
          }
        });
        log('vacancy list :' + evaluations.toString());
        evaluations.forEach((element) {
          log('vacancy list loop elements:' + element.toString());
          log(element.toJson().toString());
        });

        final createEvaluationsResponse = await createEvaluation(evaluations);

        log(createEvaluationsResponse.body.toString());
        return true;
        //Navigator.of(context).pop(true);

      } else {
        log('addSudentApplicantEvaluation invalid');
        return false;
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to submit the student application form'),
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
      return false;
    }
  }
}

class AddVacancyPage extends StatefulWidget {
  static const String route = '/vacancy/add';
  const AddVacancyPage({super.key});
  @override
  _AddVacancyPageState createState() => _AddVacancyPageState();
}

class _AddVacancyPageState extends State<AddVacancyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _avinya_type_id_Controller;
  late FocusNode _avinya_type_id_FocusNode;
  late TextEditingController _evaluation_cycle_id_Controller;
  late FocusNode _evaluation_cycle_id_FocusNode;
  late TextEditingController _head_count_Controller;
  late FocusNode _head_count_FocusNode;
  late TextEditingController _avinya_type_Controller;
  late FocusNode _avinya_type_FocusNode;
  late TextEditingController _evaluation_criteria_Controller;
  late FocusNode _evaluation_criteria_FocusNode;

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController();
    _description_FocusNode = FocusNode();
    _organization_id_Controller = TextEditingController();
    _organization_id_FocusNode = FocusNode();
    _avinya_type_id_Controller = TextEditingController();
    _avinya_type_id_FocusNode = FocusNode();
    _evaluation_cycle_id_Controller = TextEditingController();
    _evaluation_cycle_id_FocusNode = FocusNode();
    _head_count_Controller = TextEditingController();
    _head_count_FocusNode = FocusNode();
    _avinya_type_Controller = TextEditingController();
    _avinya_type_FocusNode = FocusNode();
    _evaluation_criteria_Controller = TextEditingController();
    _evaluation_criteria_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _organization_id_Controller.dispose();
    _organization_id_FocusNode.dispose();
    _avinya_type_id_Controller.dispose();
    _avinya_type_id_FocusNode.dispose();
    _evaluation_cycle_id_Controller.dispose();
    _evaluation_cycle_id_FocusNode.dispose();
    _head_count_Controller.dispose();
    _head_count_FocusNode.dispose();
    _avinya_type_Controller.dispose();
    _avinya_type_FocusNode.dispose();
    _evaluation_criteria_Controller.dispose();
    _evaluation_criteria_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacancy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Vacancy you want to add'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _description_Controller,
                decoration: const InputDecoration(labelText: 'description'),
                onFieldSubmitted: (_) {
                  _description_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_id_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type_id'),
                onFieldSubmitted: (_) {
                  _avinya_type_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _evaluation_cycle_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'evaluation_cycle_id'),
                onFieldSubmitted: (_) {
                  _evaluation_cycle_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _head_count_Controller,
                decoration: const InputDecoration(labelText: 'head_count'),
                onFieldSubmitted: (_) {
                  _head_count_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type'),
                onFieldSubmitted: (_) {
                  _avinya_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _evaluation_criteria_Controller,
                decoration:
                    const InputDecoration(labelText: 'evaluation_criteria'),
                onFieldSubmitted: (_) {
                  _evaluation_criteria_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //await _addVacancy(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

//   Future<void> _addVacancy(BuildContext context) async {
//     try {
//       if (_formKey.currentState!.validate()) {
//         final Vacancy vacancy = Vacancy(
//           name: _name_Controller.text,
//           description: _description_Controller.text,
//           organization_id: int.parse(_organization_id_Controller.text),
//           avinya_type_id: int.parse(_avinya_type_id_Controller.text),
//           evaluation_cycle_id: int.parse(_evaluation_cycle_id_Controller.text),
//           head_count: int.parse(_head_count_Controller.text),
//           //avinya_type: _avinya_type_Controller.text,
//           //evaluation_criteria: _evaluation_criteria_Controller.text,
//         );
//         //await createVacancy(vacancy);
//         Navigator.of(context).pop(true);
//       }
//     } on Exception {
//       await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           content: const Text('Failed to add Vacancy'),
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
}

class EditVacancyPage extends StatefulWidget {
  static const String route = 'vacancy/edit';
  final Vacancy vacancy;
  const EditVacancyPage({super.key, required this.vacancy});
  @override
  _EditVacancyPageState createState() => _EditVacancyPageState();
}

class _EditVacancyPageState extends State<EditVacancyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _description_Controller;
  late FocusNode _description_FocusNode;
  late TextEditingController _organization_id_Controller;
  late FocusNode _organization_id_FocusNode;
  late TextEditingController _avinya_type_id_Controller;
  late FocusNode _avinya_type_id_FocusNode;
  late TextEditingController _evaluation_cycle_id_Controller;
  late FocusNode _evaluation_cycle_id_FocusNode;
  late TextEditingController _head_count_Controller;
  late FocusNode _head_count_FocusNode;
  late TextEditingController _avinya_type_Controller;
  late FocusNode _avinya_type_FocusNode;
  late TextEditingController _evaluation_criteria_Controller;
  late FocusNode _evaluation_criteria_FocusNode;
  @override
  void initState() {
    super.initState();
    final Vacancy vacancy = widget.vacancy;
    _name_Controller = TextEditingController(text: vacancy.name);
    _name_FocusNode = FocusNode();
    _description_Controller = TextEditingController(text: vacancy.description);
    _description_FocusNode = FocusNode();
    _organization_id_Controller =
        TextEditingController(text: vacancy.organization_id.toString());
    _organization_id_FocusNode = FocusNode();
    _avinya_type_id_Controller =
        TextEditingController(text: vacancy.avinya_type_id.toString());
    _avinya_type_id_FocusNode = FocusNode();
    _evaluation_cycle_id_Controller =
        TextEditingController(text: vacancy.evaluation_cycle_id.toString());
    _evaluation_cycle_id_FocusNode = FocusNode();
    _head_count_Controller =
        TextEditingController(text: vacancy.head_count.toString());
    _head_count_FocusNode = FocusNode();
    _avinya_type_Controller =
        TextEditingController(text: vacancy.avinya_type.toString());
    _avinya_type_FocusNode = FocusNode();
    _evaluation_criteria_Controller =
        TextEditingController(text: vacancy.evaluation_criteria.toString());
    _evaluation_criteria_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _description_Controller.dispose();
    _description_FocusNode.dispose();
    _organization_id_Controller.dispose();
    _organization_id_FocusNode.dispose();
    _avinya_type_id_Controller.dispose();
    _avinya_type_id_FocusNode.dispose();
    _evaluation_cycle_id_Controller.dispose();
    _evaluation_cycle_id_FocusNode.dispose();
    _head_count_Controller.dispose();
    _head_count_FocusNode.dispose();
    _avinya_type_Controller.dispose();
    _avinya_type_FocusNode.dispose();
    _evaluation_criteria_Controller.dispose();
    _evaluation_criteria_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacancy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              const Text('Fill in the details of the Vacancy you want to edit'),
              TextFormField(
                controller: _name_Controller,
                decoration: const InputDecoration(labelText: 'name'),
                onFieldSubmitted: (_) {
                  _name_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _description_Controller,
                decoration: const InputDecoration(labelText: 'description'),
                onFieldSubmitted: (_) {
                  _description_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _organization_id_Controller,
                decoration: const InputDecoration(labelText: 'organization_id'),
                onFieldSubmitted: (_) {
                  _organization_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_id_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type_id'),
                onFieldSubmitted: (_) {
                  _avinya_type_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _evaluation_cycle_id_Controller,
                decoration:
                    const InputDecoration(labelText: 'evaluation_cycle_id'),
                onFieldSubmitted: (_) {
                  _evaluation_cycle_id_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _head_count_Controller,
                decoration: const InputDecoration(labelText: 'head_count'),
                onFieldSubmitted: (_) {
                  _head_count_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _avinya_type_Controller,
                decoration: const InputDecoration(labelText: 'avinya_type'),
                onFieldSubmitted: (_) {
                  _avinya_type_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
              TextFormField(
                controller: _evaluation_criteria_Controller,
                decoration:
                    const InputDecoration(labelText: 'evaluation_criteria'),
                onFieldSubmitted: (_) {
                  _evaluation_criteria_FocusNode.requestFocus();
                },
                validator: _mandatoryValidator,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //await _editVacancy(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  // Future<void> _editVacancy(BuildContext context) async {
  //   try {
  //     if (_formKey.currentState!.validate()) {
  //       final Vacancy vacancy = Vacancy(
  //         id: widget.vacancy.id,
  //         name: _name_Controller.text,
  //         description: _description_Controller.text,
  //         organization_id: int.parse(_organization_id_Controller.text),
  //         avinya_type_id: int.parse(_avinya_type_id_Controller.text),
  //         evaluation_cycle_id: int.parse(_evaluation_cycle_id_Controller.text),
  //         head_count: int.parse(_head_count_Controller.text),
  //         // avinya_type: _avinya_type_Controller.text,
  //         // evaluation_criteria: _evaluation_criteria_Controller.text,
  //       );
  //       //await updateVacancy(vacancy);
  //       Navigator.of(context).pop(true);
  //     }
  //   } on Exception {
  //     await showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         content: const Text('Failed to edit the Vacancy'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           )
  //         ],
  //       ),
  //     );
  //   }
  // }
}
