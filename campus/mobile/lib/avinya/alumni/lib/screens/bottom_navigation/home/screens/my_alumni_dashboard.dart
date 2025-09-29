import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/auth.dart';
import 'package:mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:alumni/data/activity_instance.dart';
import 'package:alumni/data/activity_instance_evaluation.dart';
import 'package:alumni/data/activity_participant.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';
import 'package:alumni/screens/alumni_info_view_edit.dart';
import 'package:alumni/screens/bottom_navigation/home/controllers/home_controller.dart';
import 'package:alumni/widgets/time_line_widget.dart';
import 'package:mobile/widgets/avinya_logo_widget.dart';
import 'package:mobile/widgets/avinya_brand_header.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAlumniDashboardScreen extends StatefulWidget {
  const MyAlumniDashboardScreen({Key? key}) : super(key: key);

  @override
  _MyAlumniDashboardScreenState createState() =>
      _MyAlumniDashboardScreenState();
}

class _MyAlumniDashboardScreenState extends State<MyAlumniDashboardScreen> {
  final HomeController _homeController = Get.put(HomeController());
  bool showFeedbackForm = false;
  //late Future<List<ActivityInstance>> _upcomingEventsData;
  //late Future<List<ActivityInstance>> _completedEventsData;
  String? selectedRsvp;
  String feedback = '';
  int? selectedRating;
  late Person userPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  late AlumniPerson alumniPerson = AlumniPerson(is_graduated: null)
    ..full_name = 'John'
    ..nic_no = '12';

  Color turquoiseBlue = Color(0xFF009DB1);
  int person_id = 0;

  @override
  void initState() {
    super.initState();
    person_id = campusAppsPortalInstance.getUserPerson().id!;
    userPerson = campusAppsPortalInstance.getUserPerson();
    getUserPerson(person_id);
    // if (person_id != null) {
    //   _upcomingEventsData = _loadUpcomingEventsData(person_id);
    //   _completedEventsData = _loadCompletedEventsData(person_id);
    // }
  }

  // void getUserPerson() {
  //   // Retrieve user data from local instance
  //   Person user = campusAppsPortalInstance.getUserPerson();
  //   _fetchAlumniPersonData(user.id);
  //   setState(() {
  //     userPerson = user;
  //   });
  // }
  void getUserPerson(int person_id) async {
    // Retrieve user data from local instance
    //AlumniPerson AlumniUser = campusAppsPortalInstance.getAlumniUserPerson();
    AlumniPerson AlumniUser;
    if (alumniPerson.id == null) {
      // to check alumni object is null
      AlumniUser = await fetchAlumniPerson(person_id);
      campusAppsPortalInstance.setAlumniUserPerson(AlumniUser);
    } else {
      AlumniUser = campusAppsPortalInstance.getAlumniUserPerson();
    }

    setState(() {
      alumniPerson = AlumniUser;
    });
  }

  Future<List<ActivityInstance>> _loadUpcomingEventsData(int person_id) async {
    return await fetchUpcomingEvents(person_id);
  }

  Future<List<ActivityInstance>> _loadCompletedEventsData(int person_id) async {
    return await fetchCompletedEvents(person_id);
  }

  // Future<AlumniPerson> _fetchAlumniPersonData(id) async {
  //   alumniPerson = await fetchAlumniPerson(id);
  //   setState(() {
  //     alumniPerson = alumniPerson;
  //   });
  //   return alumniPerson;
  // }

  void handleRsvp(String? value) {
    setState(() {
      selectedRsvp = value;
      showFeedbackForm = value == 'yes';
    });
  }

  Widget _getAnimalIcon(String description) {
    String imagePath = 'assets/images/';
    switch (description.toLowerCase()) {
      case 'leopards':
        imagePath += 'leopards.png';
        break;
      case 'bears':
        imagePath += 'bears.png';
        break;
      case 'bees':
        imagePath += 'bees.png';
        break;
      case 'eagles':
        imagePath += 'eagles.png';
        break;
      case 'dolphins':
        imagePath += 'dolphins.png';
        break;
      case 'elephants':
        imagePath += 'elephants.png';
        break;
      case 'sharks':
        imagePath += 'sharks.png';
        break;
      default:
        imagePath += 'question.png';
        break;
    }
    return Image.asset(
      imagePath,
      width: SizerUtil.deviceType == DeviceType.tablet ? 9.w : 7.w,
      height: SizerUtil.deviceType == DeviceType.tablet ? 9.h : 7.h,
    );
  }

  Widget _buildStatusSection(AlumniPerson alumniPerson) {
    print(
        '===============HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII=======================');
    final status = alumniPerson.alumni != null
        ? alumniPerson.alumni!.status ?? 'N/A'
        : 'N/A';

    //Get the latest working experience
    final workList = alumniPerson.alumni_work_experience ?? [];
    workList.sort((a, b) {
      //First, prioritize the currently working entries
      int bVal = (b.currentlyWorking ?? false) ? 1 : 0;
      int aVal = (a.currentlyWorking ?? false) ? 1 : 0;
      if (bVal != aVal) {
        return bVal - aVal;
      }
      //Then sort by latest start date
      final aStart = a.startDate ?? '';
      final bStart = b.startDate ?? '';

      return bStart.compareTo(aStart);
    });

    final latestWork = workList.isNotEmpty ? workList.first : null;

    final eduList = alumniPerson.alumni_education_qualifications ?? [];
    eduList.sort((a, b) {
      int bVal = (b.isCurrentlyStudying ?? false) ? 1 : 0;
      int aVal = (a.isCurrentlyStudying ?? false) ? 1 : 0;
      if (bVal != aVal) {
        return bVal - aVal;
      }

      final aStart = a.startDate ?? '';
      final bStart = b.startDate ?? '';

      return bStart.compareTo(aStart);
    });

    //Get the latest education experience
    final latestEdu = eduList.isNotEmpty ? eduList.first : null;

    switch (status) {
      case 'Working':
        return Table(
          columnWidths: {
            0: FixedColumnWidth(20.w),
            1: FlexColumnWidth(),
          },
          children: [
            if (latestWork != null) ...[
              TableRow(
                children: [
                  Text('Company :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '${latestWork.companyName != null ? latestWork.companyName : 'N/A'}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              TableRow(
                children: [
                  Text('Job Title :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${latestWork.jobTitle}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              )
            ]
          ],
        );
      case 'Studying':
        return Table(
          columnWidths: {
            0: FixedColumnWidth(20.w),
            1: FlexColumnWidth(),
          },
          children: [
            if (latestEdu != null) ...[
              TableRow(
                children: [
                  Text('Institute :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '${latestEdu.universityName != null ? latestEdu.universityName : 'N/A'}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              TableRow(
                children: [
                  Text('Programme :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${latestEdu.courseName}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              )
            ],
          ],
        );
      case 'WorkAndStudy':
        return Table(
          columnWidths: {
            0: FixedColumnWidth(20.w),
            1: FlexColumnWidth(),
          },
          children: [
            if (latestWork != null) ...[
              TableRow(
                children: [
                  Text('Company :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '${latestWork.companyName != null ? latestWork.companyName : 'N/A'}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              TableRow(
                children: [
                  Text('Job Title :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${latestWork.jobTitle}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              )
            ],
            if (latestEdu != null) ...[
              TableRow(
                children: [
                  Text('Institute :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '${latestEdu.universityName != null ? latestEdu.universityName : 'N/A'}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              TableRow(
                children: [
                  Text('Programme :',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${latestEdu.courseName}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            //letterSpacing: 1.2,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              )
            ],
          ],
        );
      case 'Other':
        return Table(
          columnWidths: {
            0: FixedColumnWidth(20.w),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                Text('Reason :',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: kTextBlackColor,
                          //letterSpacing: 1.2,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 10.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 12.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 06.sp
                                      : 08.sp,
                        ),
                    //maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text('${"House wife"}',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: kTextBlackColor,
                          //letterSpacing: 1.2,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 10.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 12.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 06.sp
                                      : 08.sp,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        );
      default:
        return SizedBox();
    }
  }

  Widget _renderSocialLinks(
      {required String assetPath,
      required String platformName,
      required String? url,
      Color activeColor = Colors.blue,
      Color inactiveColor = Colors.grey}) {
    final isValid = url != null && url.trim().isNotEmpty;

    String getShortUrl(String fullUrl) {
      try {
        final trimmedUrl = fullUrl.trim();
        Uri uri = Uri.parse(trimmedUrl);
        return uri.host.replaceFirst('www.', '') + uri.path;
      } catch (_) {
        return 'N/A';
      }
    }

    return Row(
      children: [
        Text('${platformName} :',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: kTextBlackColor,
                  //letterSpacing: 1.2,
                  fontSize: SizerUtil.deviceType == DeviceType.mobile
                      ? 10.sp
                      : SizerUtil.deviceType == DeviceType.tablet
                          ? 12.sp
                          : SizerUtil.deviceType == DeviceType.web
                              ? 06.sp
                              : 08.sp,
                ),
            //maxLines: 2,
            overflow: TextOverflow.ellipsis),
        SizedBox(
          width: 1.w,
        ),
        isValid
            ? GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(getShortUrl(url!),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: activeColor,
                          decoration: TextDecoration.underline,
                          //letterSpacing: 1.2,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 10.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 12.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 06.sp
                                      : 08.sp,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              )
            : SizedBox()
      ],
    );
  }

  void _showEditModal(
      BuildContext context, Map<String, String> item, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditModal(
          item: item,
          type: type,
          onDelete: _deleteExperience,
          onUpdate: _updateExperience,
        );
      },
    );
  }

  void _updateExperience(
    Map<String, String> item,
    String type,
    String company,
    String title,
    String university,
    String course,
    String startDate,
    String endDate,
    bool isCurrent,
  ) async {
    try {
      if (type == 'work') {
        // Update work experience
        WorkExperience updatedWork = WorkExperience(
          id: int.tryParse(item['id'] ?? ''),
          companyName: company,
          jobTitle: title,
          startDate: startDate,
          endDate: isCurrent ? null : endDate,
          currentlyWorking: isCurrent,
        );
        await updateAlumniWorkQualification(updatedWork);
        setState(() {
          AlumniPerson alumniUser =
              campusAppsPortalInstance.getAlumniUserPerson();
          int index = alumniUser.alumni_work_experience!
              .indexWhere((work) => work.id == updatedWork.id);
          if (index != -1) {
            alumniUser.alumni_work_experience![index] = updatedWork;
          }
        });
      } else {
        // Update study experience
        EducationQualifications updatedStudy = EducationQualifications(
          id: int.tryParse(item['id'] ?? ''),
          universityName: university,
          courseName: course,
          startDate: startDate,
          endDate: isCurrent ? null : endDate,
          isCurrentlyStudying: isCurrent,
        );
        await updateAlumniEduQualification(updatedStudy);
        setState(() {
          AlumniPerson alumniUser =
              campusAppsPortalInstance.getAlumniUserPerson();
          int index = alumniUser.alumni_education_qualifications!
              .indexWhere((work) => work.id == updatedStudy.id);
          if (index != -1) {
            alumniUser.alumni_education_qualifications![index] = updatedStudy;
          }
        });
      }
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $type: $e')),
      );
    }
  }

  void _deleteExperience(Map<String, String> item, String type) async {
    try {
      int id = int.tryParse(item['id'] ?? '')!;

      if (type == 'work') {
        await deleteAlumniWorkQualification(id);

        // Remove the item from the alumni_work_experience list
        AlumniPerson alumniUser =
            campusAppsPortalInstance.getAlumniUserPerson()!;
        alumniUser.alumni_work_experience!.removeWhere((work) => work.id == id);
      } else {
        // Call API to delete education qualification
        await deleteAlumniEduQualification(id);

        // Remove the item from the alumni_education_qualifications list
        AlumniPerson alumniUser =
            campusAppsPortalInstance.getAlumniUserPerson()!;
        alumniUser.alumni_education_qualifications!
            .removeWhere((edu) => edu.id == id);
      }

      // Refresh the UI after removing the item
      setState(() {});

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type deleted successfully!')),
      );
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete $type: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = alumniPerson.preferred_name?.split(' ').first ?? 'User';
    String imagePath = alumniPerson.sex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpg'; // Default or female profile image

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kDarkModeSurfaceColor
                    : kOtherColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: RepaintBoundary(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AvinyaBrandHeaderWidget(),
                        Text('👋 Welcome ${firstName}!',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color: turquoiseBlue,
                                  letterSpacing: 1.2,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 14.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 16.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 10.sp
                                                  : 12.sp,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (userPerson.is_graduated != null &&
                            userPerson.is_graduated!) ...[
                          Text('Avinya ACC',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: kTextBlackColor,
                                    letterSpacing: 1.2,
                                    fontSize: SizerUtil.deviceType ==
                                            DeviceType.mobile
                                        ? 12.sp
                                        : SizerUtil.deviceType ==
                                                DeviceType.tablet
                                            ? 14.sp
                                            : SizerUtil.deviceType ==
                                                    DeviceType.web
                                                ? 08.sp
                                                : 10.sp,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          Text('Avinya Alumni Community Center',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: kTextBlackColor,
                                      //letterSpacing: 1.2,
                                      fontSize: SizerUtil.deviceType ==
                                              DeviceType.mobile
                                          ? 08.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 06.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ] else
                          Text('Avinya Student',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: kTextBlackColor,
                                    letterSpacing: 1.2,
                                    fontSize: SizerUtil.deviceType ==
                                            DeviceType.mobile
                                        ? 12.sp
                                        : SizerUtil.deviceType ==
                                                DeviceType.tablet
                                            ? 14.sp
                                            : SizerUtil.deviceType ==
                                                    DeviceType.web
                                                ? 08.sp
                                                : 10.sp,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        Text(
                            '${alumniPerson.organization != null ? alumniPerson.organization!.parent_organizations.first.name!.name_en ?? 'N/A' : '/NA'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color: kTextBlackColor,
                                  //letterSpacing: 1.2,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 10.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 06.sp
                                                  : 08.sp,
                                ),
                            //maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getAnimalIcon(alumniPerson.organization != null
                                ? alumniPerson.organization!.description ??
                                    'N/A'
                                : 'N/A'),
                            Text(
                                '${alumniPerson.organization != null ? alumniPerson.organization!.description ?? 'N/A' : '/NA'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: kTextBlackColor,
                                      //letterSpacing: 1.2,
                                      fontSize: SizerUtil.deviceType ==
                                              DeviceType.mobile
                                          ? 10.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 06.sp
                                                  : 08.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        // SizedBox(
                        //   height: 1.h,
                        // ),
                        CircleAvatar(
                          radius: SizerUtil.deviceType == DeviceType.tablet
                              ? 12.w
                              : 13.w,
                          backgroundColor: kSecondaryColor,
                          backgroundImage:
                              alumniPerson.alumni_profile_picture?.picture !=
                                      null
                                  ? MemoryImage(base64Decode(alumniPerson
                                      .alumni_profile_picture!.picture!))
                                  : AssetImage(imagePath) as ImageProvider,
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Table(
                          columnWidths: {
                            0: FixedColumnWidth(20.w),
                            1: FlexColumnWidth(), // Value (takes the rest)// Width for labels
                          },
                          children: [
                            TableRow(
                              children: [
                                Text('NIC :',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    //maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    '${alumniPerson.nic_no != null ? alumniPerson.nic_no : 'N/A'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text('Phone :',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    //maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    '${alumniPerson.phone != null ? alumniPerson.phone : 'N/A'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text('Status :',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    //maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    '${alumniPerson.alumni != null ? alumniPerson.alumni!.status : 'N/A'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          //letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 10.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 12.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 06.sp
                                                      : 08.sp,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),

                            // SizedBox(
                            //   height: 1.h,
                            // ),
                            // _renderSocialLinks(
                            //     assetPath: "assets/images/linkedin.png",
                            //     platformName: "Linkedin",
                            //     url: alumniPerson.alumni?.linkedin_id),
                            // _renderSocialLinks(
                            //     assetPath: "assets/images/facebook.png",
                            //     platformName: "Facebook",
                            //     url: alumniPerson.alumni?.facebook_id),
                            // _renderSocialLinks(
                            //     assetPath: "assets/images/instagram.png",
                            //     platformName: "Instagram",
                            //     url: alumniPerson.alumni?.instagram_id),
                            // _renderSocialLinks(
                            //     assetPath: "assets/images/tiktok.png",
                            //     platformName: "Tiktok",
                            //     url: alumniPerson.alumni?.tiktok_id),
                          ],
                        ),
                        _buildStatusSection(alumniPerson),
                        SizedBox(
                          height: 1.h,
                        ),
                        Column(
                          children: [
                            Obx(() {
                              return SwitchListTile(
                                  title: Text("I am looking for a job",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color: kTextBlackColor,
                                            letterSpacing: 1.2,
                                            fontSize: SizerUtil.deviceType ==
                                                    DeviceType.mobile
                                                ? 12.sp
                                                : SizerUtil.deviceType ==
                                                        DeviceType.tablet
                                                    ? 14.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.web
                                                        ? 08.sp
                                                        : 10.sp,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  value: _homeController.lookingForJob.value,
                                  activeColor:
                                      turquoiseBlue, // Change switch color when ON
                                  inactiveThumbColor: Colors
                                      .grey, // Change switch thumb color when OFF
                                  onChanged: (value) => _homeController
                                      .lookingForJob.value = value);
                            }),
                            Obx(() {
                              return SwitchListTile(
                                title: Text("Help me update my CV?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: kTextBlackColor,
                                          letterSpacing: 1.2,
                                          fontSize: SizerUtil.deviceType ==
                                                  DeviceType.mobile
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.tablet
                                                  ? 14.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.web
                                                      ? 08.sp
                                                      : 10.sp,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                value: _homeController.updateCV.value,
                                activeColor: turquoiseBlue,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (value) =>
                                    _homeController.updateCV.value = value,
                              );
                            }),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) {
                                      return MyAlumniInfoViweScreen(
                                        cameFromEditButton: true,
                                      );
                                    }),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                size: SizerUtil.deviceType == DeviceType.tablet
                                    ? 6.w
                                    : 5.w,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Card(
                color: turquoiseBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RepaintBoundary(child: AvinyaBrandHeaderWidget()),
                        Text('Upcoming Events',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 15.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 16.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 14.sp
                                                  : 15.sp,
                                )),
                        FutureBuilder<List<ActivityInstance>>(
                          future: _loadUpcomingEventsData(person_id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: SpinKitCircle(
                                  color: (Colors.blueGrey[400]),
                                  size: 70,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('Something went wrong...'),
                              );
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text('No Upcoming Events Found'),
                              );
                            }
                            final upcomingEventData = snapshot.data!;
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: upcomingEventData.length,
                              itemBuilder: (context, index) {
                                return RepaintBoundary(
                                  child: UpcomingEventCard(
                                      eventData: upcomingEventData[index],
                                      alumniPerson: alumniPerson),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Card(
                color: turquoiseBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RepaintBoundary(child: AvinyaBrandHeaderWidget()),
                      Text('Completed Events',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontWeight: FontWeight.bold,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 15.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 16.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 14.sp
                                            : 15.sp,
                              )),
                      FutureBuilder<List<ActivityInstance>>(
                        future: _loadCompletedEventsData(person_id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              child: SpinKitCircle(
                                color: (Colors.blueGrey[400]),
                                size: 70,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Something went wrong...'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('No Completed Events Found'),
                            );
                          }
                          final completedEventData = snapshot.data!;
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: completedEventData.length,
                            itemBuilder: (context, index) {
                              return RepaintBoundary(
                                child: CompletedEventCard(
                                    eventData: completedEventData[index],
                                    alumniPerson: alumniPerson),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Card(
                color: turquoiseBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    RepaintBoundary(child: AvinyaBrandHeaderWidget()),
                    TimelineWidget(
                      personName: userPerson.preferred_name!,
                      workTimeline: alumniPerson.alumni_work_experience != null
                          ? alumniPerson.alumni_work_experience!
                              .map((workExperience) {
                              return {
                                "title": workExperience.jobTitle ?? '',
                                "id": workExperience.id ?? '',
                                "company": workExperience.companyName ?? '',
                                "duration": workExperience.currentlyWorking ==
                                        true
                                    ? "${workExperience.startDate} - Present"
                                    : "${workExperience.startDate} - ${workExperience.endDate ?? ''}",
                              };
                            }).toList()
                          : [],
                      educationTimeline:
                          alumniPerson.alumni_education_qualifications != null
                              ? alumniPerson.alumni_education_qualifications!
                                  .map((EduQualifications) {
                                  return {
                                    "university":
                                        EduQualifications.universityName ?? '',
                                    "id": EduQualifications.id ?? '',
                                    "course":
                                        EduQualifications.courseName ?? '',
                                    "duration": EduQualifications
                                                .isCurrentlyStudying ==
                                            true
                                        ? "${EduQualifications.startDate} - Present"
                                        : "${EduQualifications.startDate} - ${EduQualifications.endDate ?? ''}",
                                  };
                                }).toList()
                              : [],
                      onItemTap: (item, type) {
                        _showEditModal(context, item, type);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingEventCard extends StatefulWidget {
  final ActivityInstance eventData;
  final AlumniPerson? alumniPerson;

  const UpcomingEventCard(
      {required this.eventData, required this.alumniPerson, super.key});

  @override
  State<UpcomingEventCard> createState() => _UpcomingEventCardState();
}

class _UpcomingEventCardState extends State<UpcomingEventCard> {
  String? selectedRsvp;

  @override
  void initState() {
    super.initState();
    // Set initial value for the dropdown based on is_attending
    selectedRsvp = widget.eventData.activity_participant != null &&
            (widget.eventData.activity_participant!.is_attending == 1 ||
                widget.eventData.activity_participant!.is_attending == 0)
        ? (widget.eventData.activity_participant!.is_attending == 1
            ? 'Yes'
            : 'No')
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final eventGift = widget.eventData.event_gift;

    return SizedBox(
      width: MediaQuery.of(context).size.height * 0.6,
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? kDarkModeSurfaceColor
            : kOtherColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventData.name ?? '',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 12.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 13.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 11.sp
                                  : 12.sp,
                    ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: kTextBlackColor,
                    size: SizerUtil.deviceType == DeviceType.tablet ? 6.w : 5.w,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${widget.eventData.start_time != null ? DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.parse(widget.eventData.start_time!)) : ''}",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: kTextBlackColor,
                    size: SizerUtil.deviceType == DeviceType.tablet ? 6.w : 5.w,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${widget.eventData.location ?? ''}",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 10.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 06.sp
                                        : 08.sp,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Will you attend?",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontStyle: FontStyle.normal,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 10.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 12.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 06.sp
                                      : 08.sp,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? kDarkModeSurfaceColor
                              : kOtherColor,
                      value: selectedRsvp,
                      onChanged: (String? value) async {
                        setState(() {
                          selectedRsvp = value!;
                        });
                        var activityParticipant;
                        try {
                          if (widget.eventData.activity_participant?.id ==
                              null) {
                            activityParticipant = ActivityParticipant(
                              activity_instance_id: widget.eventData.id,
                              person_id: widget.alumniPerson!.id,
                              organization_id:
                                  widget.alumniPerson!.organization_id,
                              is_attending: value == 'Yes' ? 1 : 0,
                            );
                          } else if (widget
                                  .eventData.activity_participant!.id !=
                              null) {
                            activityParticipant = ActivityParticipant(
                              id: widget.eventData.activity_participant!.id,
                              activity_instance_id: widget.eventData.id,
                              person_id: widget.alumniPerson!.id,
                              is_attending: value == 'Yes' ? 1 : 0,
                            );
                          }
                          var result = await createActivityParticipant(
                              activityParticipant);

                          if (result.id != null) {
                            widget.eventData.activity_participant?.id =
                                result.id;
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to add your participant: $e')),
                          );
                        }
                      },
                      items: ['Yes', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontStyle: FontStyle.normal,
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 10.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 06.sp
                                                  : 08.sp,
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              if (eventGift != null && eventGift.description != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    eventGift.description ?? '',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 10.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 12.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 06.sp
                                      : 08.sp,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  eventGift!.notes ?? '',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 10.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 12.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 06.sp
                                    : 08.sp,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedEventCard extends StatefulWidget {
  final ActivityInstance eventData;
  final AlumniPerson? alumniPerson;

  const CompletedEventCard(
      {required this.eventData, required this.alumniPerson, super.key});

  @override
  State<CompletedEventCard> createState() => _CompletedEventCardState();
}

class _CompletedEventCardState extends State<CompletedEventCard> {
  TextEditingController feedbackController = TextEditingController();
  String feedback = '';
  int? selectedRating;
  bool showFeedbackForm = false;
  bool isFeedbackSubmitted = false; // Track if feedback & rating are submitted
  bool isSubmitting = false; //Avoid double submitting

  @override
  void initState() {
    super.initState();
    final activityEvaluation = widget.eventData.activity_evaluation;
    if (activityEvaluation != null) {
      setState(() {
        feedbackController.text = activityEvaluation.feedback ?? '';
        selectedRating =
            activityEvaluation.rating != -1 ? activityEvaluation.rating : null;
        isFeedbackSubmitted = selectedRating != null;
      });
    }
  }

  void _submitFeedback() async {
    print('exe feedback');
    if (selectedRating != null) {
      var activityEvaluation;

      setState(() {
        selectedRating;
        isSubmitting = true;
      });

      if (widget.eventData.activity_participant?.id == null) {
        activityEvaluation = ActivityInstanceEvaluation(
            activity_instance_id: widget.eventData.id,
            evaluator_id: widget.alumniPerson!.id,
            // feedback: feedback,
            rating: selectedRating);
        try {
          print("Activity Evaluation:${activityEvaluation}");
          var result =
              await createActivityInstanceEvaluation(activityEvaluation);

          setState(() {
            showFeedbackForm = false;
            isFeedbackSubmitted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Feedback submitted! Thank you for your support.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to submit feedback.Please try again')),
          );
        } finally {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventGift = widget.eventData.event_gift;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? kDarkModeSurfaceColor
            : kOtherColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 25.w,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Text(
                      widget.eventData.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: kTextBlackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 12.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 13.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 11.sp
                                        : 12.sp,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: kTextBlackColor,
                          size: SizerUtil.deviceType == DeviceType.tablet
                              ? 6.w
                              : 5.w,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "${widget.eventData.start_time != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.eventData.start_time!)) : ''}",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                fontStyle: FontStyle.normal,
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 10.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 06.sp
                                            : 08.sp,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                  child: Wrap(
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      size:
                          SizerUtil.deviceType == DeviceType.tablet ? 6.w : 5.w,
                      Icons.star,
                      color: selectedRating != null && selectedRating! > index
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: (isFeedbackSubmitted || isSubmitting)
                        ? null
                        : () {
                            selectedRating = index + 1;
                            _submitFeedback();
                          },
                  );
                }),
              )),
              // SizedBox(height: 8),
              // Row(
              //   children: [
              //     Icon(
              //       Icons.location_on,
              //       color: kTextBlackColor,
              //       size: SizerUtil.deviceType == DeviceType.tablet ? 6.w : 5.w,
              //     ),
              //     SizedBox(width: 6),
              //     Expanded(
              //       child: Text(
              //         "${widget.eventData.location ?? ''}",
              //         maxLines: 3,
              //         style: Theme.of(context).textTheme.titleSmall!.copyWith(
              //               fontStyle: FontStyle.normal,
              //               color: kTextBlackColor,
              //               fontSize: SizerUtil.deviceType == DeviceType.mobile
              //                   ? 10.sp
              //                   : SizerUtil.deviceType == DeviceType.tablet
              //                       ? 12.sp
              //                       : SizerUtil.deviceType == DeviceType.web
              //                           ? 06.sp
              //                           : 08.sp,
              //             ),
              //         overflow: TextOverflow.ellipsis,
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 8),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "Your feedback",
              //       style: Theme.of(context).textTheme.titleSmall!.copyWith(
              //             fontStyle: FontStyle.normal,
              //             color: kTextBlackColor,
              //             fontSize: SizerUtil.deviceType == DeviceType.mobile
              //                 ? 10.sp
              //                 : SizerUtil.deviceType == DeviceType.tablet
              //                     ? 12.sp
              //                     : SizerUtil.deviceType == DeviceType.web
              //                         ? 06.sp
              //                         : 08.sp,
              //           ),
              //       maxLines: 3,
              //       overflow: TextOverflow.ellipsis,
              //     ),
              //     TextField(
              //       controller: feedbackController,
              //       onChanged: (value) => feedback = value,
              //       decoration: InputDecoration(
              //         //labelText: 'Your Feedback',
              //         // fillColor: Theme.of(context).brightness == Brightness.dark
              //         //     ? Colors.black
              //         //     : Colors.white,
              //         border: OutlineInputBorder(
              //           borderSide: BorderSide(color: Colors.white),
              //         ),
              //       ),
              //       maxLines: 3,
              //       enabled: !isFeedbackSubmitted,
              //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //             fontWeight: FontWeight.normal,
              //             color: kTextBlackColor,
              //             fontSize: SizerUtil.deviceType == DeviceType.mobile
              //                 ? 12.sp
              //                 : SizerUtil.deviceType == DeviceType.tablet
              //                     ? 14.sp
              //                     : SizerUtil.deviceType == DeviceType.web
              //                         ? 12.sp
              //                         : 12.sp,
              //           ),
              //     ),
              //   ],
              // ),
              //SizedBox(height: 8),
              // Row(
              //   children: List.generate(5, (index) {
              //     return IconButton(
              //       icon: Icon(
              //         size:
              //             SizerUtil.deviceType == DeviceType.tablet ? 8.w : 7.w,
              //         Icons.star,
              //         color: selectedRating != null && selectedRating! > index
              //             ? Colors.amber
              //             : Colors.grey,
              //       ),
              //       onPressed: isFeedbackSubmitted
              //           ? null
              //           : () {
              //               setState(() => selectedRating = index + 1);
              //             },
              //     );
              //   }),
              // ),
              // SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: isFeedbackSubmitted ? null : submitFeedback,
              //   child: Text(
              //     'Submit Feedback',
              //     style: TextStyle(
              //       fontSize: 12.sp, // Responsive font size
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //       padding:
              //           EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0), // Curved edges
              //       ),
              //       backgroundColor: kPrimaryButtonColor,
              //       foregroundColor: kPrimaryColor,
              //       elevation: 3),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
