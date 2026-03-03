import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/student_update.dart';

class StudentUpdateScreen extends StatefulWidget {
  final int? id;

  const StudentUpdateScreen({Key? key, this.id}) : super(key: key);

  @override
  State<StudentUpdateScreen> createState() => _StudentUpdateScreenState();
}

class _StudentUpdateScreenState extends State<StudentUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Student Profile", style: TextStyle(color: Colors.black)),
      //   backgroundColor: Color.fromARGB(255, 120, 224, 158),
      // ),
      body: Container(
        child: StudentUpdate(id: widget.id),
      ),
    );
  }
}
