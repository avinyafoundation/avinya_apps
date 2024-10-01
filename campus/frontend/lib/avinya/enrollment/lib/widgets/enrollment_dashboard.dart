import 'package:flutter/material.dart';

class EnrollmentDashboard extends StatefulWidget {
  const EnrollmentDashboard({super.key});

  @override
  State<EnrollmentDashboard> createState() => _EnrollmentDashboardState();
}

class _EnrollmentDashboardState extends State<EnrollmentDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Enrollment Dashboard screen'),);
  }
}