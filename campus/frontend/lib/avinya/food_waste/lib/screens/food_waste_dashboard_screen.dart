import 'package:flutter/material.dart';
import '../widgets/dashboard.dart';

class FoodWasteDashboardScreen extends StatefulWidget {
  const FoodWasteDashboardScreen({super.key});

  @override
  State<FoodWasteDashboardScreen> createState() =>
      _FoodWasteDashboardScreenState();
}

class _FoodWasteDashboardScreenState
    extends State<FoodWasteDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DashboardScreen(),
    );
  }
}
