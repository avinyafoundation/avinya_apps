import 'package:gallery/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:sizer/sizer.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late Person userPerson = Person()
    ..full_name = 'John'
    // ..organization = Organization()
    // ..organization!.id = 2
    ..nic_no = '12';
  // String? preferredName;
  // String? fullName;
  // String? notes;

  @override
  void initState() {
    super.initState();
    getUserPerson();
  }

  void getUserPerson() {
    // Retrieve user data from local instance
    Person user = campusAppsPortalInstance.getUserPerson();
    setState(() {
      userPerson = user;
    });
  }

  // String? preferredName = userPerson.preferred_name;

  //  MyProfileScreen({Key? key}) : super(key: key);
  static String routeName = 'MyProfileScreen';

  //log user details
  // print('userPerson: ${userPerson.id}');
  // print('userPerson: ${userPerson.preferred_name}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar theme for tablet
      // appBar: AppBar(
      //   title: Text('My Profile'),
      //   actions: [
      //     InkWell(
      //       onTap: () {
      //         //send report to school management, in case if you want some changes to your profile
      //       },
      //       child: Container(
      //         padding: EdgeInsets.only(right: kDefaultPadding / 2),
      //         child: Row(
      //           children: [
      //             Icon(Icons.report_gmailerrorred_outlined),
      //             kHalfWidthSizedBox,
      //             Text(
      //               'Report',
      //               style: Theme.of(context).textTheme.subtitle2,
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Container(
          color: kOtherColor,
          child: Column(
            children: [
              Container(
                width: 100.w,
                height: SizerUtil.deviceType == DeviceType.tablet ? 19.h : 15.h,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: kBottomBorderRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: SizerUtil.deviceType == DeviceType.tablet
                          ? 12.w
                          : 13.w,
                      backgroundColor: kSecondaryColor,
                      backgroundImage:
                          AssetImage('assets/images/student_profile.jpeg'),
                    ),
                    kWidthSizedBox,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userPerson.full_name!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize:
                                    SizerUtil.deviceType == DeviceType.tablet
                                        ? 4.sp
                                        : 5.sp,
                              ),
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          userPerson.organization!.name!.name_en!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize:
                                    SizerUtil.deviceType == DeviceType.tablet
                                        ? 4.sp
                                        : 5.sp,
                              ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              sizedBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                      title: 'Registration Number', value: '${userPerson.id}'),
                  ProfileDetailRow(title: 'Academic Year', value: '2020-2021'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                      title: 'Programme',
                      value: '${userPerson.avinya_type!.focus!}'),
                  ProfileDetailRow(title: 'Gender', value: '${userPerson.sex}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                      title: 'Date of Admission',
                      value: DateFormat('d MMM, yyyy')
                          .format(DateTime.parse(userPerson.date_of_birth!))),
                  ProfileDetailRow(
                      title: 'Date of Birth',
                      value: DateFormat('d MMM, yyyy')
                          .format(DateTime.parse(userPerson.date_of_birth!))),
                ],
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Email',
                value: '${userPerson.digital_id}',
              ),
              ProfileDetailColumn(
                title: 'Father Name',
                value: 'John Mirza',
              ),
              ProfileDetailColumn(
                title: 'Mother Name',
                value: 'Angelica Mirza',
              ),
              ProfileDetailColumn(
                title: 'Phone Number',
                value: '${userPerson.phone}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 5.sp
                          : 6.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(
                value,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              kHalfSizedBox,
              SizedBox(
                width: 35.w,
                child: Divider(
                  thickness: 1.0,
                ),
              ),
            ],
          ),
          Icon(
            Icons.lock_outline,
            size: 6.sp,
          ),
        ],
      ),
    );
  }
}

class ProfileDetailColumn extends StatelessWidget {
  const ProfileDetailColumn(
      {Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 5.sp
                          : 6.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(
                value,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              kHalfSizedBox,
              SizedBox(
                width: 92.w,
                child: Divider(
                  thickness: 1.0,
                ),
              )
            ],
          ),
          Icon(
            Icons.lock_outline,
            size: 6.sp,
          ),
        ],
      ),
    );
  }
}
