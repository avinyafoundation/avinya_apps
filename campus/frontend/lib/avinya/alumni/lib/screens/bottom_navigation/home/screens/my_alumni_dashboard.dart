import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/data/activity_instance.dart';
import 'package:gallery/avinya/alumni/lib/data/activity_instance_evaluation.dart';
import 'package:gallery/avinya/alumni/lib/data/activity_participant.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
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
  late Future<List<ActivityInstance>> _upcomingEventsData;
  late Future<List<ActivityInstance>> _completedEventsData;
  String? selectedRsvp;
  String feedback = '';
  int? selectedRating;
  late Person userPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  late AlumniPerson alumniPerson = AlumniPerson(is_graduated: null)
    ..full_name = 'John'
    ..nic_no = '12';
  bool lookingForJob = false;
  bool updateCV = false;

  @override
  void initState() {
    super.initState();
    getUserPerson();
    if (alumniPerson != null && alumniPerson.id != null) {
      _upcomingEventsData = _loadUpcomingEventsData(alumniPerson.id!);
      _completedEventsData = _loadCompletedEventsData(alumniPerson.id!);
    }
  }

  // void getUserPerson() {
  //   // Retrieve user data from local instance
  //   Person user = campusAppsPortalInstance.getUserPerson();
  //   _fetchAlumniPersonData(user.id);
  //   setState(() {
  //     userPerson = user;
  //   });
  // }
  void getUserPerson() {
    // Retrieve user data from local instance
    AlumniPerson AlumniUser = campusAppsPortalInstance.getAlumniUserPerson();
    Person user = campusAppsPortalInstance.getUserPerson();
    setState(() {
      alumniPerson = AlumniUser;
      userPerson = user;
    });
  }

  Future<List<ActivityInstance>> _loadUpcomingEventsData(int person_id) async {
    return await fetchUpcomingEvents(person_id);
  }

  Future<List<ActivityInstance>> _loadCompletedEventsData(int person_id) async {
    return await fetchCompletedEvents(person_id);
  }

  // Future<AlumniPerson> _fetchAlumniPersonData(id) async {
  //   alumniPerson = await fetchAlumniPerson(id);
  //   setState(() {
  //     alumniPerson = alumniPerson;
  //   });
  //   return alumniPerson;
  // }

  void handleRsvp(String? value) {
    setState(() {
      selectedRsvp = value;
      showFeedbackForm = value == 'yes';
    });
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = alumniPerson.sex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpeg'; // Default or female profile image
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
                      backgroundImage: AssetImage(imagePath),
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
                          Text(
                              'LinkedIn: ${alumniPerson.alumni?.linkedin_id ?? ''}'),
                          SwitchListTile(
                            title: Text("I am looking for a job"),
                            value: lookingForJob,
                            activeColor:
                                Colors.green, // Change switch color when ON
                            inactiveThumbColor: Colors
                                .grey, // Change switch thumb color when OFF
                            onChanged: (value) =>
                                setState(() => lookingForJob = value),
                          ),
                          SwitchListTile(
                            title: Text("Help me update my CV?"),
                            value: updateCV,
                            activeColor: Colors.blue,
                            inactiveThumbColor: Colors.grey,
                            onChanged: (value) =>
                                setState(() => updateCV = value),
                          ),
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
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upcoming Events',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      FutureBuilder<List<ActivityInstance>>(
                        future: _upcomingEventsData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              child: SpinKitCircle(
                                color: (Colors.blueGrey[400]),
                                size: 70,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Something went wrong...'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('No Upcoming Events Found'),
                            );
                          }
                          final upcomingEventData = snapshot.data!;
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: upcomingEventData.length,
                            itemBuilder: (context, index) {
                              return UpcomingEventCard(
                                  eventData: upcomingEventData[index],
                                  alumniPerson: alumniPerson);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
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
                    FutureBuilder<List<ActivityInstance>>(
                      future: _completedEventsData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                              color: (Colors.blueGrey[400]),
                              size: 70,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong...'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No Completed Events Found'),
                          );
                        }
                        final completedEventData = snapshot.data!;
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: completedEventData.length,
                          itemBuilder: (context, index) {
                            return CompletedEventCard(
                                eventData: completedEventData[index],
                                alumniPerson: alumniPerson);
                          },
                        );
                      },
                    ),
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

class UpcomingEventCard extends StatefulWidget {
  final ActivityInstance eventData;
  final AlumniPerson? alumniPerson;

  const UpcomingEventCard(
      {required this.eventData, required this.alumniPerson, super.key});

  @override
  State<UpcomingEventCard> createState() => _UpcomingEventCardState();
}

class _UpcomingEventCardState extends State<UpcomingEventCard> {
  String? selectedRsvp;

  @override
  void initState() {
    super.initState();
    // Set initial value for the dropdown based on is_attending
    selectedRsvp = widget.eventData != null &&
            widget.eventData.activity_participant != null &&
            (widget.eventData.activity_participant!.is_attending == 1 ||
                widget.eventData.activity_participant!.is_attending == 0)
        ? (widget.eventData.activity_participant!.is_attending == 1
            ? 'Yes'
            : 'No')
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final eventGift = widget.eventData.event_gift;

    return SizedBox(
      width: MediaQuery.of(context).size.height * 0.6,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventData.name ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Start: ${widget.eventData.start_time != null ? DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.parse(widget.eventData.start_time!)) : ''}",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                "Location: ${widget.eventData.location ?? ''}",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text("Will you attend?"),
              DropdownButton<String>(
                value: selectedRsvp,
                onChanged: (String? value) async {
                  setState(() {
                    selectedRsvp = value!;
                  });
                  var activityParticipant;

                  if (widget.eventData.activity_participant?.id == null) {
                    activityParticipant = ActivityParticipant(
                      activity_instance_id: widget.eventData.id,
                      person_id: widget.alumniPerson!.id,
                      organization_id: widget.alumniPerson!.organization_id,
                      is_attending: value == 'Yes' ? 1 : 0,
                    );
                  } else if (widget.eventData.activity_participant!.id !=
                      null) {
                    activityParticipant = ActivityParticipant(
                      id: widget.eventData.activity_participant!.id,
                      activity_instance_id: widget.eventData.id,
                      person_id: widget.alumniPerson!.id,
                      is_attending: value == 'Yes' ? 1 : 0,
                    );
                  }
                  var result =
                      await createActivityParticipant(activityParticipant);
                },
                items: ['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 5,
              ),
              if (eventGift != null && eventGift.description != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    eventGift.description ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  eventGift!.notes ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedEventCard extends StatefulWidget {
  final ActivityInstance eventData;
  final AlumniPerson? alumniPerson;

  const CompletedEventCard(
      {required this.eventData, required this.alumniPerson, super.key});

  @override
  State<CompletedEventCard> createState() => _CompletedEventCardState();
}

class _CompletedEventCardState extends State<CompletedEventCard> {
  TextEditingController feedbackController = TextEditingController();
  String feedback = '';
  int? selectedRating;
  bool showFeedbackForm = false;
  bool isFeedbackSubmitted = false; // Track if feedback & rating are submitted

  @override
  void initState() {
    super.initState();
    final activityEvaluation = widget.eventData.activity_evaluation;
    if (activityEvaluation != null) {
      setState(() {
        feedbackController.text = activityEvaluation.feedback ?? '';
        selectedRating =
            activityEvaluation.rating != -1 ? activityEvaluation.rating : null;
        isFeedbackSubmitted = selectedRating != null;
      });
    }
  }

  void submitFeedback() async {
    if (selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide feedback and a rating.')),
      );
      return;
    } else if (selectedRating != null) {
      var activityEvaluation;

      if (widget.eventData.activity_participant?.id == null) {
        activityEvaluation = ActivityInstanceEvaluation(
            activity_instance_id: widget.eventData.id,
            evaluator_id: widget.alumniPerson!.id,
            feedback: feedback,
            rating: selectedRating);

        var result = await createActivityInstanceEvaluation(activityEvaluation);
      }
    }
    setState(() {
      showFeedbackForm = false;
      isFeedbackSubmitted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Feedback submitted! Thank you for your support.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventGift = widget.eventData.event_gift;

    return SizedBox(
      width: MediaQuery.of(context).size.height * 0.6,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventData.name ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "${widget.eventData.start_time != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.eventData.start_time!)) : ''}",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                "Location: ${widget.eventData.location ?? ''}",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text("Your feedback"),
              TextField(
                controller: feedbackController,
                onChanged: (value) => feedback = value,
                decoration: InputDecoration(
                  //labelText: 'Your Feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !isFeedbackSubmitted,
              ),
              SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: selectedRating != null && selectedRating! > index
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: isFeedbackSubmitted
                        ? null
                        : () {
                            setState(() => selectedRating = index + 1);
                          },
                  );
                }),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: isFeedbackSubmitted ? null : submitFeedback,
                child: Text('Submit Feedback'),
              ),
            ],
          ),
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
