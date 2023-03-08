import 'dart:developer';
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

  MaskTextInputFormatter phoneMaskTextInputFormatter =
      new MaskTextInputFormatter(
          mask: '###-###-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.eager);
  String gender = 'Not Specified';
  bool doneOL = false;

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'If you are a student applicant who has already registered, please go to the sign in page and login to your account.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    // Navigator.pushNamed(context, '/signin');
                    await routeState.go('/signin');
                  },
                  child: Text('Sign in'),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Avinya Academy Student Admissions",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                        "Avinya Academy is a school that is dedicated to providing a high quality education to students from all backgrounds."),
                                    Text(
                                        "We are currently accepting applications for the 2022/2023 academic year. "),
                                    Text(
                                        "Please fill out the form below to apply for admission to Avinya Academy. "),
                                    SizedBox(height: 20.0),
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
                const Text(''),
                TextFormField(
                  controller: _full_name_Controller,
                  decoration: const InputDecoration(
                    labelText: 'Your name *',
                    hintText: 'Enter your name',
                    //helperText: 'Same as in your NIC or birth certificate'
                  ),
                  onFieldSubmitted: (_) {
                    _full_name_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                SizedBox(height: 10.0),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      'Date of birth: ${dateOfBirth.year}/${dateOfBirth.month}/${dateOfBirth.day}'),
                  Container(
                    // Need to use container to add size constraint.
                    width: 300,
                    height: 400,
                    child: CalendarDatePicker(
                      firstDate: DateTime(2004, 1),
                      lastDate: DateTime(2006, 2),
                      initialDate: dateOfBirth,
                      initialCalendarMode: DatePickerMode.day,
                      onDateChanged: (DateTime dateTime) {
                        setState(() {
                          dateOfBirth = dateTime;
                        });
                      },
                    ),
                  ),
                ]),
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
                                    doneOL = true;
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
                                    doneOL = false;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Text('No'),
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
                    if (!doneOL) {
                      return 'You must have attempted O/L at least once';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                Text("Select the year you did GCE O/L"),
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
                TextFormField(
                  controller: _phone_Controller,
                  decoration: InputDecoration(
                    labelText: 'Phone number *',
                    hintText: 'Enter your phone number',
                    helperText: 'e.g 077 123 4567',
                  ),
                  onFieldSubmitted: (_) {
                    _phone_FocusNode.requestFocus();
                  },
                  validator: (value) =>
                      _mandatoryValidator(value) ?? _phoneValidator(value),

                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    phoneMaskTextInputFormatter,
                  ], // Only numbers can be entered
                ),
                TextFormField(
                  controller: _email_Controller,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter your email address',
                    helperText: 'e.g john@mail.com',
                  ),
                  onFieldSubmitted: (_) {
                    _email_FocusNode.requestFocus();
                  },
                  validator: (value) => EmailValidator.validate(value!)
                      ? null
                      : "Please enter a valid email",
                ),
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
                          await routeState.go('/signin');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to zpply, try again')),
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
        campusConfigSystemInstance.setPrecondisionsSubmitted(true);
        final ApplicantConsent applicantConsent = ApplicantConsent(
          name: _full_name_Controller.text,
          date_of_birth: DateFormat('yyyy-MM-dd').format(dateOfBirth),
          done_ol: doneOL,
          ol_year: olYear.year,
          email: _email_Controller.text,
          phone: int.parse(phoneMaskTextInputFormatter.getUnmaskedText()),
          // distance_to_school: int.parse(_distance_Controller.text),
          distance_to_school:
              15, // hard coding for now to 15 km to enable lager audiance for 1st batch of students
          information_correct_consent: checkbox1,
          agree_terms_consent: checkbox2,
        );

        var createPersonResponse = null;
        try {
          createPersonResponse = await createApplicantConsent(applicantConsent);
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
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content:
              const Text('Failed to submit the student applicant consent form'),
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
