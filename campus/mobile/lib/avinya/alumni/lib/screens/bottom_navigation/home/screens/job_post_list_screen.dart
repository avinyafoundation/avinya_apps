import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/avinya/alumni/lib/data/job_post.dart';
import 'package:mobile/avinya/alumni/lib/screens/bottom_navigation/home/widgets/job_post_list_widget.dart';

class JobPostListScreen extends StatefulWidget {
 

  const JobPostListScreen({Key? key})
      : super(key: key);
  @override
  State<JobPostListScreen> createState() => _JobPostListScreenState();
}

class _JobPostListScreenState extends State<JobPostListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: JobPostListWidget()
    );
  }
}
