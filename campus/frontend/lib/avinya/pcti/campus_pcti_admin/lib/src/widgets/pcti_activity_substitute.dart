import 'package:ShoolManagementSystem/src/data/activity_particpant.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class selectPctiSubstitute extends StatefulWidget {
  @override
  _selectPctiSubstituteState createState() => _selectPctiSubstituteState();
}

class _selectPctiSubstituteState extends State<selectPctiSubstitute> {
  late Future<List<Activity>> futurePctiActivities;
  late Activity? _selectedActivity = null;

  @override
  void initState() {
    super.initState();
    futurePctiActivities = fetchPctiActivities(); // for now get notes for activity id 1
  }

  Future<List<Activity>> refreshPctiActivitiesState() async {
    futurePctiActivities = fetchPctiActivities();
    return futurePctiActivities;
  }

  @override
  Widget build(BuildContext context) {
    Widget selectActivityInstanceWidget;
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Activity>>(
            future: refreshPctiActivitiesState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                campusConfigSystemInstance.setPctiActivities(snapshot.data);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<Activity>(
                            hint: Text("Select PCTI Activity"),
                            items: snapshot.data?.map((Activity value) {
                              return DropdownMenuItem<Activity>(
                                value: value,
                                child: Text(value.description ?? ''),
                              );
                            }).toList(),
                            onChanged: (Activity? value) {
                              setState(() {
                                _selectedActivity = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 10,),
                          ElevatedButton(
                          child: Text("Confirm"),
                          onPressed: () {
                            Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) => selectActivityInstance(pctiActivity: _selectedActivity!),
                              )
                            );
                          },
                        ),
                        ],
                      ),
                    ),
                    // _selectedActivity != null ? selectActivityInstance(_selectedActivity!) : Text("Select Activity"),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            },
        ),
      ),
    );
  }
}

class selectActivityInstance extends StatefulWidget {
  final Activity pctiActivity;

  selectActivityInstance({required this.pctiActivity});

  @override
  State<selectActivityInstance> createState() => _selectActivityInstanceState(this.pctiActivity);
}

class _selectActivityInstanceState extends State<selectActivityInstance> {
  final Activity? pctiActivity;
  late Future<List<ActivityInstance>> futurePctiActivityInstances;
  late ActivityInstance? _selectedActivityInstance = null;

  _selectActivityInstanceState(this.pctiActivity);

  @override
  void initState() {
    super.initState();
    futurePctiActivityInstances = fetchActivityInstancesFuture(pctiActivity!.id!); // for now get notes for activity id 1
  }

  Future<List<ActivityInstance>> refreshPctiActivityInstancesState() async {
    futurePctiActivityInstances = fetchActivityInstancesFuture(pctiActivity!.id!);
    return futurePctiActivityInstances;
  }

  @override
  Widget build(BuildContext context) {
    Widget selectTeacherWidget;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCTI Activity Instances'),
      ),
      body: Center(
        child: FutureBuilder<List<ActivityInstance>>(
            future: refreshPctiActivityInstancesState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // campusConfigSystemInstance.setPctiActivities(snapshot.data);
                if(snapshot.data!.length > 0){
                    return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<ActivityInstance>(
                              hint: Text("Select PCTI Activity Instance"),
                              items: snapshot.data?.map((ActivityInstance value) {
                                return DropdownMenuItem<ActivityInstance>(
                                  value: value,
                                  child: Text(value.description ?? ''),
                                );
                              }).toList(),
                              onChanged: (ActivityInstance? value) {
                                setState(() {
                                  _selectedActivityInstance = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 10,),
                            ElevatedButton(
                            child: Text("Confirm"),
                            onPressed: () {
                              setState(() {
                                // if (_selectedActivityInstance != null) {
                                //   // selectActivityInstanceWidget = selectActivityInstance(_selectedActivity!);
                                //   Text("Selected!");
                                //   print("Selected!");
                                // }
                                Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (context) => selectAvailableTeacher(pctiActivityInstance: _selectedActivityInstance!),
                                  )
                                );
                              });
                            },
                          ),
                          ],
                        ),
                      ),
                      // _selectedActivityInstance != null ? selectActivityInstance(_selectedActivity!) : Text("Select Activity"),
                    ],
                  );
                }
                else{
                  return Center(
                    child: Text("You have no classes scheduled for this activity",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    )
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
        ),
      ),
    );
  }
}

class selectAvailableTeacher extends StatefulWidget {
  final ActivityInstance pctiActivityInstance;
  
   selectAvailableTeacher({required this.pctiActivityInstance});

  @override
  State<selectAvailableTeacher> createState() => _selectAvailableTeacherState(this.pctiActivityInstance);
}

class _selectAvailableTeacherState extends State<selectAvailableTeacher> {
  final ActivityInstance? pctiActivityInstance;
  late Future<List<Person>> futureAvailableTeachers;
  late Person? _selectedTeacher = null;
  
  _selectAvailableTeacherState(this.pctiActivityInstance);

  @override
  void initState(){
    super.initState();
    futureAvailableTeachers = fetchAvailableTeachers(pctiActivityInstance!.id!);
  }

  Future<List<Person>> refreshAvailableTeachersState() async{
    futureAvailableTeachers = fetchAvailableTeachers(pctiActivityInstance!.id!);
    return futureAvailableTeachers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCTI Activity Instances'),
      ),
      body: Center(
        child: FutureBuilder<List<Person>>(
            future: refreshAvailableTeachersState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // campusConfigSystemInstance.setPctiActivities(snapshot.data);
                if(snapshot.data!.length > 0){
                    return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<Person>(
                              hint: Text("Select a substitute health"),
                              items: snapshot.data?.map((Person value) {
                                return DropdownMenuItem<Person>(
                                  value: value,
                                  child: Text(value.preferred_name ?? ''),
                                );
                              }).toList(),
                              onChanged: (Person? value) {
                                setState(() {
                                  _selectedTeacher = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 10,),
                            ElevatedButton(
                            child: Text("Confirm"),
                            onPressed: () async{
                              await _addTeacherParticipant(context, pctiActivityInstance!, _selectedTeacher!);
                            },
                          ),
                          ],
                        ),
                      ),
                      // _selectedActivityInstance != null ? selectActivityInstance(_selectedActivity!) : Text("Select Activity"),
                    ],
                  );
                }
                else{
                  return Center(
                    child: Text("You have no classes scheduled for this activity",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    )
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
        ),
      ),
    );
  }

  Future<void> _addTeacherParticipant(BuildContext context, ActivityInstance selectedActivityInstance, Person selectedTeacher) async{
    try{
      final ActivityParticipant activityParticipant = ActivityParticipant(
        activityInstanceId: selectedActivityInstance.id!,
        person_id: selectedTeacher.id!
      );
      await createActivityParticipant(activityParticipant);
      Navigator.of(context).pop(true);
    }on Exception {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('Failed to add teacher'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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




