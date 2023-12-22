import 'package:flutter/material.dart';
import 'package:attendance/widgets/assign_duty_for_participant.dart';


class DutyParticipantsScreen extends StatefulWidget {
  const DutyParticipantsScreen({super.key});

  @override
  State<DutyParticipantsScreen> createState() => _DutyParticipantsScreenState();
}

class _DutyParticipantsScreenState extends State<DutyParticipantsScreen> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Duty Participants",style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 236, 230, 253),
      ),
      body: SingleChildScrollView(
          child: Container(    
           child:Column(children: [
           Container(child: AssignDutyForParticipant()),
           ],
           )     
          ), 
      ),

    );
  }
}