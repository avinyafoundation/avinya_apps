import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/avinya/alumni/lib/widgets/time_line_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyAlumniScreen extends StatefulWidget {
  final int? id;
  const MyAlumniScreen({Key? key,this.id}) : super(key: key);

  @override
  _MyAlumniScreenState createState() => _MyAlumniScreenState();
}

class _MyAlumniScreenState extends State<MyAlumniScreen> {
  late AlumniPerson AlumniUserPerson = AlumniPerson(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  // late List<EducationQualifications> alumni_education_qualifications;
  // late List<WorkExperience> alumni_work_experience;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Person UserPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  final List<String> statusOptions = [
    'Working',
    'Studying',
    'WorkAndStudy',
    'NotWorking',
    'Abroad'
  ];

  bool isDistrictsDataLoaded = false;
  List<District> districts = [];
  List<City> cityList = [];
  int? selectedCityId;
  int? selectedDistrictId;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserPerson();
    _emailController.text = AlumniUserPerson.email ?? 'N/A';
    if (AlumniUserPerson.mailing_address != null &&
        AlumniUserPerson.mailing_address!.city!.district != null)
      _loadCities(AlumniUserPerson.mailing_address!.city!.district!.id);
  }

  void getUserPerson() async{
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
    String imagePath = AlumniUserPerson.sex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpeg'; // Default or female profile image
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 25.0),
          decoration: BoxDecoration(
            color: kOtherColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                sizedBox,
                Container(
                  width: 100.w,
                  height:
                      SizerUtil.deviceType == DeviceType.tablet ? 19.h : 15.h,
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
                        backgroundImage: AssetImage(imagePath),
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
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 12.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 15.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
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
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 13.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 14.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField(
                      'Phone', AlumniUserPerson.phone?.toString() ?? '',
                      (value) {
                    AlumniUserPerson.phone = int.tryParse(value);
                  }, validator: _validatePhone),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField(
                      'Personal Email', AlumniUserPerson.email, (value) {
                    AlumniUserPerson.email = value;
                  }, validator: _validateEmail),
                ),
                ProfileDetailColumn(
                  title: 'Address',
                  value:
                      '${AlumniUserPerson.mailing_address?.street_address ?? 'N/A'}',
                  onChanged: (newValue) {
                    setState(() {
                      AlumniUserPerson.mailing_address?.street_address =
                          newValue;
                    });
                  },
                  maxLines: 3,
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
                SizedBox(height: 10),
                Text('Social Media Profiles',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField('LinkedIn Profile Link',
                      AlumniUserPerson.alumni?.linkedin_id ?? '', (value) {
                    AlumniUserPerson.alumni?.linkedin_id = value;
                  }),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField('Facebook Profile Link',
                      AlumniUserPerson.alumni?.facebook_id ?? '', (value) {
                    AlumniUserPerson.alumni?.facebook_id = value;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField('Instagram Profile Link',
                      AlumniUserPerson.alumni?.instagram_id ?? '', (value) {
                    AlumniUserPerson.alumni?.instagram_id = value;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildEditableField('TikTok Profile Link',
                      AlumniUserPerson.alumni?.tiktok_id ?? '', (value) {
                    AlumniUserPerson.alumni?.tiktok_id = value;
                  }),
                ),
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _submitAlumniData(
                          AlumniUserPerson, UserPerson.id, selectedDistrictId);
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
                  educationTimeline:
                      AlumniUserPerson.alumni_education_qualifications != null
                          ? AlumniUserPerson.alumni_education_qualifications!
                              .map((EduQualifications) {
                              return {
                                "university":
                                    EduQualifications.universityName ?? '',
                                "id": EduQualifications.id ?? '',
                                "course": EduQualifications.courseName ?? '',
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
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value) || value.length < 10) {
      return 'Enter a valid phone number (at least 10 digits)';
    }
    return null;
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

  Widget _buildEditableField(
      String label, String? initialValue, Function(String) onSave,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: initialValue ?? '',
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => onSave(value!),
            validator: validator,
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
            // TextFormField(
            //   controller: workStartDateController,
            //   decoration: InputDecoration(labelText: "Start Date"),
            // ),
            // if (!isCurrentWork)
            //   TextFormField(
            //     controller: endDateController,
            //     decoration: InputDecoration(labelText: "End Date"),
            //   ),
            GestureDetector(
              onTap: () => _selectDate(context, workStartDateController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: workStartDateController,
                  decoration: InputDecoration(
                    labelText: "Start Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            if (!isCurrentStudy)
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
            // TextFormField(
            //   controller: studyStartDateController,
            //   decoration: InputDecoration(labelText: "Start Date"),
            // ),
            // if (!isCurrentStudy)
            //   TextFormField(
            //     controller: studyEndDateController,
            //     decoration: InputDecoration(labelText: "End Date"),
            //   ),
            GestureDetector(
              onTap: () => _selectDate(context, studyStartDateController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: studyStartDateController,
                  decoration: InputDecoration(
                    labelText: "Start Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            if (!isCurrentStudy)
              GestureDetector(
                onTap: () => _selectDate(context, studyEndDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: studyEndDateController,
                    decoration: InputDecoration(
                      labelText: "End Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
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
        AlumniUserPerson.alumni_work_experience?.add(createdWork);
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
        tiktok_id: AlumniUserPerson.alumni?.tiktok_id,
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

  ProfileDetailColumn({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.maxLines,
  });

  @override
  _ProfileDetailColumnState createState() => _ProfileDetailColumnState();
}

class _ProfileDetailColumnState extends State<ProfileDetailColumn> {
  late TextEditingController controller;

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
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
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
