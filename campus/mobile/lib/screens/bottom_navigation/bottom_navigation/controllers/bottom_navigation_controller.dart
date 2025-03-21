import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/pages/alumni_info_view.dart';
import 'package:mobile/screens/bottom_navigation/home/screens/my_alumni_dashboard.dart';
import 'package:mobile/screens/bottom_navigation/home/screens/under_development.dart';

class BottomNavigationController extends GetxController {
  static BottomNavigationController get find => Get.find();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    MyAlumniDashboardScreen(),
    UnderDevelopmentScreen(),
    UnderDevelopmentScreen(),
    Container(color: kOtherColor, child: MyAlumniScreen())
  ];
}
