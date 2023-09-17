import 'dart:developer';
import 'package:ShoolManagementSystem/src/data/evaluation.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:ShoolManagementSystem/src/data.dart';
import 'package:ShoolManagementSystem/src/data/applicant_consent.dart';
// import 'package:ShoolManagementSystem/src/data/library.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../routing.dart';

class PreconditionsScreen extends StatefulWidget {
  static const String route = 'apply';
  // final AddressType addressType;
  const PreconditionsScreen({super.key});
  @override
  _PreconditionsScreenState createState() => _PreconditionsScreenState();
}

class _PreconditionsScreenState extends State<PreconditionsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _full_name_Controller;
  late FocusNode _full_name_FocusNode;
  late TextEditingController _preferred_name_Controller;
  late FocusNode _preferred_name_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  late TextEditingController _distance_Controller;
  late FocusNode _distance_FocusNode;

  DateTime dateOfBirth = DateTime.utc(2005, 1, 1);
  bool checkbox1 = false;
  bool checkbox2 = false;
  DateTime olYear = DateTime(2021);
  DateTime alYear = DateTime(2021);

  MaskTextInputFormatter phoneMaskTextInputFormatter =
      new MaskTextInputFormatter(
          mask: '###-###-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.eager);
  String gender = 'Not Specified';
  String doneOL = 'No';
  String doneAL = 'No';

  final List<Map<String, dynamic>> subjects = [
    {'id': 105, 'name': 'Religion'},
    {'id': 106, 'name': '(Primary) Language: Sinhala Language and Literature'},
    {'id': 107, 'name': '(Secondary) Language: English'},
    {'id': 108, 'name': 'History'},
    {'id': 109, 'name': 'Science'},
    {'id': 110, 'name': 'Mathematics'}
  ];

  final List<String> results = ["Select", "A", "B", "C", "S", "W"];

  String selectedOption = 'Arts';
  List<Map<String, dynamic>> selectedOptionSubjects = [];
  Map<int, String> selectedResults = {};
  Map<int, String> selectedResultsOl = {};

  final List<Map<String, dynamic>> optionSubjects = [
    {
      'name': 'Arts',
      'subjects': [
        {'id': 55, 'name': 'Arabic'},
        {'id': 56, 'name': 'Art'},
        {'id': 57, 'name': 'Bharatha Natayam'},
        {'id': 58, 'name': 'Buddhism'},
        {'id': 59, 'name': 'Buddhist Civilization'},
        {'id': 60, 'name': 'Chinese'},
        {'id': 61, 'name': 'Christian Civilization'},
        {'id': 62, 'name': 'Christianity'},
        {'id': 63, 'name': 'Communication and Media Studies'},
        {'id': 64, 'name': 'Dance'},
        {'id': 65, 'name': 'Economics'},
        {'id': 66, 'name': 'English'},
        {'id': 67, 'name': 'French'},
        {'id': 68, 'name': 'Geography'},
        {'id': 69, 'name': 'German'},
        {'id': 70, 'name': 'Greek and Roman Civilization'},
        {'id': 71, 'name': 'Hindi Language'},
        {'id': 72, 'name': 'Hindu Civilization'},
        {'id': 73, 'name': 'Hinduism'},
        {'id': 74, 'name': 'History'},
        {'id': 75, 'name': 'Home Economics'},
        {'id': 76, 'name': 'Islam'},
        {'id': 77, 'name': 'Islamic Civilization'},
        {'id': 78, 'name': 'Japan Language'},
        {'id': 79, 'name': 'Logic and Scientific Method'},
        {'id': 80, 'name': 'Oriental Music'},
        {'id': 81, 'name': 'Pali Language'},
        {'id': 82, 'name': 'Political Science'},
        {'id': 83, 'name': 'Russian'},
        {'id': 84, 'name': 'Sanskrit'},
        {'id': 85, 'name': 'Sinhala'},
        {'id': 86, 'name': 'Tamil'},
        {'id': 87, 'name': 'Western Music'}
      ],
    },
    {
      'name': 'Commerce',
      'subjects': [
        {'id': 88, 'name': 'Accounting'},
        {'id': 89, 'name': 'Business'},
        {'id': 90, 'name': 'Statistics Business'},
        {'id': 91, 'name': 'Studies Economics'}
      ],
    },
    {
      'name': 'Bio Science',
      'subjects': [
        {'id': 92, 'name': 'Agriculture'},
        {'id': 93, 'name': 'Bio System Technology'},
        {'id': 94, 'name': 'Biology'},
        {'id': 95, 'name': 'Chemistry'},
        {'id': 96, 'name': 'Physics'},
        {'id': 97, 'name': 'Science for Technology'}
      ],
    },
    {
      'name': 'Physical Science (Maths)',
      'subjects': [
        {'id': 95, 'name': 'Chemistry'},
        {'id': 98, 'name': 'Combine Mathematics'},
        {'id': 99, 'name': 'Higher MathematicsHere'},
        {'id': 96, 'name': 'Physics'}
      ],
    },
    {
      'name': 'Technology',
      'subjects': [
        {'id': 100, 'name': 'Agro Technology'},
        {'id': 101, 'name': 'Engineering Technology'},
        {'id': 102, 'name': 'General Information Technology'},
        {'id': 103, 'name': 'Information & Communication'},
        {'id': 104, 'name': 'Technology'}
      ],
    },
  ];

  int selectedSubject = 0;
  String selectedResult = 'Select';

  @override
  void initState() {
    super.initState();
    _full_name_Controller = TextEditingController();
    _full_name_FocusNode = FocusNode();
    _preferred_name_Controller = TextEditingController();
    _preferred_name_FocusNode = FocusNode();
    _phone_Controller = TextEditingController();
    _phone_FocusNode = FocusNode();
    _email_Controller = TextEditingController();
    _email_FocusNode = FocusNode();
    _distance_Controller = TextEditingController();
    _distance_FocusNode = FocusNode();
    selectedOptionSubjects = optionSubjects[0]['subjects'];
    selectedSubject = selectedOptionSubjects[0]['id'];
  }

  @override
  void dispose() {
    _full_name_Controller.dispose();
    _full_name_FocusNode.dispose();
    _preferred_name_Controller.dispose();
    _preferred_name_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    _distance_Controller.dispose();
    _distance_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Avinya Academy Student Application Form'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Help'),
                    ),
                    body: Align(
                      alignment: Alignment.center,
                      child: SelectableText.rich(TextSpan(
                        text:
                            "If you need help, write to us at admissions-help@avinyafoundation.org",
                        style: new TextStyle(color: Colors.blue),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri(
                              scheme: 'mailto',
                              path: 'admissions-help@avinyafoundation.org',
                              query:
                                  'subject=Avinya Academy Admissions - Bandaragama&body=Question on my application', //add subject and body here
                            ));
                          },
                      )),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'You have successfully filled out your application.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: admissionSystemInstance
                                  .getStudentPerson()
                                  .id_no
                                  .toString(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Reference ID copied to clipboard!')),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  admissionSystemInstance
                                      .getStudentPerson()
                                      .id_no
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Icon(
                                Icons.content_copy,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Keep this reference ID safe and easily accessible for future use.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'If you are a new student applicant, please fill out the form below.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Wrap(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   "Avinya Academy Student Admissions",
                                      //   style: TextStyle(
                                      //       fontSize: 20,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "Avinya Academy is a school that is dedicated to providing a high quality education to students from all backgrounds."),
                                      // Text(
                                      //     "We are currently accepting applications for the 2022/2023 academic year. "),
                                      // Text(
                                      //     "Please fill out the form below to apply for admission to Avinya Academy. "),
                                      // SizedBox(height: 20.0),
                                      // Text(
                                      //   "Application Eligibility Criteria",
                                      //   style: TextStyle(
                                      //       fontSize: 15,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "In order to be eligible to join an Avinya Academy the student will need to meet the following eligibility criteria:"),
                                      // SizedBox(height: 15.0),
                                      // Text(
                                      //     "1. Be within a 15km radius of the Avinya Academy Bandaragama location"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "2. Have attempted your O/L examination at least once"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "3. Your year of birth is 2004 or 2005"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "4. Interested in a vocational programme in IT, Healthcare or Tourism industries"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "5. Committed to full time learning over a three year period"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "6. Committed to attending school on a daily basis and spend around 8 hours in the shcool"),
                                      // SizedBox(height: 10.0),
                                      // Text(
                                      //     "7. A valid phone number and an email address for us to contact you and your parents/guardians"),
                                      // SizedBox(height: 12.0),
                                      // Text(
                                      //     "Please verify the following details before proceeding:"),
                                    ]),
                              ]),
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  FormField(
                    builder: (state) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10.0),
                            Text('Have you done your GCE O/L Exam?'),
                            SizedBox(height: 10.0),
                            Row(children: [
                              SizedBox(width: 10.0),
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: true,
                                  groupValue: doneOL,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneOL = 'Yes';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('Yes'),
                              SizedBox(width: 10.0),
                              //]),
                              //Row(children: [
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: false,
                                  groupValue: doneOL,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneOL = 'No';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('No'),
                              SizedBox(width: 10.0),
                              //]),
                              //Row(children: [
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: false,
                                  groupValue: doneOL,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneOL = 'Pending';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('Pending Results'),
                            ]),
                            state.hasError
                                ? Text(
                                    state.errorText!,
                                    style: TextStyle(color: Colors.red),
                                  )
                                : Container(),
                          ]);
                    },
                    validator: (value) {
                      if (doneOL == 'No') {
                        return 'You must have attempted O/L at least once';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.0),
                  if (doneOL == 'Yes') Text("Select the year you did GCE O/L"),
                  if (doneOL == 'Yes')
                    Container(
                      // Need to use container to add size constraint.
                      width: 300,
                      height: 400,
                      child: YearPicker(
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2022),
                        initialDate: DateTime(2022),
                        currentDate: DateTime(2021),
                        selectedDate: olYear,
                        onChanged: (DateTime dateTime) {
                          setState(() {
                            olYear = dateTime;
                          });
                        },
                      ),
                    ),
                  SizedBox(height: 10.0),
                  if (doneOL == 'Yes') Text("Select your GCE O/L results"),
                  SizedBox(height: 10.0),
                  if (doneOL == 'Yes')
                    Container(
                      width: 600.0,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: {
                          0: FlexColumnWidth(4.0),
                          1: FlexColumnWidth(1.0),
                        },
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text('Subject')),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text('Result')),
                                ),
                              ),
                            ],
                          ),
                          for (var subject in subjects)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(subject['name']),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: DropdownButtonFormField<String>(
                                      // value: results[0], // Set initial value
                                      value: selectedResultsOl[subject] ??
                                          'Select',
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedResultsOl[subject['id']] =
                                              newValue!;
                                        });
                                      },
                                      // onChanged: (value) {},
                                      items: results.map((result) {
                                        return DropdownMenuItem<String>(
                                          value: result,
                                          child: Text(result),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: 10.0),

                  FormField(
                    builder: (state) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10.0),
                            Text('Have you done your GCE A/L Exam?'),
                            SizedBox(height: 10.0),
                            Row(children: [
                              SizedBox(width: 10.0),
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: true,
                                  groupValue: doneAL == 'Yes' ? true : false,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneAL = 'Yes';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('Yes'),
                              SizedBox(width: 10.0),
                              //]),
                              //Row(children: [
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: false,
                                  groupValue: doneAL == 'No' ? true : false,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneAL = 'No';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('No'),
                              SizedBox(width: 10.0),
                              SizedBox(
                                width: 10,
                                child: Radio(
                                  value: true,
                                  groupValue:
                                      doneAL == 'Pending' ? true : false,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    //value may be true or false
                                    setState(() {
                                      doneAL = 'Pending';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text('Pending')
                            ]),
                            state.hasError
                                ? Text(
                                    state.errorText!,
                                    style: TextStyle(color: Colors.red),
                                  )
                                : Container(),
                          ]);
                    },
                    // validator: (value) {
                    //   if (!doneOL) {
                    //     return 'You must have attempted O/L at least once';
                    //   }
                    //   return null;
                    // },
                  ),
                  SizedBox(height: 10.0),
                  if (doneAL == 'Yes') Text("Select the year you did GCE A/L"),
                  if (doneAL == 'Yes')
                    Container(
                      // Need to use container to add size constraint.
                      width: 300,
                      height: 400,
                      child: YearPicker(
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2022),
                        initialDate: DateTime(2022),
                        currentDate: DateTime(2021),
                        selectedDate: alYear,
                        onChanged: (DateTime dateTime) {
                          setState(() {
                            alYear = dateTime;
                          });
                        },
                      ),
                    ),
                  SizedBox(height: 10.0),
                  SizedBox(height: 20),
                  if (doneAL == 'Yes')
                    Text("Select the stream you did GCE A/L"),
                  if (doneAL == 'Yes')
                    DropdownButton<String>(
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                          selectedOptionSubjects = optionSubjects.firstWhere(
                              (option) =>
                                  option['name'] == newValue)['subjects'];
                          selectedSubject = selectedOptionSubjects[0]['id'];
                        });
                      },
                      items: optionSubjects
                          .map<DropdownMenuItem<String>>((option) {
                        return DropdownMenuItem<String>(
                          value: option['name'],
                          child: Text(option['name']),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),
                  if (doneAL == 'Yes')
                    Text(
                        "Please kindly choose the results for the subjects in which you actively participated"),
                  SizedBox(height: 20),
                  if (doneAL == 'Yes') buildResultTable(),
                  // TextFormField(
                  //   controller: _distance_Controller,
                  //   decoration: InputDecoration(
                  //     labelText:
                  //         'Distance from the school location in Kilometers *',
                  //     hintText:
                  //         'How far you live from Avinya Academy Bandaragama in KM?',
                  //     helperText: 'e.g. 14',
                  //   ),
                  //   onFieldSubmitted: (_) {
                  //     _distance_FocusNode.requestFocus();
                  //   },
                  //   validator: (value) =>
                  //       _mandatoryValidator(value) ?? _distanceValidator(value),

                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: <TextInputFormatter>[
                  //     FilteringTextInputFormatter.digitsOnly,
                  //     // phoneMaskTextInputFormatter,
                  //   ], // Only numbers can be entered
                  // ),
                  SizedBox(width: 10.0, height: 10.0),
                  FormField<bool>(
                    builder: (state) {
                      return Row(children: [
                        SizedBox(width: 10.0),
                        SizedBox(
                          width: 10,
                          child: Checkbox(
                            value: checkbox1,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              //value may be true or false
                              setState(() {
                                checkbox1 = !checkbox1;
                                state.didChange(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.errorText ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).errorColor,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Container(
                                width: c_width,
                                child: Text(
                                  'By checking this box, I confirm that the information provided herein' +
                                      ' on the student applicant is accurate, correct and complete and that' +
                                      ' it would lead to the rejection of the application in the event' +
                                      ' of any false information being provided.',
                                  softWrap: true,
                                ),
                              ),
                            ]),
                      ]);
                    },
                    validator: (value) {
                      if (!checkbox1) {
                        return 'You need to verify informaton correctness';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(width: 10.0, height: 10.0),
                  FormField<bool>(
                    builder: (state) {
                      return Row(children: [
                        SizedBox(width: 10.0),
                        SizedBox(
                          width: 10,
                          child: Checkbox(
                            value: checkbox2,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              //value may be true or false
                              setState(() {
                                checkbox2 = !checkbox2;
                                state.didChange(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.errorText ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).errorColor,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Container(
                                width: c_width,
                                child: Text(
                                  'By checking this box, I agree to the Terms of Use and Privacy Policy' +
                                      ' (unless I am under the age of 18, in which case,' +
                                      ' I represent that my parent or legal guardian also agrees' +
                                      ' to the Terms of Use on my behalf)',
                                  softWrap: true,
                                ),
                              ),
                            ]),
                      ]);
                    },
                    validator: (value) {
                      if (!checkbox2) {
                        return 'You need to agree to the terms and conditions';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(width: 10.0, height: 10.0),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );

                          bool successAddingApplicantConsent =
                              await addSudentApplicantConsent(context);
                          if (successAddingApplicantConsent) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('You consented successfully')),
                            );
                            await routeState.go('/submitted_thankyou');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to Apply, try again')),
                            );
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
                                  left: 100.0, right: 100.0, bottom: 100.0),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.yellow,
                            ),
                          );
                        }
                      },
                      child: Text('Submit'))
                ],
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        new OutlinedButton(
            child: Text('About'),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: AppConfig.applicationName,
                  applicationVersion: AppConfig.applicationVersion);
            }),
        new Text("© 2022, Avinya Foundation."),
      ],
    );
  }

  Widget buildResultTable() {
    return Container(
      width: 600.0,
      child: Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(4.0),
          1: FlexColumnWidth(1.0),
        },
        children: <TableRow>[
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Subject')),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Result')),
                ),
              ),
            ],
          ),
          for (var subject in selectedOptionSubjects)
            buildTableRow(
                [Text(subject['name']), buildResultDropdown(subject['id'])]),
        ],
      ),
    );
  }

  // Widget buildSubjectDropdown() {
  //   return DropdownButton<String>(
  //     value: selectedSubject,
  //     onChanged: (String? newValue) {
  //       setState(() {
  //         selectedSubject = newValue!;
  //       });
  //     },
  //     items:
  //         selectedOptionSubjects.map<DropdownMenuItem<String>>((String value) {
  //       return DropdownMenuItem<String>(
  //         value: value,
  //         child: Text(value),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget buildResultDropdown(int subject) {
    return DropdownButton<String>(
      value: selectedResults[subject] ?? 'Select',
      onChanged: (String? newValue) {
        setState(() {
          selectedResults[subject] = newValue!;
        });
      },
      items: <String>['Select', 'A', 'B', 'C', 'D', 'F']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  TableRow buildTableRow(List<dynamic> values) {
    return TableRow(
      children: values
          .map((value) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: value is Widget ? value : Text(value),
                ),
              ))
          .toList(),
    );
  }

  String? _mandatoryValidator(String? text) {
    return (text!.isEmpty) ? 'Required' : null;
  }

  // String? _distanceValidator(String? text) {
  //   if (text!.isEmpty) {
  //     return 'Required';
  //   } else if (int.parse(text) > 15) {
  //     return 'Distance cannot be more than 15 KM';
  //   } else {
  //     return null;
  //   }
  // }

  String? _phoneValidator(String? text) {
    String? value = phoneMaskTextInputFormatter.getUnmaskedText();
    return (value.length != 10)
        ? 'Phone number must be 10 digits e.g 071 234 5678'
        : null;
  }

  Future<bool> addSudentApplicantConsent(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        log('addSudentApplicantConsent valid');
        log(_phone_Controller.text);
        log(phoneMaskTextInputFormatter.getUnmaskedText());
        var orgId = admissionSystemInstance.getStudentPerson().organization_id;
        var avinyaTypeId =
            admissionSystemInstance.getStudentPerson().avinya_type_id;
        var applicationId = admissionSystemInstance.getApplication().id;
        var personId = admissionSystemInstance.getStudentPerson().id;
        log(orgId.toString());
        log(avinyaTypeId.toString());
        log(applicationId.toString());
        log(personId.toString());
        log(selectedOption.toString());
        log(selectedOptionSubjects.toString());
        log(selectedResults.toString());
        log(selectedResultsOl.toString());
        log(selectedOption.toString());

        var organizationId =
            admissionSystemInstance.getStudentPerson().organization_id;
        var avinyatypeId =
            admissionSystemInstance.getStudentPerson().avinya_type_id;
        var applicationid = admissionSystemInstance.getApplication().id;
        var personid = admissionSystemInstance.getStudentPerson().id;
        var name = admissionSystemInstance.getStudentPerson().full_name;
        var dateOfBirth =
            admissionSystemInstance.getStudentPerson().date_of_birth;
        var phone = admissionSystemInstance.getStudentPerson().phone;
        var email = admissionSystemInstance.getStudentPerson().email;

        admissionSystemInstance.setPrecondisionsSubmitted(true);
        final ApplicantConsent applicantConsent = ApplicantConsent(
          organization_id: organizationId,
          avinya_type_id: avinyatypeId,
          application_id: applicationid,
          person_id: personid,
          name: name,
          date_of_birth: dateOfBirth,
          phone: phone,
          email: email,
          done_ol: doneOL,
          ol_year: olYear.year,
          done_al: doneAL,
          al_year: alYear.year,
          al_stream: selectedOption,
          // distance_to_school: int.parse(_distance_Controller.text),
          distance_to_school:
              15, // hard coding for now to 15 km to enable lager audiance for 1st batch of students
          information_correct_consent: checkbox1,
          agree_terms_consent: checkbox2,
        );

        // final Evaluation evaluation = Evaluation(
        //     evaluatee_id: admissionSystemInstance.getStudentPerson().id!,
        //     evaluator_id: 0,
        //     evaluation_criteria_id:
        //         int.parse(_evaluation_criteria_id_Controller.text),
        //     activity_instance_id:
        //         int.parse(_activity_instance_id_Controller.text),
        //     response: _response_Controller.text,
        //     notes: _notes_Controller.text,
        //     grade: int.parse(_grade_Controller.text));
        List<Evaluation> evaluations = [];
        // selectedResults.forEach((element) {
        //   if (element != '') {
        //     evaluations.add(Evaluation(
        //         evaluation_criteria_id: criteriaIds[answers.indexOf(element)],
        //         response: element,
        //         evaluatee_id: person.id,
        //         evaluator_id: person.id,
        //         notes: 'Student Test Evaluation',
        //         grade: -1));
        //   }
        // });
        selectedResults.forEach((index, element) {
          if (element != '') {
            evaluations.add(Evaluation(
              evaluation_criteria_id: index,
              response: element,
              evaluatee_id: admissionSystemInstance.getStudentPerson().id!,
              evaluator_id: admissionSystemInstance.getStudentPerson().id!,
              notes: 'Student Test Evaluation',
              grade: -1,
            ));
          }
        });

        log('vacancy list :' + evaluations.toString());
        evaluations.forEach((element) {
          log('vacancy list loop elements:' + element.toString());
          log(element.toJson().toString());
        });

        // log(createEvaluationsResponse.body.toString());
        // return true;

        var createPersonResponse = null;
        var createEvaluationsResponse = null;
        try {
          createPersonResponse = await createApplicantConsent(applicantConsent);
          createEvaluationsResponse = await createEvaluation(evaluations);
          // var result = await createEvaluation([evaluation]);
        } catch (e) {
          log(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'There was a problem submitting your data. Please try again later.',
                style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(left: 100.0, right: 100.0, bottom: 100.0),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.yellow,
            ),
          );
          return false;
        }

        log(createPersonResponse.body.toString());

        return true;
      } else {
        log('addSudentApplicantConsent invalid');
        return false;
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There was a problem submitting your data. Please try again later.',
            style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 100.0, right: 100.0, bottom: 100.0),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.yellow,
        ),
      );
      return false;
    }
  }
}
