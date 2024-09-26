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
      appBar: AppBar(
        title: Text("Student Enrollment & Records",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 120, 224, 158),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height, // Ensure minimum height
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                StudentUpdate(id: widget.id), // Pass the ID
                // Add other widgets or buttons if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
