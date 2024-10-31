import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/student_create.dart';

class StudentCreateScreen extends StatefulWidget {
  final int? id;

  const StudentCreateScreen({Key? key, this.id}) : super(key: key);

  @override
  State<StudentCreateScreen> createState() => _StudentCreateScreenState();
}

class _StudentCreateScreenState extends State<StudentCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 120, 224, 158),
      ),
      body: Container(
        child: StudentCreate(id: widget.id),
      ),
    );
  }
}
