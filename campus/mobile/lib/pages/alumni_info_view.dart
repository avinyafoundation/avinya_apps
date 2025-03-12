import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';
import 'package:mobile/widgets/time_line_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyAlumniScreen extends StatefulWidget {
  const MyAlumniScreen({Key? key}) : super(key: key);

  @override
  _MyAlumniScreenState createState() => _MyAlumniScreenState();
}

class _MyAlumniScreenState extends State<MyAlumniScreen> {
  late AlumniPerson AlumniUserPerson = AlumniPerson(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  late List<EducationQualifications> alumni_education_qualifications;
  late List<WorkExperience> alumni_work_experience;

  late Person UserPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  final List<String> statusOptions = [
    'Working',
    'Not Working',
    'Working and Studying',
    'Studying'
  ];

  bool isDistrictsDataLoaded = false;
  List<District> districts = [];
  List<City> cityList = [];
  int? selectedCityId;
  int? selectedDistrictId;

  @override
  void initState() {
    super.initState();
    getUserPerson();
  }

  void getUserPerson() {
    // Retrieve user data from local instance
    AlumniPerson AlumniUser = campusAppsPortalInstance.getAlumniUserPerson();
    Person user = campusAppsPortalInstance.getUserPerson();
    setState(() {
      AlumniUserPerson = AlumniUser;
      UserPerson = user;
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

  Future<List<District>> fetchDistrictList() async {
    return await fetchDistricts();
  }

  int? getDistrictIdByCityId(int? selectedCityId, List<District> districtList) {
    for (var district in districtList) {
      if (district.cities != null) {
        // Check if cities is not null
        for (var city in district.cities!) {
          // Use the non-null assertion operator
          if (city.id == selectedCityId) {
            return district.id; // Return the district ID if the city ID matches
          }
        }
      }
    }
    return null; // Return null if no matching district is found
  }

  TextEditingController myController = TextEditingController();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController workStartDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? workStatus;

  final TextEditingController universityController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController studyStartDateController =
      TextEditingController();
  final TextEditingController studyEndDateController = TextEditingController();
  String? studyStatus;

  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();
  bool isCurrentWork = false;
  bool isCurrentStudy = false;

  @override
  Widget build(BuildContexcosdantext) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 25.0),
          decoration: BoxDecoration(
            color: kOtherColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
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
                          '${AlumniUserPerson.full_name ?? 'N/A'}',
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
                          '${AlumniUserPerson.organization?.name?.name_en ?? 'N/A'}',
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
                          '${UserPerson.updated == null ? 'N/A' : '${DateFormat('yyyy').format(DateTime.parse(UserPerson.updated!))} - ${DateFormat('yyyy').format(DateTime.parse(UserPerson.updated!).add(Duration(days: 365)))} '}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileDetailRow(
                    title: 'Programme',
                    value: '${UserPerson.avinya_type?.focus ?? 'N/A'}',
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
                value: '${AlumniUserPerson.phone ?? 'N/A'}',
                // controller: TextEditingController(
                //     text: AlumniUserPerson.phone?.toString()),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.phone = int.tryParse(newValue);
                  });
                },
              ),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: _buildTextField(phoneNumberController, 'Phone Number'),
              // ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Email',
                value: '${AlumniUserPerson.email ?? 'N/A'}',
                // controller: TextEditingController(text: AlumniUserPerson.email),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.email = newValue;
                  });
                },
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Address',
                value:
                    '${AlumniUserPerson.mailing_address?.street_address ?? 'N/A'}',
                // controller: TextEditingController(
                //     text: AlumniUserPerson.mailing_address?.street_address),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.mailing_address?.street_address = newValue;
                  });
                },
              ),
              FutureBuilder<List<District>>(
                  future: fetchDistrictList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SpinKitCircle(
                          color: (Color.fromARGB(255, 74, 161, 70)),
                          size: 70,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong...'),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No districts found'),
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!isDistrictsDataLoaded) {
                          setState(() {
                            isDistrictsDataLoaded = true;
                            print(
                                "isDistrictsDataLoaded:${isDistrictsDataLoaded}");
                          });
                        }
                      });
                      districts = snapshot.data!;
                      int? districtId =
                          getDistrictIdByCityId(selectedCityId, districts);
                      selectedDistrictId = districtId ?? selectedDistrictId;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDistrictField(),
                            _buildCityField(),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  }),
              sizedBox,
              ProfileDetailColumn(
                title: 'LinkedIn Profile Link',
                value: '${AlumniUserPerson.alumni?.linkedin_id ?? 'N/A'}',
                // controller: TextEditingController(
                //     text: AlumniUserPerson.phone?.toString()),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.alumni?.linkedin_id = newValue;
                  });
                },
              ),
              _buildSocialMediaSection(),
              sizedBox,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: AlumniUserPerson.alumni?.status,
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
                      AlumniUserPerson.alumni?.status = newValue;
                    });
                  },
                ),
              ),
              sizedBox,
              ElevatedButton(
                onPressed: () {
                  _submitAlumniData(AlumniUserPerson, UserPerson.id);
                },
                child: Text("Save Changes"),
              ),
              SizedBox(height: 20),
              _buildWorkSection(UserPerson.id),
              SizedBox(height: 20),
              _buildStudySection(UserPerson.id),
              SizedBox(height: 10),

              SizedBox(height: 10),
              TimelineWidget(
                workTimeline: AlumniUserPerson.alumni_work_experience != null
                    ? AlumniUserPerson.alumni_work_experience!
                        .map((workExperience) {
                        return {
                          "title": workExperience.jobTitle ?? '',
                          "company": workExperience.companyName ?? '',
                          "duration": workExperience.currentlyWorking == true
                              ? "${workExperience.startDate} - Present"
                              : "${workExperience.startDate} - ${workExperience.endDate ?? ''}",
                        };
                      }).toList()
                    : [],
                educationTimeline: AlumniUserPerson
                            .alumni_education_qualifications !=
                        null
                    ? AlumniUserPerson.alumni_education_qualifications!
                        .map((EduQualifications) {
                        return {
                          "university": EduQualifications.universityName ?? '',
                          "course": EduQualifications.courseName ?? '',
                          "duration": EduQualifications.isCurrentlyStudying ==
                                  true
                              ? "${EduQualifications.startDate} - Present"
                              : "${EduQualifications.startDate} - ${EduQualifications.endDate ?? ''}",
                        };
                      }).toList()
                    : [],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _getDistrictOptions() {
    return districts.map((district) {
      return DropdownMenuItem<int>(
        value: district.id as int,
        child: Text(district.name?.name_en ?? 'Unknown'),
      );
    }).toList();
  }

  Future<void> _loadCities(int? districtId) async {
    final fetchedCities = await fetchCities(districtId);
    setState(() {
      cityList = fetchedCities;
      selectedCityId = null; // Reset selected city
    });
  }

  Widget _buildDistrictField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: selectedDistrictId,
              items: _getDistrictOptions(),
              onChanged: (value) async {
                await _loadCities(value);
                setState(() {
                  selectedDistrictId = value;
                  AlumniUserPerson.mailing_address?.district_id = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select District',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    // Ensure selectedCityId is valid or set to null if not found in the current city's list
    if (cityList.isNotEmpty && selectedCityId != null) {
      bool cityExists = cityList.any((city) => city.id == selectedCityId);
      if (!cityExists) {
        selectedCityId = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: selectedCityId,
              items: cityList
                  .map((city) => DropdownMenuItem<int>(
                        value: city.id,
                        child: Text(city.name?.name_en ?? 'Unknown City'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCityId = value;

                  if (AlumniUserPerson.mailing_address == null) {
                    // Create a new Address object with city_id set to value
                    AlumniUserPerson.mailing_address = Address(
                        city_id: value, // Use named parameter for city_id
                        id: null);
                    UserPerson.mailing_address!.city = City(
                      id: value, // Use named parameter for city_id
                    );
                  } else {
                    UserPerson.mailing_address!.city = City(
                      id: value, // Use named parameter for city_id
                    );
                  }

                  // Debugging: print selected city
                  print("Selected City ID: $selectedCityId");
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Social Media Profiles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildTextField(linkedInController, 'LinkedIn Profile Link'),
          _buildTextField(facebookController, 'Facebook Profile Link'),
          _buildTextField(instagramController, 'Instagram Profile Link'),
        ],
      ),
    );
  }

  Widget _buildWorkSection(id) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Add Work Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: companyController,
              decoration: InputDecoration(labelText: "Company Name"),
            ),
            TextFormField(
              controller: jobTitleController,
              decoration: InputDecoration(labelText: "Job Title"),
            ),
            SwitchListTile(
              title: Text("Currently Working Here?"),
              value: isCurrentWork,
              onChanged: (bool value) {
                setState(() {
                  isCurrentWork = value;
                });
              },
            ),
            TextFormField(
              controller: workStartDateController,
              decoration: InputDecoration(labelText: "Start Date"),
            ),
            if (!isCurrentWork)
              TextFormField(
                controller: endDateController,
                decoration: InputDecoration(labelText: "End Date"),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _submitWorkExperience(id);
              },
              child: Text("Add Work Experience"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudySection(id) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Add Study Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: universityController,
              decoration: InputDecoration(labelText: "University/School"),
            ),
            TextFormField(
              controller: degreeController,
              decoration: InputDecoration(labelText: "Degree/Course"),
            ),
            SwitchListTile(
              title: Text("Currently Studying Here?"),
              value: isCurrentStudy,
              onChanged: (bool value) {
                setState(() {
                  isCurrentStudy = value;
                });
              },
            ),
            TextFormField(
              controller: studyStartDateController,
              decoration: InputDecoration(labelText: "Start Date"),
            ),
            if (!isCurrentStudy)
              TextFormField(
                controller: studyEndDateController,
                decoration: InputDecoration(labelText: "End Date"),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _submitStudyExperience(id);
              },
              child: Text("Add Study Experience"),
            ),
          ],
        ),
      ),
    );
  }

  void _submitWorkExperience(id) async {
    WorkExperience workExperience = WorkExperience(
      person_id: id,
      companyName: companyController.text,
      jobTitle: jobTitleController.text,
      startDate: workStartDateController.text,
      endDate: isCurrentWork ? null : endDateController.text,
      currentlyWorking: isCurrentWork,
    );

    try {
      WorkExperience createdWork =
          await createAlumniWorkQualification(workExperience);
      setState(() {
        alumni_work_experience?.add(createdWork);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work experience added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add work experience: $e')),
      );
    }
  }

  // void _submitAlumniData(AlumniUserPerson, id) async {
  //   AlumniPerson person = AlumniPerson(
  //       id: id,
  //       phone: AlumniUserPerson.phone,
  //       is_graduated: true
  //       // street_address: jobTitleController.text,
  //       // startDate: workStartDateController.text,
  //       // endDate: isCurrentWork ? null : endDateController.text,
  //       // currentlyWorking: isCurrentWork,
  //       );

  //   try {
  //     // AlumniPerson createdWork =
  //     await createAlumniPerson(person);
  //     // setState(() {
  //     //   AlumniUserPerson.alumni_work_experience?.add(createdWork);
  //     // });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Work experience added successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to add work experience: $e')),
  //     );
  //   }
  // }

  void _submitAlumniData(AlumniPerson AlumniUserPerson, int? id) async {
    AlumniPerson person2 = AlumniPerson(
      id: id,
      full_name: AlumniUserPerson.full_name,
      email: AlumniUserPerson.email,
      phone: AlumniUserPerson.phone,
      mailing_address: Address(
        id: AlumniUserPerson.mailing_address?.id,
        name_en: AlumniUserPerson.mailing_address?.name_en,
        street_address: AlumniUserPerson.mailing_address?.street_address,
        phone: AlumniUserPerson.mailing_address?.phone,
        city: City(
          id: AlumniUserPerson.mailing_address?.city?.id,
          name: Name(
            name_en: AlumniUserPerson.mailing_address?.city?.name?.name_en,
          ),
          latitude: AlumniUserPerson.mailing_address?.city?.latitude ?? 0.0,
          longitude: AlumniUserPerson.mailing_address?.city?.longitude ?? 0.0,
        ),
      ),
      alumni: Alumni(
        status: AlumniUserPerson.alumni?.status,
        company_name: AlumniUserPerson.alumni?.company_name,
        job_title: AlumniUserPerson.alumni?.job_title,
        linkedin_id: AlumniUserPerson.alumni?.linkedin_id,
        facebook_id: AlumniUserPerson.alumni?.facebook_id,
        instagram_id: AlumniUserPerson.alumni?.instagram_id,
        updated_by: AlumniUserPerson.alumni?.updated_by,
      ),
      is_graduated: null,
    );

    try {
      if (AlumniUserPerson.alumni?.id != null) {
        await updateAlumniPerson(person2);
      } else {
        await createAlumniPerson(person2);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alumni data processed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process alumni data: $e')),
      );
    }
  }

  void _submitStudyExperience(id) async {
    EducationQualifications studyExperience = EducationQualifications(
      person_id: id,
      universityName: universityController.text,
      courseName: degreeController.text,
      startDate: studyStartDateController.text,
      endDate: isCurrentStudy ? null : studyEndDateController.text,
      isCurrentlyStudying: isCurrentStudy,
    );

    try {
      EducationQualifications createdStudy =
          await createAlumniEduQualification(studyExperience);
      setState(() {
        AlumniUserPerson.alumni_education_qualifications?.add(createdStudy);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Study experience added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add study experience: $e')),
      );
    }
  }
}

Widget _buildDropdown(List<String> options, Function(String?) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
      hint: Text('Select an option'),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
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
  final String title;
  final String? value;
  final TextEditingController controller;
  final Function(String) onChanged;

  ProfileDetailColumn({
    required this.title,
    required this.value,
    required this.onChanged,
  }) : controller = TextEditingController(text: value ?? '');

  // ProfileDetailColumn({
  //   required this.title,
  //   required this.value,
  //   required this.controller,
  //   required this.onChanged,
  // }) : controller = TextEditingController(text: value ?? '');

  @override
  Widget build(BuildContext context) {
    controller.text = value ?? ''; // Prepopulate the value

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
