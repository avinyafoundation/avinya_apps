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
        title: Text("Duty Participants"),
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