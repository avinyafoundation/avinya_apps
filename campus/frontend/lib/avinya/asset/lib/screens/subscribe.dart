import 'dart:developer';

import 'package:ShoolManagementSystem/src/data.dart';
import 'package:ShoolManagementSystem/src/data/prospect.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../routing.dart';

class SubscribeScreen extends StatefulWidget {
  static const String route = 'subscribe';
  // final AddressType addressType;
  const SubscribeScreen({super.key});
  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name_Controller;
  late FocusNode _name_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  late TextEditingController _address_Controller;
  late FocusNode _address_FocusNode;

  bool receive_information_consent = true;
  bool agree_terms_consent = true;

  DateTime dateOfBirth = DateTime.utc(2005, 1, 1);

  MaskTextInputFormatter phoneMaskTextInputFormatter =
      new MaskTextInputFormatter(
          mask: '###-###-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.eager);

  @override
  void initState() {
    super.initState();
    _name_Controller = TextEditingController();
    _name_FocusNode = FocusNode();
    _phone_Controller = TextEditingController();
    _phone_FocusNode = FocusNode();
    _email_Controller = TextEditingController();
    _email_FocusNode = FocusNode();
    _address_Controller = TextEditingController();
    _address_FocusNode = FocusNode();
    _address_Controller.text = '';
  }

  @override
  void dispose() {
    _name_Controller.dispose();
    _name_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    _address_Controller.dispose();
    _address_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    //double c_width = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Avinya Academy - Student Admissions'),
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
                      child: SelectableText.rich(
                        TextSpan(
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
                        ),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
              children: <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Avinya Academy - Prospective Student Subscription Form",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                  "Thank you for your interest in Avinya Academy"),
                              SizedBox(height: 10.0),
                              Text(
                                  "Please fill in the form if you are interested in applying for a place at Avinya Academy. We will contact you with further information."),
                              Text(
                                  "Please note that we are currently only accepting applications for Avinya Academy Bandaragama."),
                              SizedBox(height: 10.0),
                              Text(
                                  "Avinya Academy හි ස්ථානයක් සඳහා අයදුම් කිරීමට ඔබ කැමති නම් කරුණාකර පෝරමය පුරවන්න. වැඩිදුර තොරතුරු සමඟ අපි ඔබව සම්බන්ධ කර ගන්නෙමු."),
                              Text(
                                  "දැනට අප අයදුම්පත් භාර ගන්නේ අවින්‍යා ඇකඩමිය බණ්ඩාරගම ශාඛාව සඳහා පමණක් බව කරුණාවෙන් සලකන්න."),
                              SizedBox(height: 10.0),
                              SelectableText(''),
                              SelectableText.rich(TextSpan(
                                text:
                                    "ඔබට උදව් අවශ්‍ය නම්, admissions-help@avinyafoundation.org වෙත විද්‍යුත් තැපෑලක් එවන්න.",
                                style: new TextStyle(color: Colors.blue),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(Uri(
                                      scheme: 'mailto',
                                      path:
                                          'admissions-help@avinyafoundation.org',
                                      query:
                                          'subject=Avinya Academy Admissions - Bandaragama&body=Question on my application', //add subject and body here
                                    ));
                                  },
                              )),
                              // Text(
                              //     "By completing this form, your name and contact information will be added to our prospects database,"),
                              // Text(
                              //     "so that you can receive emails and notifications about Avinya Academy and student admissions related information."),
                              SizedBox(height: 10.0),
                            ]),
                      ]),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _name_Controller,
                  decoration: const InputDecoration(
                    labelText: 'Your name *',
                    hintText: 'Enter your name',
                    helperText: 'Your proffered given name and surname',
                  ),
                  onFieldSubmitted: (_) {
                    _name_FocusNode.requestFocus();
                  },
                  validator: _mandatoryValidator,
                ),
                SizedBox(height: 5.0),
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
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _address_Controller,
                  decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      helperText:
                          'You must be able to receive mail at this address'),
                  onFieldSubmitted: (_) {
                    _address_FocusNode.requestFocus();
                  },
                  //validator: _mandatoryValidator,
                ),
                SizedBox(width: 10.0, height: 5.0),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      'Date of birth: ${dateOfBirth.year}/${dateOfBirth.month}/${dateOfBirth.day}'),
                  Container(
                    // Need to use container to add size constraint.
                    width: 300,
                    height: 400,
                    child: CalendarDatePicker(
                      firstDate: DateTime(2003, 1),
                      lastDate: DateTime(2007, 2),
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
                SizedBox(width: 10.0, height: 5.0),
                // FormField<bool>(
                //   builder: (state) {
                //     return Row(children: [
                //       SizedBox(width: 10.0),
                //       SizedBox(
                //         width: 10,
                //         child: Checkbox(
                //           value: receive_information_consent,
                //           activeColor: Colors.orange,
                //           onChanged: (value) {
                //             //value may be true or false
                //             setState(() {
                //               receive_information_consent =
                //                   !receive_information_consent;
                //               state.didChange(value);
                //             });
                //           },
                //         ),
                //       ),
                //       SizedBox(width: 10.0),
                //       Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               state.errorText ?? '',
                //               style: TextStyle(
                //                 color: Theme.of(context).errorColor,
                //               ),
                //             ),
                //             SizedBox(width: 10.0),
                //             Container(
                //               width: c_width,
                //               child: Text(
                //                 'I agree to receive announcements and news via email or text messages.',
                //                 softWrap: true,
                //               ),
                //             ),
                //           ]),
                //     ]);
                //   },
                //   validator: (value) {
                //     if (!receive_information_consent) {
                //       return 'You need to verify informaton correctness';
                //     } else {
                //       return null;
                //     }
                //   },
                // ),
                // SizedBox(width: 10.0, height: 5.0),
                // FormField<bool>(
                //   builder: (state) {
                //     return Row(children: [
                //       SizedBox(width: 10.0),
                //       SizedBox(
                //         width: 10,
                //         child: Checkbox(
                //           value: agree_terms_consent,
                //           activeColor: Colors.orange,
                //           onChanged: (value) {
                //             //value may be true or false
                //             setState(() {
                //               agree_terms_consent = !agree_terms_consent;
                //               state.didChange(value);
                //             });
                //           },
                //         ),
                //       ),
                //       SizedBox(width: 10.0),
                //       Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               state.errorText ?? '',
                //               style: TextStyle(
                //                 color: Theme.of(context).errorColor,
                //               ),
                //             ),
                //             SizedBox(width: 10.0),
                //             Container(
                //               width: c_width,
                //               child: Text(
                //                 'By checking this box, I agree to the Terms of Use and Privacy Policy' +
                //                     ' (unless I am under the age of 18, in which case,' +
                //                     ' I represent that my parent or legal guardian also agrees' +
                //                     ' to the Terms of Use on my behalf)',
                //                 softWrap: true,
                //               ),
                //             ),
                //           ]),
                //     ]);
                //   },
                //   validator: (value) {
                //     if (!agree_terms_consent) {
                //       return 'You need to agree to the terms and conditions';
                //     } else {
                //       return null;
                //     }
                //   },
                // ),
                // SizedBox(width: 10.0, height: 5.0),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        bool successAddingProspecct =
                            await addProspect(context);
                        if (successAddingProspecct) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You subscribed successfully')),
                          );
                          await routeState.go('/subscribed_thankyou');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Failed to subscribe, try again')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Some of the data you entred on this form ' +
                                  'does not meet the validation criteria.\r\n' +
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

  String? _phoneValidator(String? text) {
    String? value = phoneMaskTextInputFormatter.getUnmaskedText();
    return (value.length != 10)
        ? 'Phone number must be 10 digits e.g 071 234 5678'
        : null;
  }

  Future<bool> addProspect(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        log('addProspect form valid');
        log(_phone_Controller.text);
        log(phoneMaskTextInputFormatter.getUnmaskedText());
        campusConfigSystemInstance.setPrecondisionsSubmitted(true);
        final Prospect prospect = Prospect(
            name: _name_Controller.text,
            phone: int.parse(phoneMaskTextInputFormatter.getUnmaskedText()),
            email: _email_Controller.text,
            street_address: _address_Controller.text,
            date_of_birth: DateFormat('yyyy-MM-dd').format(dateOfBirth),
            receive_information_consent: receive_information_consent,
            agree_terms_consent: agree_terms_consent);
        log(prospect.toJson().toString());
        var createProspectResponse = null;
        try {
          createProspectResponse = await await createProspect(prospect)
              .timeout(Duration(seconds: 10));
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

        log(createProspectResponse.body.toString());
        return true;
        //Navigator.of(context).pop(true);

      } else {
        log('addProspect form invalid');
        return false;
      }
    } on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to submit the student prospect form'),
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
