import 'package:get/get.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';

class HomeController extends GetxController {
  static HomeController get find => Get.find();

  final Rx<int> selectedIndex = 0.obs;
  final Rx<bool> lookingForJob = false.obs;
  final Rx<bool> updateCV = false.obs;
  
  var alumniPersonModel = AlumniPerson(is_graduated: false).obs;
  var userPersonModel = Person(is_graduated: false).obs;
  var workExperienceModel = WorkExperience().obs;
  var EducationQualificationsModel = EducationQualifications().obs;
  
}
