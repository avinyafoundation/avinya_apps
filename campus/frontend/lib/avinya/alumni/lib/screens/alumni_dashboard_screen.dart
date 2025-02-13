import 'package:flutter/material.dart';
import 'package:gallery/avinya/alumni/lib/widgets/alumni_dashboard.dart';

class AlumniDashboardScreen extends StatefulWidget {
  const AlumniDashboardScreen({super.key});

  @override
  State<AlumniDashboardScreen> createState() => _AlumniDashboardScreenState();
}

class _AlumniDashboardScreenState extends State<AlumniDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AlumniDashboard(),
    );
  }
}
