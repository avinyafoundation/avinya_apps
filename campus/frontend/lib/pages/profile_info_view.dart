import 'package:gallery/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late Person userPerson = Person()
    ..full_name = 'John'
    ..nic_no = '12';

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

  int calculateAge(String dateOfBirth) {
    DateTime today = DateTime.now();
    DateTime dob = DateTime.parse(dateOfBirth);
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: kOtherColor,
          child: Column(
            children: [
              sizedBox,
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
                          '${userPerson.full_name == null ? 'N/A' : userPerson.full_name!}',
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
                        Text(
                          '${userPerson.organization == null ? 'N/A' : userPerson.organization!.name == null ? 'N/A' : userPerson.organization!.name!.name_en == null ? 'N/A' : userPerson.organization!.name!.name_en!}',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize:
                                    SizerUtil.deviceType == DeviceType.tablet
                                        ? 3.sp
                                        : 4.sp,
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
                      title: 'Registration Number',
                      value:
                          '${userPerson.id == null ? 'N/A' : userPerson.id}'),
                  ProfileDetailRow(
                      title: 'Academic Year',
                      value:
                          '${userPerson.updated == null ? 'N/A' : '${DateFormat('yyyy').format(DateTime.parse(userPerson.updated!))} - ${DateFormat('yyyy').format(DateTime.parse(userPerson.updated!).add(Duration(days: 365)))} '}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                    title: 'Programme',
                    value:
                        '${userPerson.avinya_type == null ? 'N/A' : userPerson.avinya_type!.focus == null ? 'N/A' : userPerson.avinya_type!.focus}',
                  ),
                  ProfileDetailRow(title: 'Class', value: 'TBD'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                      title: 'Date of Admission',
                      value:
                          '${userPerson.created == null ? 'N/A' : DateFormat('d MMM, yyyy').format(DateTime.parse(userPerson.created!))}'),
                  // ProfileDetailRow(
                  //     title: 'Age',
                  //     value:
                  //         '${calculateAge(userPerson.date_of_birth!)} years old'),
                ],
              ),
              sizedBox,
              sizedBox,
              sizedBox,
              Text(
                'Student Information',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Full Name',
                value:
                    '${userPerson.full_name == null ? 'N/A' : userPerson.full_name}',
              ),
              ProfileDetailColumn(
                title: 'Preferred Name',
                value:
                    '${userPerson.preferred_name == null ? 'N/A' : userPerson.preferred_name}',
              ),
              ProfileDetailColumn(
                title: 'Date of Birth',
                value:
                    '${userPerson.date_of_birth == null ? 'N/A' : DateFormat('d MMM, yyyy').format(DateTime.parse(userPerson.date_of_birth!))}',
              ),
              ProfileDetailColumn(
                title: 'Gender',
                value: '${userPerson.sex == null ? 'N/A' : userPerson.sex}',
              ),
              ProfileDetailColumn(
                title: 'NIC Number',
                value:
                    '${userPerson.nic_no == null ? 'N/A' : userPerson.nic_no}',
              ),
              ProfileDetailColumn(
                title: 'Passport Number',
                value:
                    '${userPerson.passport_no == null ? 'N/A' : userPerson.passport_no}',
              ),
              sizedBox,
              sizedBox,
              sizedBox,
              Text(
                'Student Contact Information',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Personal Phone Number',
                value: '${userPerson.phone == null ? 'N/A' : userPerson.phone}',
              ),
              ProfileDetailColumn(
                title: 'Avinya Phone Number',
                value:
                    '${userPerson.avinya_phone == null ? 'N/A' : userPerson.avinya_phone}',
              ),
              ProfileDetailColumn(
                title: 'Email',
                value: '${userPerson.email == null ? 'N/A' : userPerson.email}',
              ),
              ProfileDetailColumn(
                title: 'Home Address',
                value:
                    '${userPerson.permanent_address == null ? 'N/A' : userPerson.permanent_address!.street_address == null ? 'N/A' : userPerson.permanent_address!.street_address}',
              ),
              ProfileDetailColumn(
                title: 'Mailing Address',
                value:
                    '${userPerson.mailing_address == null ? 'N/A' : userPerson.mailing_address!.street_address == null ? 'N/A' : userPerson.mailing_address!.street_address}',
              ),
              sizedBox,
              sizedBox,
              sizedBox,
              Text(
                'Student Bank Information',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Bank Name',
                value:
                    '${userPerson.bank_name == null ? 'N/A' : userPerson.bank_name}',
              ),
              ProfileDetailColumn(
                title: 'Bank Account Name',
                value:
                    '${userPerson.bank_account_name == null ? 'N/A' : userPerson.bank_account_name}',
              ),
              ProfileDetailColumn(
                title: 'Bank Account Number',
                value:
                    '${userPerson.bank_account_number == null ? 'N/A' : userPerson.bank_account_number}',
              ),
              sizedBox,
              sizedBox,
              sizedBox,
              Text(
                'Parent/Guardian Information',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Father Name',
                value:
                    '${userPerson.parent_students[0] == null ? 'N/A' : userPerson.parent_students[0].preferred_name == null ? 'N/A' : userPerson.parent_students[0].preferred_name}',
              ),
              ProfileDetailColumn(
                title: 'Mother Name',
                value:
                    '${userPerson.parent_students[1] == null ? 'N/A' : userPerson.parent_students[1].preferred_name == null ? 'N/A' : userPerson.parent_students[1].preferred_name}',
              ),
              ProfileDetailColumn(
                title: 'Father Phone Number',
                value:
                    '${userPerson.parent_students[0] == null ? 'N/A' : userPerson.parent_students[0].phone == null ? 'N/A' : userPerson.parent_students[0].phone}',
              ),
              ProfileDetailColumn(
                title: 'Mother Phone Number',
                value:
                    '${userPerson.parent_students[1] == null ? 'N/A' : userPerson.parent_students[1].phone == null ? 'N/A' : userPerson.parent_students[1].phone}',
              ),
              sizedBox,
              sizedBox,
              sizedBox,
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
                          ? 4.sp
                          : 5.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(
                value,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 3.sp
                          : 4.sp,
                    ),
              ),
              kHalfSizedBox,
              SizedBox(
                width: 35.w,
                child: Divider(
                  thickness: 1.0,
                  color: kTextBlackColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.lock_outline,
            size: 6.sp,
            color: kTextBlackColor,
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
                          ? 8.sp
                          : 5.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(
                value,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 7.sp
                          : 4.sp,
                    ),
              ),
              kHalfSizedBox,
              SizedBox(
                width: 92.w,
                child: Divider(
                  thickness: 1.0,
                  color: kTextBlackColor,
                ),
              )
            ],
          ),
          Icon(
            Icons.lock_outline,
            size: 6.sp,
            color: kTextBlackColor,
          ),
        ],
      ),
    );
  }
}
