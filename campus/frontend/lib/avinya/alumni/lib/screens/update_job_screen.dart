import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/widgets/update_job_widget.dart';

class UpdateJobScreen extends StatefulWidget {
  final int? id;
  const UpdateJobScreen({super.key, this.id});

  @override
  State<UpdateJobScreen> createState() => _UpdateJobScreenState();
}

class _UpdateJobScreenState extends State<UpdateJobScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Update a Job', style: TextStyle(color: Colors.white))),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              UpdateJobWidget(
                jobPostId: widget.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
