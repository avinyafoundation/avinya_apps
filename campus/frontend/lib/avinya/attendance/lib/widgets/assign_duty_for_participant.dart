import 'package:flutter/material.dart';
import 'package:attendance/data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/constants.dart';


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

  List<DutyParticipant> _dutyParticipants = [];
  List<Activity>  _activitiesByAvinyaType = []; 
  List<String?> _activitiesNames = [];
  List<DutyParticipant> _dutyRelatedParticipantsFilterAndStore = []; //filter And Store duty Relavant Participants

  @override
  void initState(){
    super.initState();
   loadActivitiesByAvinyaType();
  }

  Future<List<DutyParticipant>> loadDutyParticipantsData() async{

    return await fetchDutyParticipants();
  }

  Future<void> loadActivitiesByAvinyaType() async{

    _activitiesByAvinyaType = await fetchActivitiesByAvinyaType(91); //load avinya type =91(work) related activities
    _activitiesNames = _activitiesByAvinyaType.map((activities) => activities.name).toList();

    _dropDownPersonList = List.generate(_activitiesNames.length,(index) =>[]);
    _selectedClassValues = List.generate(_activitiesNames.length, (index) => null);
    _selectedPersonValues = List.generate(_activitiesNames.length, (index) => null);

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
        child: FutureBuilder(
          future:loadDutyParticipantsData(),         
          builder:(BuildContext context,snapshot){
           if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SpinKitCircle(
                          color: (Colors
                              .blue), 
                          size: 70,
                        ),
                    );
                    
           }if (snapshot.connectionState == ConnectionState.done) {
             
              if(snapshot.hasError){
                
                return Center(
                    child: Text(
                      'An ${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
              );

             }if(snapshot.hasData){

             return ListView.builder(
                    shrinkWrap: true,                
                    itemCount: _activitiesNames.length,
                    itemBuilder: (context,tableIndex){
                    print('table index:{$tableIndex}');
                    _dutyRelatedParticipantsFilterAndStore.clear();
                    _dutyParticipants = (snapshot.data as List<DutyParticipant>);
                    _dutyRelatedParticipantsFilterAndStore = _dutyParticipants.where((filterParticipant)=>filterParticipant.activity!.name ==  _activitiesNames[tableIndex]).toList();
                    print('dutyRelatedParticipantsFilterAndStore: ${_dutyRelatedParticipantsFilterAndStore}');
                    print('length is: ${_dutyRelatedParticipantsFilterAndStore.length}');
                    return  Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            for (var org in campusAppsPortalInstance
                                .getUserPerson()
                                .organization!
                                .child_organizations)  
                              
                              if (org.child_organizations.length > 0)                             
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Flexible(                             
                                                child: Text(
                                                  '${_activitiesNames[tableIndex]}',
                                                   overflow: TextOverflow.ellipsis,
                                                  )
                                              ),
                                             Flexible(
                                                child: buildClassDropDownButton(org,tableIndex,_dutyParticipants)
                                              ),
                                            Flexible(
                                                child: buildPersonDropDownButton(tableIndex)
                                              ),
                                            
                                          ],
                                        ),        
                                buildTable(_dutyRelatedParticipantsFilterAndStore,tableIndex),
                                SizedBox(
                                  height: 30,
                                )
                          ],
                          
                        ),
                    );
                },    
              );
           }
          }
          return Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SpinKitCircle(
                          color: (Colors
                              .blue),
                          size: 70, 
                        ),
              );
         },
        ));
  }

  Widget buildTable(List<DutyParticipant> dutyRelatedParticipantsFilterAndStore,int tableIndex){
    return Card(
         child: Padding(
          padding:const EdgeInsets.all(8.0),
          child: Column(
          children: [
  
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 800,
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
                           "Remove",
                           style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                           ),
                  ),
                ], 
                rows: dutyRelatedParticipantsFilterAndStore.map((participant){
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
                         DataCell(Icon(Icons.delete))
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
   print("org name:${org}");
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
        setState(() {
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
       value: value.preferred_name,
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
     onChanged:(String? newValue){
        setState(() {
          _selectedPersonValues[tableIndex] = newValue;
          print('table index(person drop down button):${tableIndex}');
          print('selected person array values(person drop down button):${_selectedPersonValues}');
          print('selected person values:${_selectedPersonValues[tableIndex]}');
          print('selected drop down array(person drop down button):${_dropDownPersonList}');
          print('selected drop down values(person drop down button):${_dropDownPersonList[tableIndex]}');
        });
       },
      
      );
  //  }else{
  //    return Text('Choose a  option in the first dropdown activate the second drop down');
  //  }
  
  }



}


