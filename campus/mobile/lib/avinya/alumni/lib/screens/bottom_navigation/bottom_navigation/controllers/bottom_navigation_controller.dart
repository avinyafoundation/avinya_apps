import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/avinya/alumni/lib/data/job_post.dart';
import 'package:mobile/avinya/alumni/lib/screens/bottom_navigation/home/screens/job_post_list_screen.dart';
import 'package:mobile/constants.dart';
import 'package:alumni/screens/alumni_info_view_edit.dart';
import 'package:alumni/screens/bottom_navigation/home/screens/my_alumni_dashboard.dart';
import 'package:mobile/screens/bottom_navigation/home/screens/under_development.dart';

class BottomNavigationController extends GetxController {
  static BottomNavigationController get find => Get.find();

  final Rx<int> selectedIndex = 0.obs;
  final Rx<bool> lookingForJob = false.obs;
  final Rx<bool> updateCV = false.obs;
 
  late final PagingController<int, JobPost> pagingController;

  @override
  void onInit() {
    super.onInit();
    pagingController = PagingController(firstPageKey: 0);
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  final screens = [
    MyAlumniDashboardScreen(),
    const JobPostListScreen(),
    UnderDevelopmentScreen(),
    Container(color: kOtherColor, child: MyAlumniInfoViweScreen())
  ];
}
