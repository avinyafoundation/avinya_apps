import 'package:mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';
import 'package:mobile/widgets/time_line_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyAlumniDashboardScreen extends StatefulWidget {
  const MyAlumniDashboardScreen({Key? key}) : super(key: key);

  @override
  _MyAlumniDashboardScreenState createState() =>
      _MyAlumniDashboardScreenState();
}

class _MyAlumniDashboardScreenState extends State<MyAlumniDashboardScreen> {
  bool showFeedbackForm = false;
  String? selectedRsvp;
  String feedback = '';
  int? selectedRating;
  late Person userPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  late AlumniPerson alumniPerson = AlumniPerson(is_graduated: null)
    ..full_name = 'John'
    ..nic_no = '12';

  @override
  void initState() {
    super.initState();
    getUserPerson();
  }

  void getUserPerson() {
    // Retrieve user data from local instance
    Person user = campusAppsPortalInstance.getUserPerson();
    _fetchAlumniPersonData(user.id);
    setState(() {
      userPerson = user;
    });
  }

  Future<AlumniPerson> _fetchAlumniPersonData(id) async {
    alumniPerson = await fetchAlumniPerson(id);
    setState(() {
      alumniPerson = alumniPerson;
    });
    return alumniPerson;
  }

  void handleRsvp(String? value) {
    setState(() {
      selectedRsvp = value;
      showFeedbackForm = value == 'yes';
    });
  }

  void submitFeedback() {
    if (feedback.isEmpty || selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide feedback and a rating.')),
      );
      return;
    }
    setState(() {
      feedback = '';
      selectedRating = null;
      showFeedbackForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback submitted! Thank you for your input.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: SizerUtil.deviceType == DeviceType.tablet
                          ? 12.w
                          : 13.w,
                      backgroundColor: kSecondaryColor,
                      backgroundImage:
                          AssetImage('assets/images/student_profile.jpeg'),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, ${alumniPerson.full_name}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Email: ${alumniPerson.email}'),
                          Text('Phone: ${alumniPerson.phone}'),
                          Text(
                            'Current Status: ${alumniPerson.alumni_work_experience != null && alumniPerson.alumni_work_experience!.isNotEmpty ? alumniPerson.alumni_work_experience![0].companyName : "No work experience available"}',
                          ),
                          Text('LinkedIn: linkedin.com/in/johndoe'),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: Colors.blue, size: 24),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.lightBlue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upcoming Events',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Alumni Meetup 2025 - Jan 15, 2025'),
                    DropdownButton<String>(
                      value: selectedRsvp,
                      hint: Text('Will you attend?'),
                      onChanged: handleRsvp,
                      items: ['yes', 'no'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.capitalize()),
                        );
                      }).toList(),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                            255, 53, 158, 77), // Change color as needed
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🎉 Participate & win a 5000 LKR gift voucher!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Note: By participating, You stand a chance to win a 5000 LKR gift voucher!'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.lightBlue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completed Events',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Text('Alumni Meetup 2025 - Jan 15, 2025'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (value) => feedback = value,
                          decoration: InputDecoration(
                            labelText: 'Your Feedback',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                Icons.star,
                                color: selectedRating != null &&
                                        selectedRating! > index
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() => selectedRating = index + 1);
                              },
                            );
                          }),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: submitFeedback,
                          child: Text('Submit Feedback'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
