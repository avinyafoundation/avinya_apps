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
  final _formKey = GlobalKey<FormState>();

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
    if (AlumniUserPerson.mailing_address != null &&
        AlumniUserPerson.mailing_address!.city!.district != null)
      _loadCities(AlumniUserPerson.mailing_address!.city!.district!.id);
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
                  ProfileDetailRow(
                      title: 'Class',
                      value:
                          '${UserPerson.organization!.description ?? 'N/A'}'),
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
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone Number is required'; // Error message if field is empty
                  }
                  return null; // No error
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
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required'; // Error message if field is empty
                  }
                  return null; // No error
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
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required'; // Error message if field is empty
                  }
                  return null; // No error
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
                      int? districtId = null;
                      if (AlumniUserPerson.mailing_address!.city!.district !=
                          null) {
                        districtId = AlumniUserPerson
                            .mailing_address!.city!.district!.id;
                      }

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
              Text('Social Media Profiles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
                maxLines: 1,
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Facebook Profile Link',
                value: '${AlumniUserPerson.alumni?.facebook_id ?? 'N/A'}',
                // controller: TextEditingController(
                //     text: AlumniUserPerson.phone?.toString()),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.alumni?.facebook_id = newValue;
                  });
                },
                maxLines: 1,
              ),
              sizedBox,
              ProfileDetailColumn(
                title: 'Instagram Profile Link',
                value: '${AlumniUserPerson.alumni?.instagram_id ?? 'N/A'}',
                // controller: TextEditingController(
                //     text: AlumniUserPerson.phone?.toString()),
                onChanged: (newValue) {
                  setState(() {
                    AlumniUserPerson.alumni?.instagram_id = newValue;
                  });
                },
                maxLines: 1,
              ),
              // _buildSocialMediaSection(),
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
                  if (_formKey.currentState?.validate() ?? false) {
                    // Proceed with submission if the form is valid
                    _submitAlumniData(
                        AlumniUserPerson, UserPerson.id, selectedDistrictId);
                  } else {
                    // Show an error message or highlight fields
                    print("Please fill in all required fields");
                  }
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
                          "id": workExperience.id ?? '',
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
                          "id": EduQualifications.id ?? '',
                          "course": EduQualifications.courseName ?? '',
                          "duration": EduQualifications.isCurrentlyStudying ==
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
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
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
                  AlumniUserPerson.mailing_address!.city!.district = District(
                    id: value, // Use named parameter for city_id
                  );
                  AlumniUserPerson.mailing_address?.city!.district!.id = value;
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
    if (cityList.isNotEmpty &&
        AlumniUserPerson.mailing_address!.city!.id != null) {
      bool cityExists = cityList
          .any((city) => city.id == AlumniUserPerson.mailing_address!.city!.id);
      if (!cityExists) {
        selectedCityId = null;
      } else {
        selectedCityId = AlumniUserPerson.mailing_address!.city!.id;
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
                    AlumniUserPerson.mailing_address!.city = City(
                      id: value, // Use named parameter for city_id
                    );
                  } else {
                    AlumniUserPerson.mailing_address!.city = City(
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

  void _submitAlumniData(
      AlumniPerson AlumniUserPerson, int? id, selectedDistrictId) async {
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
          district:
              District(id: selectedDistrictId, name: Name(name_en: "Kalutara")),
          latitude: AlumniUserPerson.mailing_address?.city?.latitude ?? 0.0,
          longitude: AlumniUserPerson.mailing_address?.city?.longitude ?? 0.0,
        ),
      ),
      alumni: Alumni(
        id: AlumniUserPerson.alumni?.id,
        status: AlumniUserPerson.alumni?.status,
        company_name: AlumniUserPerson.alumni?.company_name,
        job_title: AlumniUserPerson.alumni?.job_title,
        linkedin_id: AlumniUserPerson.alumni?.linkedin_id,
        facebook_id: AlumniUserPerson.alumni?.facebook_id,
        instagram_id: AlumniUserPerson.alumni?.instagram_id,
        updated_by: AlumniUserPerson.digital_id,
      ),
      is_graduated: null,
    );

    try {
      if (AlumniUserPerson.alumni?.id != null) {
        await updateAlumniPerson(person2, id, selectedDistrictId);
      } else {
        await createAlumniPerson(person2, selectedDistrictId);
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

class ProfileDetailColumn extends StatefulWidget {
  final String title;
  final String? value;
  final Function(String) onChanged;
  final int? maxLines;
  final String? Function(String?)? validator;

  ProfileDetailColumn({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.maxLines,
    this.validator,
  });

  @override
  _ProfileDetailColumnState createState() => _ProfileDetailColumnState();
}

class _ProfileDetailColumnState extends State<ProfileDetailColumn> {
  late TextEditingController controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(ProfileDetailColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      controller.text = widget.value ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onChanged,
              maxLines: widget.maxLines,
              validator: widget.validator,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
}

class EditModal extends StatefulWidget {
  final Map<String, String> item;
  final String type;
  final Function(Map<String, String>, String) onDelete;
  final Function(Map<String, String>, String, String, String, String, String,
      String, String, bool) onUpdate;

  EditModal({
    required this.item,
    required this.type,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  _EditModalState createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  late TextEditingController companyController;
  late TextEditingController idController;
  late TextEditingController jobTitleController;
  late TextEditingController universityController;
  late TextEditingController courseController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late bool isCurrent;

  @override
  void initState() {
    super.initState();

    companyController = TextEditingController(text: widget.item['company']);
    idController = TextEditingController(text: widget.item['id']);
    jobTitleController = TextEditingController(text: widget.item['title']);
    universityController =
        TextEditingController(text: widget.item['university']);
    courseController = TextEditingController(text: widget.item['course']);

    // Extract start and end dates
    String? duration = widget.item['duration'];
    List<String> dates = duration?.split(' - ') ?? [];

    String startDate = dates.isNotEmpty ? dates[0] : '';
    String endDate =
        (dates.length > 1 && dates[1] != "Present") ? dates[1] : '';

    startDateController = TextEditingController(text: startDate);
    endDateController = TextEditingController(text: endDate);

    isCurrent = duration?.contains('Present') ?? false;
  }

// Function to show date picker and update text field
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.type == 'work'
                  ? 'Edit Work Experience'
                  : 'Edit Study Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (widget.type == 'work') ...[
              TextFormField(
                controller: companyController,
                decoration: InputDecoration(labelText: "Company Name"),
              ),
              TextFormField(
                controller: jobTitleController,
                decoration: InputDecoration(labelText: "Job Title"),
              ),
            ] else ...[
              TextFormField(
                controller: universityController,
                decoration: InputDecoration(labelText: "University/School"),
              ),
              TextFormField(
                controller: courseController,
                decoration: InputDecoration(labelText: "Degree/Course"),
              ),
            ],
            SwitchListTile(
              title: Text(widget.type == 'work'
                  ? "Currently Working Here?"
                  : "Currently Studying Here?"),
              value: isCurrent,
              onChanged: (bool value) {
                setState(() {
                  isCurrent = value;
                  if (isCurrent) {
                    endDateController.text = "Present";
                  } else {
                    endDateController.clear();
                  }
                });
              },
            ),
            GestureDetector(
              onTap: () => _selectDate(context, startDateController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: "Start Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            if (!isCurrent)
              GestureDetector(
                onTap: () => _selectDate(context, endDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: "End Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onDelete(widget.item, widget.type);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Delete"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onUpdate(
                      widget.item,
                      widget.type,
                      companyController.text,
                      jobTitleController.text,
                      universityController.text,
                      courseController.text,
                      startDateController.text,
                      endDateController.text,
                      isCurrent,
                    );
                    Navigator.pop(context);
                  },
                  child: Text("Update"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
