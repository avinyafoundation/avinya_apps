import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:attendance/widgets/assign_duty_for_participant.dart';
import 'package:attendance/data.dart';


import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;





class DutyParticipantsScreen extends StatefulWidget {
  const DutyParticipantsScreen({super.key});

  @override
  State<DutyParticipantsScreen> createState() => _DutyParticipantsScreenState();
}

class _DutyParticipantsScreenState extends State<DutyParticipantsScreen> {

  List<Activity>  _activitiesByAvinyaType = []; 
  List<DutyParticipant> _dutyParticipants = [];
  var  organization_id;

  void initState(){
   super.initState();
   organization_id = campusAppsPortalInstance.getUserPerson().organization!.id!;
   loadActivitiesByAvinyaType();
   loadDutyParticipantsData();
  }


  Future<void> loadDutyParticipantsData() async{

    _dutyParticipants = await fetchDutyParticipants(organization_id);
  }

  Future<void> loadActivitiesByAvinyaType() async{

    _activitiesByAvinyaType = await fetchActivitiesByAvinyaType(91); //load avinya type =91(work) related activities
    _activitiesByAvinyaType.removeWhere((activity) => activity.name == 'work');

    
  }

void generateDutyParticipantsReportPdf() async{

   final pdf = pw.Document();

  for(var activity in _activitiesByAvinyaType){

    final participantsForActivity = _dutyParticipants
        .where((participant) => participant.activity!.id == activity.id).toList();
    
    pdf.addPage(pw.MultiPage(
       pageFormat: PdfPageFormat.a4,
       header:(pw.Context context){
        return  pw.Container(
          alignment: pw.Alignment.center,
          margin: pw.EdgeInsets.only(bottom: 10.0),
          child: pw.Text('${activity.name}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              )),
         );
       },
       build: (pw.Context context){
       return [pw.Center(
          child: pw.Table.fromTextArray(
            context: context,
            data: <List<String?>>[
              <String>['Student Name', 'Digital Id', 'Class', 'Role'],
              for (var participant in participantsForActivity)
                <String?>[
                  participant.person!.preferred_name,
                  participant.person!.digital_id,
                  participant.person!.organization?.description,
                  participant.role
                ],
            ],
          ),      
        )
       ];
       },
      ),
    );
  }

  var savedFile = await pdf.save();
  List<int> fileInts = List.from(savedFile);
  html.AnchorElement(
   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
  ..setAttribute("download", "duty_participants_${DateTime.now().toLocal().toIso8601String().split('T')[0]}.pdf")
  ..click();

  }



  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Duty Participants"),
      ),
      body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                AssignDutyForParticipant(),
              ],
            ),
          ), 
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Duty Participants Report',
        child: Icon(Icons.download),
        onPressed: () async{
          generateDutyParticipantsReportPdf();
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
