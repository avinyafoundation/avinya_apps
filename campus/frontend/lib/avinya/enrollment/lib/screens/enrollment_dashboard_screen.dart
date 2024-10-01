import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/enrollment_dashboard.dart';

class EnrollmentDashboardScreen extends StatefulWidget {
  const EnrollmentDashboardScreen({super.key});

  @override
  State<EnrollmentDashboardScreen> createState() => _EnrollmentDashboardScreenState();
}

class _EnrollmentDashboardScreenState extends State<EnrollmentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EnrollmentDashboard(),
    );
  }
}