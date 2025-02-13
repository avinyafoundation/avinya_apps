import 'package:mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyAlumniScreen extends StatefulWidget {
  const MyAlumniScreen({Key? key}) : super(key: key);

  @override
  _MyAlumniScreenState createState() => _MyAlumniScreenState();
}

class _MyAlumniScreenState extends State<MyAlumniScreen> {
  late Person userPerson = Person()
    ..full_name = 'John'
    ..nic_no = '12';

  String? selectedStatus;
  final List<String> statusOptions = [
    'Working',
    'Not Working',
    'Working and Studying',
    'Studying'
  ];

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
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 12.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 15.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 7.sp
                                            : 12.sp,
                              ),
                        ),
                        Text(
                          '${userPerson.organization == null ? 'N/A' : userPerson.organization!.name == null ? 'N/A' : userPerson.organization!.name!.name_en == null ? 'N/A' : userPerson.organization!.name!.name_en!}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 13.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 14.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 6.sp
                                            : 11.sp,
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
              sizedBox,
              sizedBox,
              sizedBox,
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 15.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 6.sp
                                  : 11.sp,
                    ),
              ),
              sizedBox,
              sizedBox,
              ProfileDetailColumn(
                title: 'Phone Number',
                value: '${userPerson.phone == null ? 'N/A' : userPerson.phone}',
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Email',
                value: '${userPerson.email == null ? 'N/A' : userPerson.email}',
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Address',
                value:
                    '${userPerson.mailing_address == null ? 'N/A' : userPerson.mailing_address!.street_address == null ? 'N/A' : userPerson.mailing_address!.street_address}',
              ),
              sizedBox,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Employment Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                ),
              ),
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
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 15.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 6.sp
                                  : 11.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 15.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 6.sp
                                  : 11.sp,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust as needed
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 14.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 6.sp
                                    : 11.sp,
                      ),
                ),
                kHalfSizedBox,
                SizedBox(
                  width: double.infinity, // Allow full width
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 15.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 14.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 6.sp
                                      : 11.sp,
                        ),
                    softWrap: true,
                  ),
                ),
                kHalfSizedBox,
                Divider(
                  thickness: 1.0,
                  color: kTextBlackColor,
                ),
              ],
            ),
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
