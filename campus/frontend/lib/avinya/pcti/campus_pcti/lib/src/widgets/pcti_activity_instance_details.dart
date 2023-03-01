import 'package:flutter/material.dart';
import 'package:pcti/src/widgets/pcti_note_list.dart';

import '../data.dart';

class SelectPctiActivityInstancePage extends StatefulWidget{
  static const String route = '/pcti_activity_instances';
  final Activity? pctiActivity;

  const SelectPctiActivityInstancePage({super.key, this.pctiActivity});
  @override
  _SelectPctiActivityInstancePageState createState() => _SelectPctiActivityInstancePageState(this.pctiActivity);
}

class _SelectPctiActivityInstancePageState extends State<SelectPctiActivityInstancePage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Activity? pctiActivity;

  late Future<List<ActivityInstance>> futureActivityInstances;
  
  late TextEditingController _project_activity_instance_Controller;
  late FocusNode _project_activity_instance_FocusNode;
  late ActivityInstance selectedActivityInstance;

  _SelectPctiActivityInstancePageState(this.pctiActivity);

  @override
  void initState() {
    super.initState();
    _project_activity_instance_Controller = TextEditingController();
    _project_activity_instance_FocusNode = FocusNode();
    
    futureActivityInstances = _getActivityInstances(pctiActivity);
  }

  Future<List<ActivityInstance>> refreshActivityInstancesState() async {
    futureActivityInstances = _getActivityInstances(pctiActivity);
    return futureActivityInstances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCTI Activity Instances'),
      ),
      body: Center(
        child: FutureBuilder<List<ActivityInstance>>(
          future: refreshActivityInstancesState(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              campusConfigSystemInstance.setActivityInstances(snapshot.data);
              if (snapshot.data!.length > 0){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton(
                      hint: Text("Select PCTI Activity Instance"),
                      items: snapshot.data?.map((ActivityInstance value) {
                        return DropdownMenuItem<ActivityInstance>(
                          value: value,
                          child: Text(value.description ?? ''),
                        );
                      }).toList(),
                      onChanged: (ActivityInstance? value) {
                        setState(() {
                          _project_activity_instance_Controller.text = value?.description ?? '';
                          selectedActivityInstance = value!;
                        });
                      },
                    ),
                    TextField(
                      focusNode: _project_activity_instance_FocusNode,
                      controller: _project_activity_instance_Controller,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                          builder: (context) => AddPctiNotePage(pctiActivityInstance: selectedActivityInstance,),
                  ),
                )
                .then((value) => setState(() {}));
              },
                        child: Text("Select"),
                      ),
                    )
                  ],
                );
            } else {
                return Center(
                  child: Text("You have no classes for today",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  )
                );
              }
            }
            else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } 
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

  Future<List<ActivityInstance>> _getActivityInstances(dynamic pctiActivity) async{
    return fetchPctiActivityInstancesToday(pctiActivity.id);
}


