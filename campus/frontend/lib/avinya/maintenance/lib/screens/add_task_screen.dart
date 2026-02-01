import 'package:flutter/material.dart';
//import 'package:mock_maintenance_web/widgets/add_task_form.dart';
import '../widgets/task_create_form.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaskCreateForm(), 
    );
  }
}
