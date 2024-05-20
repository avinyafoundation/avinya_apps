import 'package:flutter/material.dart';

class AssetDashboardScreen extends StatefulWidget {
  const AssetDashboardScreen({super.key});

  @override
  State<AssetDashboardScreen> createState() => _AssetDashboardScreenState();
}

class _AssetDashboardScreenState extends State<AssetDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Asset Dashboard Screen'),
    );
  }
}