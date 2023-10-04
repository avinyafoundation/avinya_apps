

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:attendance/data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/constants.dart';
import '../data/activity_instance.dart';
import 'package:attendance/data/evaluation.dart';


class DutyAttendanceMarker extends StatefulWidget {
  const DutyAttendanceMarker({super.key});

  @override
  State<DutyAttendanceMarker> createState() => _DutyAttendanceMarkerState();
}

class _DutyAttendanceMarkerState extends State<DutyAttendanceMarker> {


var workActivityId = 0;
var workActivityInstance = ActivityInstance(id: -1);
Activity? _selectedDutyTypeValue;

List<Activity>  _activitiesByAvinyaType = [];
List<DutyParticipant> _dutyParticipants = [];
List<ActivityAttendance> _fetchedDutyAttendance = [];
List<Evaluation> _fetchedEvaluations = [];
List<bool> selectedRows = [];



  @override
  void initState(){
   super.initState();
   loadActivitiesByAvinyaType();
   workActivityId = campusAppsPortalInstance.activityIds['work']!;
   loadDutyParticipants();   
   loadDutyAttendance();
   loadEvaluations();
  }


  Future<void> submitDutyAttendance(DutyParticipant dutyParticipant) async{

    if (workActivityInstance.id == -1) {
      workActivityInstance = await campusAttendanceSystemInstance
          .getCheckinActivityInstance(workActivityId);
    }

    int index = -1;

    index = _fetchedDutyAttendance.indexWhere((attendance) =>
          attendance.person_id == dutyParticipant.person!.id && attendance.sign_in_time != null);

    print(
        'index: $index  person_id: ${dutyParticipant.person!.id}  _fetchedAttendance lenth ${_fetchedDutyAttendance.length}');

    if (index == -1) {
      index = _fetchedDutyAttendance
          .indexWhere((attendance) => attendance.person_id == -1);
      if (index == -1) {
        print(
            'index is still -1 => index: $index  person_id: ${dutyParticipant.person!.id} ');
        // if index is still -1 then there is no empty slot
        // so we need to create a new slot
        _fetchedDutyAttendance.add(ActivityAttendance(
            person_id: -1, sign_in_time: null, sign_out_time: null));
        index = _fetchedDutyAttendance.length - 1;
      }
    }

   ActivityAttendance activityAttendance = ActivityAttendance(
          person_id: -1, sign_in_time: null, sign_out_time: null);

    activityAttendance = ActivityAttendance(
          activity_instance_id: workActivityInstance.id,
          person_id: dutyParticipant.person!.id,
          sign_in_time: DateTime.now().toString(),
          in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        );
    
    
    createDutyActivityAttendance(activityAttendance);

    _fetchedDutyAttendance[index] = activityAttendance;

  }

  Future<void> toggleAbsent(DutyParticipant dutyParticipant, bool value) async{

   if (workActivityInstance.id == -1) {

      workActivityInstance =  await campusAttendanceSystemInstance.getCheckinActivityInstance(workActivityId);
                                        
   }

   if(value == true){

    final Evaluation evaluation = Evaluation(
            evaluatee_id: dutyParticipant.person!.id,
            evaluator_id: campusAppsPortalInstance.getUserPerson().id,
            evaluation_criteria_id: 54,
            activity_instance_id: workActivityInstance.id,  //activity_instance_id: activityInstanceForAbsent.id,
            response: "absence",
            notes: "",
            grade: 0
          );
    await createEvaluation([evaluation]);

   }else if(value == false){

     var evaluation = _fetchedEvaluations.firstWhere((evaluation) =>
                                                    evaluation.evaluatee_id ==
                                                    dutyParticipant.person!.id!); 
     await deleteEvaluation(evaluation.id!.toString());

   }

  }


  Future<void> loadActivitiesByAvinyaType() async{  

    final activities = await fetchActivitiesByAvinyaType(91);//load avinya type =91(work) related activities
    setState(() {
      _activitiesByAvinyaType = activities;
    });
  }

  Future<void> loadDutyParticipants() async{  

    print("leader activity id:${campusAppsPortalInstance.getLeaderParticipant().activity!.id!}");
    print("organization id:${campusAppsPortalInstance.getUserPerson().organization!.parent_organizations}");

    final dutyParticipants = await fetchDutyParticipantsByDutyActivityId(
                 campusAppsPortalInstance.getUserPerson().organization!.id!,campusAppsPortalInstance.getLeaderParticipant().activity!.id!);
    setState(() {
      _dutyParticipants = dutyParticipants;
    });
  }

  Future<void> loadDutyAttendance() async{  

    final dutyAttendance = await getDutyAttendanceToday(
                campusAppsPortalInstance.getUserPerson().organization!.id!,workActivityId);
    setState(() {
      _fetchedDutyAttendance = dutyAttendance;
    });
  }

  Future<void> loadEvaluations() async{  

    if (workActivityInstance.id == -1) {
              workActivityInstance  =  await campusAttendanceSystemInstance
                                    .getCheckinActivityInstance(
                                    workActivityId);
        }

    final evaluations = await getActivityInstanceEvaluations(workActivityInstance.id!);

    setState(() {
      _fetchedEvaluations = evaluations;
    });

  }




  TimeOfDay? _getInitialTime(DutyParticipant participant) {
    final attendance = _fetchedDutyAttendance.firstWhere(
      (attendance) =>
          attendance.person_id == participant.person!.id! &&
          attendance.sign_in_time != null,);

    if (attendance.sign_in_time != null) {
      
      final dateTime = DateTime.parse(attendance.sign_in_time.toString());
      return TimeOfDay.fromDateTime(dateTime);
    } else {
      
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: [
          SizedBox(
                  height: 60,
          ),
          Row(
            children: [
              
              Icon(
                  Icons.work_outline,
                  size: 25,
                  color: Colors.blueAccent,
                ),
              SizedBox(
                  width: 10,
                ),
              Text(
                  'Duty :',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal)
                ),
              SizedBox(
                  width: 20,
                ),
              //buildDutyDropDownButton(),
              Text(
                  campusAppsPortalInstance.getLeaderParticipant().activity!.name!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
                ),
              SizedBox(
                 height: 100,
              )
            ],
          ),
          SizedBox(
                    height: 50,
              ),  
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                           
                _dutyParticipants.isEmpty ? SizedBox(): buildTable(),
                 ],
              )
          ),            
        ],
      ),
    );
  }

 Widget buildDutyDropDownButton(){

   return DropdownButton<Activity>(
    value:_selectedDutyTypeValue,
    items: _activitiesByAvinyaType.map<DropdownMenuItem<Activity>>((Activity value){
      return DropdownMenuItem<Activity>(
       value: value,
       child: Text(value.name.toString()),
        );
       },
      ).toList(), 
     onChanged:(Activity? newValue) async{
        _selectedDutyTypeValue = newValue;

        // _dutyParticipants =  await fetchDutyParticipantsByDutyActivityId(
        //          campusAppsPortalInstance.getUserPerson().organization!.id!,_selectedDutyTypeValue!.id!);

        // _fetchedDutyAttendance = await getDutyAttendanceToday(
        //         campusAppsPortalInstance.getUserPerson().organization!.id!,workActivityId);

        // if (workActivityInstance.id == -1) {
        //       workActivityInstance  =  await campusAttendanceSystemInstance
        //                             .getCheckinActivityInstance(
        //                             workActivityId);
        // }

        
        //  _fetchedEvaluations = await getActivityInstanceEvaluations(workActivityInstance.id!);

        setState(() {});      
       },     
      );
  }



Widget buildTable(){
    return Card(
         child: Padding(
          padding:const EdgeInsets.all(8.0),
          child: Column(
          children: [
  
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width:  1100,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                          "Student Name",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                          "Digital Id",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                          "Class",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                   DataColumn(
                    label: Text(
                          "Status",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                           "Time",
                           style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                           ),
                  ),
                  DataColumn(
                    label: Text(
                           "Absent",
                           style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                           ),
                  ),
                ], 

                rows: _dutyParticipants.map((participant){     
                    
                    bool isAbsent = true;
                      if (_fetchedEvaluations
                                          .firstWhere(
                                              (evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  participant.person!.id!,
                                              orElse: () => new Evaluation(
                                                  evaluatee_id: -1))
                                          .evaluatee_id !=
                                      -1)  
                          isAbsent = false;

                      return DataRow(
                        cells:[
                         DataCell(Text(
                                  participant.person!.preferred_name ?? 'N/A',
                                  )
                                ),
                         DataCell(Text(
                                  participant.person!.digital_id ?? 'N/A',
                                  )
                                ),
                         DataCell(Text(
                                  participant.person!.organization?.description ?? 'N/A',
                                  )
                                ),
                         DataCell(
                            _fetchedDutyAttendance
                                              .firstWhere(
                                                (attendance) =>
                                                    attendance.person_id ==
                                                        participant.person!.id! &&
                                                    attendance.sign_in_time !=
                                                        null,
                                                orElse: () =>
                                                  new ActivityAttendance(
                                                    sign_in_time: null)
                                              )
                                              .sign_in_time !=
                                          null ?    
                                          Text(
                                           "Present",
                                            style: TextStyle(
                                            color: Colors.green
                                          ),                              
                                          ):
                                          Text(
                                            "Absent",
                                            style: TextStyle(
                                            color: Colors.red
                                          ),   
                                         ),
                                ),
                      
                          if(_fetchedDutyAttendance.firstWhere((attendance) => 
                                 attendance.person_id == participant.person!.id!
                                 && attendance.sign_in_time != null,
                                 orElse: () =>
                                                new ActivityAttendance(
                                                    person_id: -1)
                                 ).person_id !=-1)
                            DataCell(
                              TimePickerCell(
                                onTimeSelected: (TimeOfDay selectedTime){
                                 // Handle the selected time here.
                                 print('Selected Time: $selectedTime');
                                },
                                initialTime:_getInitialTime(participant),
                                isButtonEnabled:isAbsent,
                             ),
                               )
                          else
                            DataCell(
                              TimePickerCell(
                                onTimeSelected: (TimeOfDay selectedTime) async{
                                   // Handle the selected time here.
                                   print('Selected Time: $selectedTime');
                                  await submitDutyAttendance(participant);
                                  // loadDutyParticipants();   
                                  // loadDutyAttendance();
                                  // loadEvaluations();
                                  setState(() {});
                                },
                                initialTime:null,
                                isButtonEnabled:isAbsent,
                              ),
                            ),

                          if (_fetchedEvaluations
                                          .firstWhere(
                                              (evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  participant.person!.id!,
                                              orElse: () => new Evaluation(
                                                  evaluatee_id: -1))
                                          .evaluatee_id !=
                                      -1)  
                              
                            DataCell(Checkbox( // Add a Checkbox to the cell
                              value: _fetchedEvaluations
                                                .firstWhere((evaluation) =>
                                                    evaluation.evaluatee_id ==
                                                    participant.person!.id!)
                                                .response!=null,
                              onChanged: (bool? value) async{
                                  await  toggleAbsent(participant,value!);  

                                  // loadDutyParticipants();   
                                  // loadDutyAttendance();

                                  // _fetchedEvaluations =
                                  //               await getActivityInstanceEvaluations(
                                  //                   workActivityInstance.id!);
                                    setState(() {});
                                },
                              )
                            )
                          else
                            DataCell(Checkbox( // Add a Checkbox to the cell
                              value: false,
                              onChanged: (bool? value) async{
                                  await  toggleAbsent(participant,value!); 

                                  // loadDutyParticipants();   
                                  // loadDutyAttendance();

                                  // _fetchedEvaluations =
                                  //               await getActivityInstanceEvaluations(
                                  //                   workActivityInstance.id!);
                                  setState(() {});
                                },
                              )
                           )
                        ], 
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
     ),
    );
  }


}

class TimePickerCell extends StatefulWidget {

  final ValueChanged<TimeOfDay> onTimeSelected;
  final TimeOfDay? initialTime;
  final bool isButtonEnabled; 


  TimePickerCell({required this.onTimeSelected,this.initialTime,required this.isButtonEnabled});

  @override
  State<TimePickerCell> createState() => _TimePickerCellState();
}

class _TimePickerCellState extends State<TimePickerCell> {

  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
     _selectedTime = widget.initialTime;
     
   // Initialize _selectedTime with initialTime
  }

 
  @override
  Widget build(BuildContext context) {

    //_selectedTime == null ? widget.initialTime:_selectedTime?.format(context);

    if(widget.initialTime !=null){
      _selectedTime = widget.initialTime;
    }else if(widget.initialTime ==null){
      _selectedTime = widget.initialTime;
    }
    

    return Container(
      width:  120,
      height: 70,
      child: Row(
        children: [

        if(_selectedTime !=null)
          Text(
             _selectedTime?.format(context) ?? '',
          style: TextStyle(
            color: _selectedTime != null ? Colors.black : Colors.grey,
          )
          ),

        if(_selectedTime == null)
          ElevatedButton(
            onPressed: widget.isButtonEnabled ? () async{
              final selectedTime = await showTimePicker(
                context: context, 
                initialTime: _selectedTime ?? TimeOfDay.now(),
              );
    
              if(selectedTime !=null){
                setState(() {
                  _selectedTime = selectedTime;
                 
                });
    
              widget.onTimeSelected(selectedTime);
              }
            }:null, 
            child: Text('Pick a Time'),
          )
        ],
      ),
    );

  }
}