

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:attendance/data.dart';

class DutyAttendanceMarker extends StatefulWidget {
  const DutyAttendanceMarker({super.key});

  @override
  State<DutyAttendanceMarker> createState() => _DutyAttendanceMarkerState();
}

class _DutyAttendanceMarkerState extends State<DutyAttendanceMarker> {


 String? _selectedDutyTypeValue;

 List<Activity>  _activitiesByAvinyaType = [];
 List<String> _activitiesNames = [];

  @override
  void initState(){
   super.initState();
   loadActivitiesByAvinyaType();
   
  }


  Future<void> loadActivitiesByAvinyaType() async{

    _activitiesByAvinyaType = await fetchActivitiesByAvinyaType(91); //load avinya type =91(work) related activities
    _activitiesNames = _activitiesByAvinyaType
                     .where((activity) => activity.name !=null)
                      .map((activity) => activity.name!).toList();

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
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
                ),
              SizedBox(
                  width: 20,
                ),
              FutureBuilder<void>(
                future: loadActivitiesByAvinyaType(),
                builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting){
                   return CircularProgressIndicator();
                }else{
                  return buildDutyDropDownButton();
                }

               }
              ),
            ],
          )
        ],
      ),
    );
  }

 Widget buildDutyDropDownButton(){

   return DropdownButton<String>(
    value:_selectedDutyTypeValue,
    items: _activitiesNames.map<DropdownMenuItem<String>>((String value){
      return DropdownMenuItem<String>(
       value: value,
       child: Text(value),
        );
       },
      ).toList(), 
     onChanged:(String? newValue) async{
     
        setState(() {
          _selectedDutyTypeValue = newValue;
          
        });
       },
      
      );
  }

}