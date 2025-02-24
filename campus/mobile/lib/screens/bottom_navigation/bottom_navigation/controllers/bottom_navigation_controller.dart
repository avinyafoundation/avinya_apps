import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/screens/bottom_navigation/home/screens/my_alumni_dashboard.dart';

class BottomNavigationController extends GetxController {
  static BottomNavigationController get find => Get.find();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    MyAlumniDashboardScreen(),
    Container(
      color: Colors.purple,
    ),
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.yellow,
    )
  ];
}
