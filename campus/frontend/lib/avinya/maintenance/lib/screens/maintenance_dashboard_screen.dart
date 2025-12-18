import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/widgets/director_dashboard.dart';

class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  State<MaintenanceDashboardScreen> createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends State<MaintenanceDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DirectorDashboardScreen(),
    );
  }
}
