import 'package:flutter/material.dart';

import '../widgets/consumable_dashboard.dart';

class ConsumableDashboardScreen extends StatefulWidget {
  const ConsumableDashboardScreen({super.key});

  @override
  State<ConsumableDashboardScreen> createState() => _ConsumableDashboardScreenState();
}

class _ConsumableDashboardScreenState extends State<ConsumableDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ConsumableDashboard(),
    );
  }
}