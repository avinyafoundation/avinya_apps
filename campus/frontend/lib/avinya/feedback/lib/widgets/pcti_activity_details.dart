import 'package:flutter/material.dart';

import '../data.dart';

class SelectPctiActivityPage extends StatefulWidget{
  static const String route = '/pcti_activities';
  const SelectPctiActivityPage({super.key,this.onTap});
  final ValueChanged<Activity>? onTap;

  @override
  _SelectPctiActivityPageState createState() => _SelectPctiActivityPageState(onTap);
}

class _SelectPctiActivityPageState extends State<SelectPctiActivityPage>{
  
  late Future<List<Activity>> futureActivities;
  final ValueChanged<Activity>? onTap;

  _SelectPctiActivityPageState(this.onTap);
  
  late TextEditingController activity_Controller;
  late FocusNode activity_FocusNode;
  late Activity selectedActivity;

  @override
  void initState() {
    super.initState();
    activity_Controller = TextEditingController();
    activity_FocusNode = FocusNode();
    
    futureActivities = _getActivities();
  }

  Future<List<Activity>> refreshActivitiesState() async {
    futureActivities = _getActivities();
    return futureActivities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Activity>>(
          future: refreshActivitiesState(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              campusFeedbackSystemInstance.setActivities(snapshot.data);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DropdownButton(
                    hint: Text("Select PCTI Activity"),
                    items: snapshot.data?.map((Activity value) {
                      return DropdownMenuItem<Activity>(
                        value: value,
                        child: Text(value.description ?? ''),
                      );
                    }).toList(),
                    onChanged: (Activity? value) {
                      setState(() {
                        activity_Controller.text = value?.description ?? '';
                        selectedActivity = value!;
                      });
                    },
                  ),
                  TextField(
                    focusNode: activity_FocusNode,
                    controller: activity_Controller,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        onTap!(selectedActivity);
                        // onTap != null ? () => onTap!(selectedActivity) : null;
                      },
                      child: Text("View Notes"),
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

  Future<List<Activity>> _getActivities() async{
    return fetchPctiParticipantActivities(421);
}




