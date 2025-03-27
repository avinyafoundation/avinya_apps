import 'package:flutter/material.dart';
import 'package:gallery/avinya/academic_scheduler/lib/widgets/academic_scheduler_dashboard.dart';

class AcademicSchedulerDashboardScreen extends StatefulWidget {
  const AcademicSchedulerDashboardScreen({super.key});

  @override
  State<AcademicSchedulerDashboardScreen> createState() => _AcademicSchedulerDashboardScreenState();
}

class _AcademicSchedulerDashboardScreenState extends State<AcademicSchedulerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AcademicSchedulerDashboard(),
    );
  }
}