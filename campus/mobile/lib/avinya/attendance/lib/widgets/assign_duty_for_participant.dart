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

  late TextEditingController  _startDate;
  late TextEditingController _endDate;

  bool _startDateSelected = false;
  bool _endDateSelected = false;


  @override
  void initState(){
   super.initState();
   loadActivitiesByAvinyaType();
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
        //height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                height: 50,
              ),
            _startDateSelected && _endDateSelected 
              ? SizedBox()
              : Text(
                'Please select both start and end dates',
                style: TextStyle(color: Colors.red),  
              ),
            FutureBuilder(
              future:loadDutyParticipantsData(campusAppsPortalInstance.getUserPerson().organization!.id!),         
              builder:(BuildContext context,snapshot){
               if (snapshot.connectionState == ConnectionState.waiting) {
                // return Container(
                //             margin: EdgeInsets.only(top: 10),
                //             child: SpinKitCircle(
                //               color: (Colors
                //                   .blue), 
                //               size: 70,
                //             ),
                //         );
                        
               }
               //if (snapshot.connectionState == ConnectionState.done) {
                 
                  // if(snapshot.hasError){
                    
                  //   return Center(
                  //       child: Text(
                  //         'An ${snapshot.error} occurred',
                  //         style: const TextStyle(fontSize: 18, color: Colors.red),
                  //       ),
                  // );

                 //}
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
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                             style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)
                                                            )
                                                           ],
                                                          ),
                                                       ), 
                                                    SizedBox(
                                                      width: 10,
                                                    ),                                                   
                                                    Container(                                                  
                                                        child: buildClassDropDownButton(org,tableIndex,_dutyParticipants)
                                                      ),   
                                                    SizedBox(
                                                      width: 10,
                                                    ),                                          
                                                    Container(
                                                        
                                                        child: buildPersonDropDownButton(tableIndex)
                                                      ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),   
                                                    Container(
                                                        
                                                        child: buildRoleDropDownButton(tableIndex)
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
          print('new organization value:${newValue.name!.name_en}');
         _selectedClassValues[tableIndex] = newValue;
         _dropDownPersonList[tableIndex] = _fetchedOrganization!.people;
          print('table index(class drop down button):${tableIndex}');
          print('selected class array values(class drop down button):${_selectedClassValues}');
          print('selected class values:${ _selectedClassValues[tableIndex]}');

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
               _selectedRoleValues[tableIndex] = null;
               _selectedPersonValues[tableIndex] = null;
              _selectedClassValues[tableIndex] = null;      
           }
        }else{
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
                        "A leader role participant is already added to this $activityName duty.",
                        textAlign: TextAlign.center,
                       ),
                       Text(
                        "You can't add another participant with a leader role.",
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
      String formattedDate = 
             DateFormat('yyyy-MM-dd').format(picked);
      print(formattedDate);
      
      setState(() {
        _startDate.text = formattedDate;
        _startDateSelected= true;  // Set to true when start date is selected
      });
    }else if(picked == null){
      setState(() {
         String formattedDate = '';
        _startDate.text = formattedDate;
        _startDateSelected = false;  // Set to true when start date is selected
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
      String formattedDate = 
             DateFormat('yyyy-MM-dd').format(picked);
      print(formattedDate);

      setState(() {
        _endDate.text = formattedDate;
        _endDateSelected = true;  // Set to true when end date is selected
      });

      var dutyRotationMetadata = DutyRotationMetadata(
         id: 1,
         start_date: _startDate.text,
         end_date:_endDate.text ,
       );

        var result = await updateDutyRotation(dutyRotationMetadata);
        print("update duty rotation ${result}");
        if(result.id !=null){
          _startDate.text = '';
          _endDate.text = '';
        }

    }else if(picked == null){
      setState(() {
         String formattedDate = '';
        _endDate.text = formattedDate;
        _endDateSelected= false;  // Set to true when start date is selected
      });
    }
}



}


