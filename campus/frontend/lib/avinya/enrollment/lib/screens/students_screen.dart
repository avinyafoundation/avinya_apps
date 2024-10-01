import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/students.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Enrollment & Records",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 120, 224, 158),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Students(),
            ],
          ),
        ),
      ),
    );
  }
}
