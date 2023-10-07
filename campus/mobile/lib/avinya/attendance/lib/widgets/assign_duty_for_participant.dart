import 'package:flutter/material.dart';
import 'package:attendance/data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/constants.dart';
import 'package:intl/intl.dart';


class AssignDutyForParticipant extends StatefulWidget {
  const AssignDutyForParticipant({super.key});

  @override
  State<AssignDutyForParticipant> createState() => _AssignDutyForParticipantState();
}

class _AssignDutyForParticipantState extends State<AssignDutyForParticipant> {

  var _selectedClassValue;
  var _selectedPersonValue;
  Organization? _fetchedOrganization;

  late List<List<Person>> _dropDownPersonList;
  late List<Organization?> _selectedClassValues;
  late List<String?> _selectedPersonValues;
  late List<String?> _selectedRoleValues;

  List<DutyParticipant> _dutyParticipants = [];
  List<Activity>  _activitiesByAvinyaType = []; 
  List<String?> _activitiesNames = [];
  List<DutyParticipant> _dutyRelatedParticipantsFilterAndStore = []; //filter And Store duty Relavant Participants
  List<String> _dropDownRoleList = ['leader','member'];
  late DutyRotationMetaDetails _rotationMetaDetails;

  late TextEditingController  _startDate;
  late TextEditingController _endDate;

  bool _startDateSelected = true;
  bool _endDateSelected = true;


  @override
  void initState(){
   super.initState();
   loadActivitiesByAvinyaType();
   loadRotationMetadetails();
    _startDate = TextEditingController();
    _endDate = TextEditingController();
  }

  @override
  void dispose() {
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  bool hasLeaderRoleWithActivity(String? activityName,String? allocatedRole){
    print('duty participants : ${_dutyParticipants}');
    bool hasLeaderRoleWithActivity;

    if(allocatedRole == "leader"){
      hasLeaderRoleWithActivity = _dutyParticipants.any((participant)=>participant.activity?.name == activityName && participant.role == 'leader');
     
      if(hasLeaderRoleWithActivity){
        return true;
      }else{
        return false;
      }   
    }else{
         return  false;
    }
  }

  Future<List<DutyParticipant>> loadDutyParticipantsData(int organization_id) async{

    print('organization id inside loadDutyParticipantsData() methos : ${organization_id}');
    return await fetchDutyParticipants(organization_id);
  }

  Future<void> loadRotationMetadetails() async{
    _rotationMetaDetails = await fetchDutyRotationMetadataByOrganization(campusAppsPortalInstance.getUserPerson().organization!.id!);
  
   if(_rotationMetaDetails.start_date!=null && _rotationMetaDetails.end_date !=null){

       DateTime parsedStartDate = DateTime.parse(_rotationMetaDetails.start_date!).toLocal();
       DateTime parsedEndDate = DateTime.parse(_rotationMetaDetails.end_date!).toLocal();
       _startDate.text = DateFormat('yyyy-MM-dd').format(parsedStartDate);
       _endDate.text = DateFormat('yyyy-MM-dd').format(parsedEndDate);
   
   }else{
      setState(() {
        _startDateSelected = false;
       _endDateSelected = false;
      });
   }
  
  }

  Future<void> loadActivitiesByAvinyaType() async{

    _activitiesByAvinyaType = await fetchActivitiesByAvinyaType(91); //load avinya type =91(work) related activities
    _activitiesNames = _activitiesByAvinyaType.map((activities) => activities.name).toList();

    _dropDownPersonList = List.generate(_activitiesNames.length,(index) =>[]);
    _selectedClassValues = List.generate(_activitiesNames.length, (index) => null);
    _selectedPersonValues = List.generate(_activitiesNames.length, (index) => null);
    _selectedRoleValues = List.generate(_activitiesNames.length,(index)=>null);

    print(' _dropDownPersonList value:${_dropDownPersonList}');
    print('_selectedClassValues value:${_selectedClassValues}');
    print('_selectedPersonValues value:${_selectedPersonValues}');
  }



   @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    print('');
    print('execute did change dependencies');
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                _startDateSelected && _endDateSelected 
                   ? SizedBox()
                   : Text(
                      'Please select both start and end dates',
                      style: TextStyle(color: Colors.red),  
                   ),
                SizedBox(
                height: 10,
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _startDate,
                    decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: "Start Date"
                    ),
                    readOnly: true,
                    onTap:  () => _selectStartDate(context),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _endDate,
                    decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: "End Date"
                    ),
                    readOnly: true,
                    onTap:  () => _selectEndDate(context),
                  ),
                ),
                ],
            
              ),
            ),
            SizedBox(
                height: 20,
              ),
            FutureBuilder(
              future:loadDutyParticipantsData(campusAppsPortalInstance.getUserPerson().organization!.id!),         
              builder:(BuildContext context,snapshot){

                 if(snapshot.hasData){

                 return SingleChildScrollView(
                   child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,                
                          itemCount: _activitiesNames.length,
                          itemBuilder: (context,tableIndex){
                         // print('table index:{$tableIndex}');
                          _dutyRelatedParticipantsFilterAndStore.clear();
                          _dutyParticipants = (snapshot.data as List<DutyParticipant>);
                          _dutyRelatedParticipantsFilterAndStore = _dutyParticipants.where((filterParticipant)=>filterParticipant.activity!.name ==  _activitiesNames[tableIndex]).toList();
                         // print('dutyRelatedParticipantsFilterAndStore: ${_dutyRelatedParticipantsFilterAndStore}');
                         // print('length is: ${_dutyRelatedParticipantsFilterAndStore.length}');
                          return  Container(
                              width: 1200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  for (var org in campusAppsPortalInstance
                                      .getUserPerson()
                                      .organization!
                                      .child_organizations)  
                                    
                                    if (org.child_organizations.length > 0)                             
                                            SingleChildScrollView(
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[                                                
                                                                                                                              
                                                       Container(
                                                         
                                                         child: Row(
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
                                                            '${_activitiesNames[tableIndex]}',
                                                             overflow: TextOverflow.clip,
                                                             style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
                                                            )
                                                           ],
                                                          ),
                                                       ), 
                                                    SizedBox(
                                                      height: 15,
                                                    ),                                                   
                                                    Row(
                                                      children:[
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            'Select a class :',
                                                             overflow: TextOverflow.clip,
                                                             style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal)
                                                        ),
                                                        
                                                       Container( 
                                                          margin: EdgeInsets.only(left: 30.0),
                                                          width: 120,                                            
                                                          child: buildClassDropDownButton(org,tableIndex,_dutyParticipants)
                                                        ),
                                                      ]
                                                    ),   
                                                    SizedBox(
                                                      height: 25,
                                                    ),                                          
                                                    Row(
                                                      children: [ 
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            'Select a person :',
                                                             overflow: TextOverflow.clip,
                                                             style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal)
                                                        ), 
                                                        SizedBox(
                                                          width: 20.0,
                                                        ),                                            
                                                        Flexible(     
                                                          child: Container(
                                                            width: 240,
                                                            child: buildPersonDropDownButton(tableIndex)
                                                          ),
                                                        ),
                                                      ]
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),   
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            'Select a role :',
                                                             overflow: TextOverflow.clip,
                                                             style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal)
                                                        ),
                                                           
                                                        Container( 
                                                          margin: EdgeInsets.only(left: 40.0),
                                                          width: 100, 
                                                          child: buildRoleDropDownButton(tableIndex)
                                                        ),
                                                      ],
                                                    ),                                                
                                                  ],
                                                ),
                                            ),        
                                      buildTable(_dutyRelatedParticipantsFilterAndStore,tableIndex,_dutyParticipants),
                                      SizedBox(
                                        height: 30,
                                      )
                                ],
                                
                              ),
                          );
                      },    
                    ),
                 );
              }
              //}
              return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                              color: (Colors
                                  .blue),
                              size: 70, 
                            ),
                  );
             },
            ),
          ],
        ));
  }

  Widget buildTable(List<DutyParticipant> dutyRelatedParticipantsFilterAndStore,int tableIndex,List<DutyParticipant> dutyParticipants){
    return Card(
         child: Padding(
          padding:const EdgeInsets.all(8.0),
          child: Column(
          children: [
  
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width:  950,
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
                          "Role",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                           "Remove",
                           style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                           ),
                  ),
                ], 
                rows: dutyRelatedParticipantsFilterAndStore.map((participant){

                    bool isLeader = participant.role == 'leader';

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
                         DataCell(Row(
                           children: [
                             if(isLeader)
                               Icon(Icons.star,color: Colors.orange,),
                             SizedBox(width: 1,),
                             Text( participant.role ?? 'N/A',),
                           ],
                         )
                                ),
                         DataCell(IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async{
                                var result = await deleteDutyForParticipant(participant.id!);
                                print(result);
                                setState(() {
                                
                                });
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

  Widget buildClassDropDownButton(Organization org,int tableIndex,List<DutyParticipant> dutyParticipants){
  //  print("org name:${org}");
  //  print("organization name in english: ${campusAppsPortalInstance.getUserPerson().organization!.name!.name_en!}");
  //  print("organization: ${campusAppsPortalInstance.getUserPerson().organization}");
  //  for(var org in campusAppsPortalInstance.getUserPerson().organization!.child_organizations){
  //     print("org name(child organizations):${org.name!.name_en}");
  //  }
  //  for(var org in org.child_organizations){
  //     print("org name(org.child_organizations):${org.name!.name_en}");
  //  }
   return DropdownButton<Organization>(
    value: _selectedClassValues[tableIndex],
    items: org.child_organizations.map<DropdownMenuItem<Organization>>((Organization  value){
     return DropdownMenuItem<Organization>(
      value: value,
      child: Text(value.description!),
     );
    }).toList(), 
    onChanged: (Organization? newValue) async{
       _selectedClassValue = newValue!;
       print(newValue.id);
       _fetchedOrganization = await fetchOrganization(newValue.id!);

       _selectedPersonValues[tableIndex] = null; // Reset selected person value when class changes

      // Remove people with names( _fetchedOrganization!.people list) that match the names in dutyParticipants
      _fetchedOrganization!.people.removeWhere((person) => 
        dutyParticipants.any((dutyParticipant) =>
          person.digital_id == dutyParticipant.person?.digital_id));

        setState(() {
         _selectedClassValues[tableIndex] = newValue;
         _dropDownPersonList[tableIndex] = _fetchedOrganization!.people;

        });
    },
    );

  }

  Widget buildPersonDropDownButton(int tableIndex){

  //if(_dropDownPersonList.isNotEmpty){

   return DropdownButton<String>(
    value:_selectedPersonValues[tableIndex],
    items: _dropDownPersonList[tableIndex].map<DropdownMenuItem<String>>((Person value){
     if(value.preferred_name !=null){
      return DropdownMenuItem<String>(
       value: value.digital_id,
       child: Text(value.preferred_name!),
      );
     }else{
       return DropdownMenuItem<String>(
        value: null,
        child:Text('No Preferred Name'),
        );
       }
      },
     ).toList(), 
     onChanged:(String? newValue) async{
     
        setState(() {
          _selectedPersonValues[tableIndex] = newValue;
          // print('table index(person drop down button):${tableIndex}');
          // print('selected person array values(person drop down button):${_selectedPersonValues}');
          // print('selected person values:${_selectedPersonValues[tableIndex]}');
          // print('selected drop down array(person drop down button):${_dropDownPersonList}');
          // print('selected drop down values(person drop down button):${_dropDownPersonList[tableIndex]}');
        });
       },
      
      );
  //  }else{
  //    return Text('Choose a  option in the first dropdown activate the second drop down');
  //  }
  
  }

 Widget buildRoleDropDownButton(int tableIndex){

   return DropdownButton<String>(
    value:_selectedRoleValues[tableIndex],
    items: _dropDownRoleList.map<DropdownMenuItem<String>>((String value){
      return DropdownMenuItem<String>(
       value: value,
       child: Text(value),
      );
      },
     ).toList(), 
    onChanged:(String? newValue) async{
       
        setState(() {
          _selectedRoleValues[tableIndex] = newValue;
          // print('table index(Role drop down button):${tableIndex}');
          // print('selected Role array values(Role drop down button):${_selectedRoleValues}');
          // print('selected Role values:${_selectedRoleValues[tableIndex]}');
         
        });
      
      if(_activitiesNames[tableIndex] !=null && _selectedRoleValues[tableIndex] !=null && _selectedPersonValues[tableIndex] !=null){
        
        String? activityName = _activitiesNames[tableIndex];
        Activity? activity  =   _activitiesByAvinyaType.firstWhere((activityObject) => activityObject.name == activityName);
        String? allocatedRole = _selectedRoleValues[tableIndex];
        String? personDigitalId = _selectedPersonValues[tableIndex];
        Person? person =  _dropDownPersonList[tableIndex].firstWhere((personObject) => personObject.digital_id == personDigitalId);

        var dutyForParticipant = DutyParticipant(
        activity_id: activity.id,
        person_id: person.id,
        role: allocatedRole,
       );

       bool hasLeaderRole = hasLeaderRoleWithActivity(activityName,allocatedRole);

       print('has a leader role ${hasLeaderRole}');

        if(!hasLeaderRole){
            var result = await  createDutyForParticipant(dutyForParticipant);
            print("add participant for duty result : ${result.id}");
       
            if(result.id != null){     
               _selectedRoleValues[tableIndex] = null;    //clear the drop down 
               _selectedPersonValues[tableIndex] = null;  //clear the drop down 
              _selectedClassValues[tableIndex] = null;    //clear the drop down 
           }
           setState(() {});
        }else{
           showDialog(
             context: context,
             builder: (BuildContext context) {
                    
               _selectedRoleValues[tableIndex] = null; //clear the drop down 
               _selectedPersonValues[tableIndex] = null;  //clear the drop down 
               _selectedClassValues[tableIndex] = null;      //clear the drop down 
           
             return Container(
              width: 300,
              height: 100,
              padding: EdgeInsets.all(8),
               child: AlertDialog(
                  title: Text(
                     'Error',
                     style: TextStyle(color: Colors.red), 
                    ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 40,
                       ),
                       SizedBox(height: 10,),
                       Text(
                        "A leader role participant is already added to this $activityName duty.",
                        textAlign: TextAlign.center,
                       ),
                       Text(
                        "You can't add another participant with a leader role.If you'd like to add this participant as a leader, please remove the current leader first.",
                        textAlign: TextAlign.center,
                       ),
                    ],
                  ),
                  actions: <Widget>[
                       TextButton(
                            onPressed: () {
                           Navigator.of(context).pop(); 
                         },
                       child: Text('OK'),
                ),
                         ],
                       ),
             );
           },
          );
        }
      }else{
         
         List<String> missingValues = []; 

         
         if(_selectedRoleValues[tableIndex] == null){
           missingValues.add('Role is missing.');
         }
         if(_selectedPersonValues[tableIndex] == null){
           missingValues.add('Person is missing.');
         }
        
        String errorMessage = 'The following values are missing: ${missingValues.join(', ')}';

          showDialog(
             context: context,
             builder: (BuildContext context) {
             return Container(
              width: 300,
              height: 100,
              padding: EdgeInsets.all(8),
               child: AlertDialog(
                  title: Text(
                     'Error',
                     style: TextStyle(color: Colors.red), 
                    ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 40,
                       ),
                       SizedBox(height: 10,),
                       Text(
                        'Cannot add duty for participant.',
                        textAlign: TextAlign.center,
                       ),
                       Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                       )
                    ],
                  ),
                  actions: <Widget>[
                       TextButton(
                            onPressed: () {
                           Navigator.of(context).pop(); 
                         },
                       child: Text('OK'),
                ),
                         ],
                       ),
             );
           },
          );
      }
    },
  );
}

Future<void> _selectStartDate(BuildContext context) async{
   final DateTime?  picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if(picked !=null){
      print(picked);
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      print(formattedDate);
      
      setState(() {
        _startDate.text = formattedDate;
        _startDateSelected= true;  
      });
    }else if(picked == null){
      setState(() {
         String formattedDate = '';
        _startDate.text = formattedDate;
        _startDateSelected = false;  
      });
    }
}

Future<void> _selectEndDate(BuildContext context) async{
   final DateTime?  picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if(picked !=null){
      print(picked);
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
    
      print(formattedDate);

      setState(() {
        _endDate.text = formattedDate;
        _endDateSelected = true;  // Set to true when end date is selected
      });

      var dutyRotationMetadata = DutyRotationMetaDetails(
         id: _rotationMetaDetails.id ?? 0,
         start_date:DateTime.parse(_startDate.text).toUtc().toIso8601String(),
         end_date:DateTime.parse(_endDate.text).toUtc().toIso8601String(),
         organization_id: campusAppsPortalInstance.getUserPerson().organization!.id!,
       );
        print("duty rotation meta data: ${dutyRotationMetadata}");
        var result = await updateDutyRotationMetadata(dutyRotationMetadata);
        print("update duty rotation ${result}");
        
        _rotationMetaDetails = await fetchDutyRotationMetadataByOrganization(campusAppsPortalInstance.getUserPerson().organization!.id!);

    }else if(picked == null){
      setState(() {
         String formattedDate = '';
        _endDate.text = formattedDate;
        _endDateSelected= false;  
      });
    }
}



}


