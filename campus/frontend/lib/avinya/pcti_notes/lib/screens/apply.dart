import 'dart:developer';

import 'package:flutter/gestures.dart';
// import 'package:ShoolManagementSystem/src/data/library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery/config/app_config.dart';
import '../data.dart';
import '../data/address.dart';
import '../routing.dart';

class CityNearBandaragama {
  int? id;
  String? name;

  CityNearBandaragama(this.name, this.id);

  String getName() {
    return name!;
  }
}

class ApplyScreen extends StatefulWidget {
  static const String route = 'apply';
  // final AddressType addressType;
  const ApplyScreen({super.key});
  @override
  _ApplyScreenState createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  late Future<Person> futurePerson;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _full_name_Controller;
  late FocusNode _full_name_FocusNode;
  late TextEditingController _preferred_name_Controller;
  late FocusNode _preferred_name_FocusNode;
  late TextEditingController _email_Controller;
  late FocusNode _email_FocusNode;
  late TextEditingController _phone_Controller;
  late FocusNode _phone_FocusNode;
  late TextEditingController _address_Controller;
  late FocusNode _address_FocusNode;

  MaskTextInputFormatter phoneMaskTextInputFormatter =
      MaskTextInputFormatter(
          mask: '###-###-####',
          filter: {"#": RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.eager);
  String gender = 'Not Specified';

  var cities = <CityNearBandaragama>[
    CityNearBandaragama("Akarawita", 329),
    CityNearBandaragama("Alubomulla", 656),
    CityNearBandaragama("Ambalangoda", 330),
    CityNearBandaragama("Arawwala West", 1904),
    CityNearBandaragama("Bandaragama", 660),
    CityNearBandaragama("Batuwatta", 914),
    CityNearBandaragama("Bokundara", 1922),
    CityNearBandaragama("Boralesgamuwa", 337),
    CityNearBandaragama("Dampe", 1941),
    CityNearBandaragama("Deltara", 341),
    CityNearBandaragama("Egodauyana North", 1928),
    CityNearBandaragama("Egodauyana South", 1929),
    CityNearBandaragama("Galawilawaththa", 1901),
    CityNearBandaragama("Gonapola Junction", 678),
    CityNearBandaragama("Gorakapitiya", 1919),
    CityNearBandaragama("Haltota", 682),
    CityNearBandaragama("Hiripitya", 344),
    CityNearBandaragama("Homagama", 346),
    CityNearBandaragama("Homagama Town", 1898),
    CityNearBandaragama("Horagala", 347),
    CityNearBandaragama("Horana", 690),
    CityNearBandaragama("Indibedda", 1930),
    CityNearBandaragama("Kahathuduwa", 1923),
    CityNearBandaragama("Kananwila", 695),
    CityNearBandaragama("Kandanagama", 696),
    CityNearBandaragama("Katuwawala", 1917),
    CityNearBandaragama("Kesbewa", 1921),
    CityNearBandaragama("Kiriwattuduwa", 352),
    CityNearBandaragama("Kottawa", 1902),
    CityNearBandaragama("Kuda Uduwa", 700),
    CityNearBandaragama("Liyanwala", 1939),
    CityNearBandaragama("Madapatha", 355),
    CityNearBandaragama("Magammana-Dolekade", 1897),
    CityNearBandaragama("Maharagama", 356),
    CityNearBandaragama("Makandana", 1920),
    CityNearBandaragama("Malapalla", 1907),
    CityNearBandaragama("Mattegoda", 1908),
    CityNearBandaragama("Millaniya", 714),
    CityNearBandaragama("Millewa", 715),
    CityNearBandaragama("Miwanapalana", 716),
    CityNearBandaragama("Morontuduwa", 719),
    CityNearBandaragama("Pannipitiya", 364),
    CityNearBandaragama("Paragastota", 727),
    CityNearBandaragama("Pelenwatta", 1903),
    CityNearBandaragama("Piliyandala", 365),
    CityNearBandaragama("Pitipana Homagama", 366),
    CityNearBandaragama("Pokunuwita", 734),
    CityNearBandaragama("Polgasowita", 367),
    CityNearBandaragama("Poregedara", 1940),
    CityNearBandaragama("Siddamulla", 370),
    CityNearBandaragama("Siyambalagoda", 371),
    CityNearBandaragama("Suwarapola", 1918),
    CityNearBandaragama("Welmilla Junction", 749),
    CityNearBandaragama("Willorawatta", 1933),
  ];

  var selectedcity = null;

  @override
  void initState() {
    super.initState();
    _full_name_Controller = TextEditingController();
    _full_name_FocusNode = FocusNode();
    _preferred_name_Controller = TextEditingController();
    _preferred_name_FocusNode = FocusNode();
    _email_Controller = TextEditingController();
    _email_FocusNode = FocusNode();
    _phone_Controller = TextEditingController();
    _phone_FocusNode = FocusNode();
    _address_Controller = TextEditingController();
    _address_FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _full_name_Controller.dispose();
    _full_name_FocusNode.dispose();
    _preferred_name_Controller.dispose();
    _preferred_name_FocusNode.dispose();
    _email_Controller.dispose();
    _email_FocusNode.dispose();
    _phone_Controller.dispose();
    _phone_FocusNode.dispose();
    _address_Controller.dispose();
    _address_FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    // admissionSystemInstance
    //     .fetchPersonForUser(); // do a fetch to help cross check
    // Person person = admissionSystemInstance.getStudentPerson();
    // log('Apply person' + person.toJson().toString());
    // if (admissionSystemInstance.getJWTSub() == person.jwt_sub_id) {
    //   // the person already exists in the system
    //   // so no need to prefill the form
    //   // go to dashboard
    //   routeState.go('/application');
    //   return Container();
    // }
    return FutureBuilder<Person>(
        future: fetchStudentPerson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            campusAppsPortalInstance.setUserPerson(snapshot.data!);
            routeState.go('/application');
          } else if (snapshot.hasError) {
            return Scaffold(
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
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
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
                        const Text('Fill in the applicant details'),
                        TextFormField(
                          controller: _full_name_Controller,
                          decoration: const InputDecoration(
                              labelText: 'Full name *',
                              hintText: 'Enter your full name',
                              helperText:
                                  'Same as in your NIC or birth certificate'),
                          onFieldSubmitted: (_) {
                            _full_name_FocusNode.requestFocus();
                          },
                          validator: _mandatoryValidator,
                        ),
                        TextFormField(
                          controller: _preferred_name_Controller,
                          decoration: const InputDecoration(
                              labelText: 'Preferred name *',
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              hintText:
                                  'Enter the name you preferr to be called',
                              helperText: 'e.g. John'),
                          onFieldSubmitted: (_) {
                            _preferred_name_FocusNode.requestFocus();
                          },
                          validator: _mandatoryValidator,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 10.0),
                              const Text('Sex'),
                              const SizedBox(height: 10.0),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 10,
                                    child: Radio(
                                      value: 'Male',
                                      groupValue: gender,
                                      activeColor: Colors.orange,
                                      onChanged: (value) {
                                        //value may be true or false
                                        setState(() {
                                          gender = 'Male';
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                const Text('Male'),
                                const SizedBox(width: 10.0),
                                //]),
                                //Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 10,
                                    child: Radio(
                                      value: 'Female',
                                      groupValue: gender,
                                      activeColor: Colors.orange,
                                      onChanged: (value) {
                                        //value may be true or false
                                        setState(() {
                                          gender = 'Female';
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                const Text('Female'),
                              ]),
                            ]),
                        TextFormField(
                          controller: _phone_Controller,
                          decoration: const InputDecoration(
                            labelText: 'Phone number *',
                            hintText: 'Enter your phone number',
                            helperText: 'e.g 077 123 4567',
                          ),
                          onFieldSubmitted: (_) {
                            _phone_FocusNode.requestFocus();
                          },
                          validator: (value) =>
                              _mandatoryValidator(value) ??
                              _phoneValidator(value),

                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            phoneMaskTextInputFormatter,
                          ], // Only numbers can be entered
                        ),
                        TextFormField(
                          controller: _email_Controller,
                          decoration: const InputDecoration(
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
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: _address_Controller,
                          decoration: const InputDecoration(
                              labelText: 'Address *',
                              hintText: 'Enter your address',
                              helperText:
                                  'You must be able to receive mail at this address'),
                          onFieldSubmitted: (_) {
                            _address_FocusNode.requestFocus();
                          },
                          validator: _mandatoryValidator,
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(3.0)),
                          child: DropdownButtonFormField<CityNearBandaragama>(
                            hint: const Text("Select the city you live in"),
                            value: selectedcity,
                            // isExpanded: true,
                            icon:
                                const Icon(Icons.keyboard_arrow_down, size: 22),
                            decoration: const InputDecoration(
                              constraints: BoxConstraints(
                                maxWidth: 200.0,
                              ),
                            ),
                            items: cities.map((CityNearBandaragama value) {
                              return DropdownMenuItem<CityNearBandaragama>(
                                value: value,
                                child: Text(value.name!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              //Do something with this value
                              setState(() {
                                selectedcity = value!;
                              });
                            },
                            validator: (value) => value == null
                                ? 'You must select the city nearest to your home'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const SizedBox(width: 10.0, height: 10.0),
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                                bool successAddingStudentApplicant =
                                    await addSudentApplicant(context);
                                if (successAddingStudentApplicant) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('You applied successfully')),
                                  );
                                  campusConfigSystemInstance
                                      .setApplicationSubmitted(true);

                                  await routeState.go('/tests/logical');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Failed to apply, try again')),
                                  );
                                }
                              }
                            },
                            child: const Text('Submit'))
                      ],
                    ),
                  ),
                ),
              ),
              persistentFooterButtons: [
                OutlinedButton(
                    child: const Text('About'),
                    onPressed: () {
                      showAboutDialog(
                          context: context,
                          applicationName: AppConfig.applicationName,
                          applicationVersion: AppConfig.applicationVersion);
                    }),
                const Text("© 2022, Avinya Foundation."),
              ],
            );
          }
          return const CircularProgressIndicator();
        });
  }

  Future<Person> fetchStudentPerson() async {
    // check if user is in Avinya database person table as a student
    try {
      futurePerson = fetchPerson(campusAppsPortalInstance.getDigitalId()!);
    } catch (e) {
      print(
          'AdmissionSystem fetchPersonForUser :: Error fetching person for user');
      print(e);
    }
    return futurePerson;
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

  Future<bool> addSudentApplicant(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        final Address address = Address(
          record_type: 'address',
          name_en: 'Mailing Address',
          street_address: _address_Controller.text,
          phone: int.parse(phoneMaskTextInputFormatter.getUnmaskedText()),
          city_id: selectedcity.id,
        );

        Address studentAddress;
        Person studentPerson;
        Application createdApplication;

        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing Address Data')),
          );
          studentAddress = await createAddress(address);

          log('studentAddress: $studentAddress');

          final Person person = Person(
            record_type: 'person',
            full_name: _full_name_Controller.text,
            preferred_name: _preferred_name_Controller.text,
            sex: gender,
            phone: int.parse(phoneMaskTextInputFormatter.getUnmaskedText()),
            email: _email_Controller.text,
            mailing_address_id: studentAddress.id,
            jwt_sub_id: campusAppsPortalInstance.getJWTSub(),
            jwt_email: campusAppsPortalInstance.getJWTEmail(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing Student Data')),
          );
          studentPerson = await createStudentApplicant(person);

          campusAppsPortalInstance.setUserPerson(studentPerson);

          final Application application = Application(
            person_id: studentPerson.id,
            vacancy_id: campusConfigSystemInstance.getVacancyId(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preparing Appliction Data')),
          );

          createdApplication = await createApplication(application);
          campusConfigSystemInstance.setApplication(createdApplication);

          log(createdApplication.toString());

          return true;
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
      } else {
        log('addSudentApplicant invalid');
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
