

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:attendance/data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/constants.dart';
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

List<DutyParticipant> _dutyParticipants = [];
List<ActivityAttendance> _fetchedDutyAttendance = [];
List<Evaluation> _fetchedEvaluations = [];
List<bool> selectedRows = [];

var parentOrganizationId = 0;


  @override
  void initState(){
   super.initState();
   workActivityId = campusAppsPortalInstance.activityIds['work']!;
   parentOrganizationId =  campusAppsPortalInstance.getUserPerson().
                                   organization!.parent_organizations[0].parent_organizations[0].id!;
   loadDutyParticipants();   
   loadDutyAttendance();
   loadEvaluations();
  }


  Future<void> submitDutyAttendance(DutyParticipant dutyParticipant,TimeOfDay selectedTime) async{

    if (workActivityInstance.id == -1) {
      workActivityInstance = await campusAttendanceSystemInstance
          .getCheckinActivityInstance(workActivityId);
    }

   ActivityAttendance activityAttendance = ActivityAttendance(
          person_id: -1, sign_in_time: null, sign_out_time: null);

    activityAttendance = ActivityAttendance(
          activity_instance_id: workActivityInstance.id,
          person_id: dutyParticipant.person!.id,
          sign_in_time: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute).toString(),
          in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        );
    

     var dutyAttendance = null;
     dutyAttendance =  _fetchedDutyAttendance
                .firstWhere(
                  (attendance) =>
                      attendance.person_id ==
                          dutyParticipant.person!.id! &&
                      attendance.sign_in_time !=
                          null,
                  orElse: () =>
                    new ActivityAttendance(
                      sign_in_time: null));
                                           
                                  
    if(dutyAttendance.sign_in_time !=null){
    await  deleteActivityAttendance(dutyAttendance.id!);
    }
    
    
    await createDutyActivityAttendance(activityAttendance);
    
  }

  Future<void> toggleAbsent(DutyParticipant dutyParticipant, bool value) async{

   if (workActivityInstance.id == -1) {

      workActivityInstance =  await campusAttendanceSystemInstance.getCheckinActivityInstance(workActivityId);
                                        
   }

   if(value == true){

     var dutyAttendance =null;

     dutyAttendance =  _fetchedDutyAttendance
                .firstWhere(
                  (attendance) =>
                      attendance.person_id ==
                          dutyParticipant.person!.id! &&
                      attendance.sign_in_time !=
                          null,
                  orElse: () =>
                    new ActivityAttendance(
                      sign_in_time: null));
                                           
                                  
    if(dutyAttendance.sign_in_time !=null){
    await  deleteActivityAttendance(dutyAttendance.id!);
    }


    final Evaluation evaluation = Evaluation(
            evaluatee_id: dutyParticipant.person!.id,
            evaluator_id: campusAppsPortalInstance.getUserPerson().id,
            evaluation_criteria_id: 54,
            activity_instance_id: workActivityInstance.id,  
            response: "absence",
            notes: "",
            grade: 0
          );
    await createEvaluation([evaluation]);

   }else if(value == false){

     var evaluation = _fetchedEvaluations.firstWhere((evaluation) =>
                                                    evaluation.evaluatee_id ==
                                                    dutyParticipant.person!.id!,
                                                    orElse: () => new Evaluation(
                                                  evaluatee_id: -1)); 

    if(evaluation.evaluatee_id != null &&  evaluation.evaluatee_id != -1){
      await deleteEvaluation(evaluation.id!.toString());
    }

   }

  }


  Future<void> loadDutyParticipants() async{  

    final dutyParticipants = await fetchDutyParticipantsByDutyActivityId(
                 parentOrganizationId,campusAppsPortalInstance.getLeaderParticipant().activity!.id!);

    setState(() {
      _dutyParticipants = dutyParticipants;
    });
  }

  Future<void> loadDutyAttendance() async{  

    final dutyAttendance = await getDutyAttendanceToday(
                parentOrganizationId,workActivityId);

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
          attendance.sign_in_time != null,
           orElse: () =>
            new ActivityAttendance(
              sign_in_time: null
          )
      );

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
                  height: 60,
          ),
          Row(
            children: [
              SizedBox(
                width: 17,
              ),
              const Icon(
                IconData(0xe6f2, fontFamily: 'MaterialIcons'),
                size: 25,
                color: Colors.blueAccent,
              ),
              SizedBox(
                  width: 10,
                ),
              Text(
                  'Duty :',
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal)
                ),
              SizedBox(
                  width: 20,
                ),
              
              Flexible(
                flex: 2,
                child: Container(
                  width: 200,
                  child: Text(
                      campusAppsPortalInstance.getLeaderParticipant().activity!.name!,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
                    ),
                ),
              ),
              SizedBox(
                 height: 50,
              )
            ],
          ),
          SizedBox(
                    height: 30,
              ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,       
          child:Row(
            children: [
              SizedBox(
                width: 15,
              ), 
              Container(
                  child:  _dutyParticipants.isEmpty ? SizedBox(): buildTable(),  
              )           
             ],
           ),    
          ),        
        ],
      ),
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
                    
                    bool isAbsent = false;
                      if (_fetchedEvaluations
                                          .firstWhere(
                                              (evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  participant.person!.id!,
                                              orElse: () => new Evaluation(
                                                  evaluatee_id: -1))
                                          .evaluatee_id !=
                                      -1)  
                          isAbsent = true;

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
                      
                            DataCell(
                              TimePickerCell(
                                onTimeSelected: (TimeOfDay selectedTime) async{
  
                                  await submitDutyAttendance(participant,selectedTime);

                                  _fetchedDutyAttendance = await getDutyAttendanceToday(
                                             parentOrganizationId,workActivityId);

                                  _fetchedEvaluations =
                                                await getActivityInstanceEvaluations(
                                                    workActivityInstance.id!);
                                 
                                  setState(() {});
                                },
                                initialTime:_getInitialTime(participant),
                                isButtonEnabled:isAbsent,
                             ),
                               ),
                              DataCell(Checkbox( // Add a Checkbox to the cell
                              value: _fetchedEvaluations
                                          .firstWhere(
                                              (evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  participant.person!.id!,
                                              orElse: () => new Evaluation(
                                                  evaluatee_id: -1))
                                          .evaluatee_id !=
                                          -1,
                              onChanged: (bool? value) async{
                                  await  toggleAbsent(participant,value!);  

                                  _fetchedDutyAttendance = await getDutyAttendanceToday(
                                             parentOrganizationId,workActivityId);

                                  _fetchedEvaluations =
                                                await getActivityInstanceEvaluations(
                                                    workActivityInstance.id!);
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
  }

  @override
  void didChangeDependencies() {
    
    super.didChangeDependencies();
  }
 
  @override
  void didUpdateWidget(covariant TimePickerCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the initialTime property has changed
    if (widget.initialTime != oldWidget.initialTime) {
      setState(() {
        _selectedTime = widget.initialTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Container(
          height: 60,
          child: Row(
            children: [
              ElevatedButton(
                onPressed:widget.isButtonEnabled ? null:()async{
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
                },
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 12)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ), 
                child: Container(
                  width: 75,
                  child: Text(
                       _selectedTime != null ? _selectedTime!.format(context) : 'Pick a Time',
                       textAlign: TextAlign.center,
                      ),
                ),
              ),
            ],
          ),
        );
  }
}