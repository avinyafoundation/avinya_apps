import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/screens/bottom_navigation/bottom_navigation/controllers/bottom_navigation_controller.dart';

class NavigationMenu extends StatelessWidget {
  NavigationMenu({super.key});

  final BottomNavigationController _onBoardingController =
      Get.put(BottomNavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            currentIndex: _onBoardingController.selectedIndex.value,
            onTap: (index) => _onBoardingController.selectedIndex.value = index,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.card_travel), label: 'My Works'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ]);
      }),
      body: Obx(() {
        return _onBoardingController
            .screens[_onBoardingController.selectedIndex.value];
      }),
    );
  }
}
