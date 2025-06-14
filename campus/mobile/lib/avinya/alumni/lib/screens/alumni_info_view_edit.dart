import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/campus_apps_portal.dart';
import 'package:mobile/data/person.dart';
import 'package:mobile/data/profile_picture.dart';
import 'package:alumni/screens/bottom_navigation/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:alumni/screens/bottom_navigation/home/screens/my_alumni_dashboard.dart';
import 'package:alumni/widgets/time_line_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyAlumniInfoViweScreen extends StatefulWidget {
  final bool cameFromEditButton;
  const MyAlumniInfoViweScreen({Key? key, this.cameFromEditButton = false})
      : super(key: key);

  @override
  _MyAlumniInfoViweScreenState createState() => _MyAlumniInfoViweScreenState();
}

class _MyAlumniInfoViweScreenState extends State<MyAlumniInfoViweScreen> {
  final BottomNavigationController _bottomNavController =
      Get.put(BottomNavigationController());
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedProfilePictureImage;
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

  Color turquoiseBlue = Color(0xFF009DB1);
  Color secondColor = Color(0xFF00C2CB);

  bool isDistrictsDataLoaded = false;
  List<District> districts = [];
  List<City> cityList = [];
  int? selectedCityId;
  int? selectedDistrictId;
  bool _isSubmitting = false;
  bool _isUploadingProfilePicture = false;
  bool _isSubmittingWorkExperience = false;
  bool _isSubmittingStudyExperience = false;

  @override
  void initState() {
    super.initState();
    getUserPerson();
    //  if (AlumniUserPerson.mailing_address != null &&
    //     AlumniUserPerson.mailing_address!.city!.district != null)
    //   _loadCities(AlumniUserPerson.mailing_address!.city!.district!.id);
  }

  void getUserPerson() {
    // Retrieve user data from local instance
    AlumniPerson AlumniUser = campusAppsPortalInstance.getAlumniUserPerson();
    Person user = campusAppsPortalInstance.getUserPerson();
    setState(() {
      AlumniUserPerson = AlumniUser;
      UserPerson = user;
    });
    if (AlumniUser.mailing_address?.id == null) {
      selectedDistrictId = UserPerson.mailing_address?.city?.district?.id;
      selectedCityId = UserPerson.mailing_address?.city?.id ?? 0;
    } else {
      selectedDistrictId = AlumniUser.mailing_address?.city?.district?.id;
      selectedCityId = AlumniUser.mailing_address?.city?.id ?? 0;
    }

    if (selectedDistrictId != null) {
      // _loadCities(AlumniUserPerson.mailing_address!.city!.district!.id);
      _loadCities(selectedDistrictId, selectedCityId);
    }
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

  //Image picker function to get image from gallery
  Future<Uint8List?> getImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  //Image picker function to get image from gallery
  Future<Uint8List?> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  Future<Uint8List?> _showImageSourceActionSheet(BuildContext context) async {
    return await showModalBottomSheet<Uint8List?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Uint8List? image = await getImageFromCamera();
                Navigator.pop(context, image); //Return image here
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Uint8List? image = await getImageFromGallery();
                Navigator.pop(context, image);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitProfilePicture() async {
    final pickedImage = await _showImageSourceActionSheet(context);

    if (_isUploadingProfilePicture) return; //prevent double call

    _isUploadingProfilePicture = true;
    setState(() {});

    if (pickedImage != null) {
      try {
        var profilePictureDetails = {
          "id": 0,
          "person_id": AlumniUserPerson.id,
          "nic_no": AlumniUserPerson.nic_no,
          "uploaded_by": UserPerson.digital_id
        };
        ProfilePicture profilePictureUploadResponse =
            await uploadProfilePicture(pickedImage, profilePictureDetails);

        if (profilePictureUploadResponse.id != 0) {
          print("pro picture add res:${profilePictureUploadResponse.toJson()}");
          setState(() {
            _selectedProfilePictureImage = pickedImage;
            AlumniUserPerson.alumni_profile_picture =
                profilePictureUploadResponse;
            AlumniUserPerson.alumni_profile_picture!.picture =
                base64Encode(_selectedProfilePictureImage!).toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile Picture Uploaded Successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed To Upload Profile Picture: $e')),
        );
      } finally {
        _isUploadingProfilePicture = false;
        setState(() {});
      }
    } else {
      _isUploadingProfilePicture = false;
      setState(() {});
    }
  }

  void _deleteProfilePicture() async {
    if (AlumniUserPerson.alumni_profile_picture != null) {
      try {
        var result = await deleteProfilePictureById(
            AlumniUserPerson.alumni_profile_picture!.id!);

        print("pro picture delete res:${result}");
        if (result == 1) {
          setState(() {
            AlumniUserPerson.alumni_profile_picture = null;
          });
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed To Delete Profile Picture: $e')),
        );
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContexcosdantext) {
    String imagePath = AlumniUserPerson.sex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpeg'; // Default or female profile image
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            if (widget.cameFromEditButton) {
              Navigator.pop(context);
            } else {
              _bottomNavController.selectedIndex.value = 0;
            }
          },
          child: Row(
            children: [
              // SizedBox(width: 8), // Add small padding
              Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: SizerUtil.deviceType == DeviceType.tablet ? 8.w : 7.w,
              ),
              // Text(
              //   'Back',
              //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //         fontWeight: FontWeight.w600,
              //         color: kTextBlackColor,
              //         fontSize: SizerUtil.deviceType == DeviceType.mobile
              //             ? 16.sp
              //             : SizerUtil.deviceType == DeviceType.tablet
              //                 ? 18.sp
              //                 : SizerUtil.deviceType == DeviceType.web
              //                     ? 12.sp
              //                     : 14.sp,
              //       ),
              // ),
            ],
          ),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: kTextBlackColor,
                fontSize: SizerUtil.deviceType == DeviceType.mobile
                    ? 16.sp
                    : SizerUtil.deviceType == DeviceType.tablet
                        ? 18.sp
                        : SizerUtil.deviceType == DeviceType.web
                            ? 12.sp
                            : 14.sp,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          //margin: EdgeInsets.only(top: 25.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? kDarkModeSurfaceColor
                : kOtherColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              Container(
                width: 100.w,
                height: SizerUtil.deviceType == DeviceType.tablet ? 36.h : 32.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kDarkModeSurfaceColor
                      : kOtherColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: CurvedBottomClipper(),
                      child: Container(
                        height: 15.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              turquoiseBlue,
                              secondColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 2.h,
                          ),
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius:
                                      SizerUtil.deviceType == DeviceType.tablet
                                          ? 13.w
                                          : 14.w,
                                  backgroundColor: kSecondaryColor,
                                  backgroundImage:
                                      _selectedProfilePictureImage != null
                                          ? MemoryImage(
                                              _selectedProfilePictureImage!)
                                          : AlumniUserPerson
                                                      .alumni_profile_picture
                                                      ?.picture !=
                                                  null
                                              ? MemoryImage(base64Decode(
                                                  AlumniUserPerson
                                                      .alumni_profile_picture!
                                                      .picture!))
                                              : AssetImage(imagePath)
                                                  as ImageProvider,
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _isUploadingProfilePicture
                                          ? null
                                          : _submitProfilePicture,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: turquoiseBlue,
                                        child:const  Icon(Icons.camera_alt,
                                            color: Colors.white, size: 18),
                                      ),
                                    )),
                                if (_selectedProfilePictureImage != null ||
                                    AlumniUserPerson
                                            .alumni_profile_picture?.picture !=
                                        null)
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: Text(
                                                              'Remove Picture?',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        kTextBlackColor,
                                                                    fontSize: SizerUtil.deviceType ==
                                                                            DeviceType
                                                                                .mobile
                                                                        ? 14.sp
                                                                        : SizerUtil.deviceType ==
                                                                                DeviceType.tablet
                                                                            ? 16.sp
                                                                            : SizerUtil.deviceType == DeviceType.web
                                                                                ? 14.sp
                                                                                : 14.sp,
                                                                  ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        false),
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleSmall!
                                                                      .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontStyle:
                                                                            FontStyle.normal,
                                                                        color:
                                                                            kTextBlackColor,
                                                                        fontSize: SizerUtil.deviceType ==
                                                                                DeviceType.mobile
                                                                            ? 12.sp
                                                                            : SizerUtil.deviceType == DeviceType.tablet
                                                                                ? 14.sp
                                                                                : SizerUtil.deviceType == DeviceType.web
                                                                                    ? 08.sp
                                                                                    : 10.sp,
                                                                      ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    _deleteProfilePicture,
                                                                child: Text(
                                                                  'Remove',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleSmall!
                                                                      .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontStyle:
                                                                            FontStyle.normal,
                                                                        color:
                                                                            kTextBlackColor,
                                                                        fontSize: SizerUtil.deviceType ==
                                                                                DeviceType.mobile
                                                                            ? 12.sp
                                                                            : SizerUtil.deviceType == DeviceType.tablet
                                                                                ? 14.sp
                                                                                : SizerUtil.deviceType == DeviceType.web
                                                                                    ? 08.sp
                                                                                    : 10.sp,
                                                                      ),
                                                                ),
                                                              )
                                                            ],
                                                          ));
                                          if (confirm == true) {
                                            setState(() {
                                              _selectedProfilePictureImage =
                                                  null;
                                            });
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close,
                                              size: 16, color: Colors.white),
                                        ),
                                      )),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${AlumniUserPerson.full_name ?? 'N/A'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: kTextBlackColor,
                                      fontSize: SizerUtil.deviceType ==
                                              DeviceType.mobile
                                          ? 16.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 18.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 12.sp
                                                  : 14.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Text(
                                '${AlumniUserPerson.email ?? 'N/A'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade800,
                                      fontSize: SizerUtil.deviceType ==
                                              DeviceType.mobile
                                          ? 14.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 17.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 12.sp
                                                  : 14.sp,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // SizedBox(
                              //   height: 5.h,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: IconButton(
                    //     icon: Icon(
                    //       Icons.arrow_back,
                    //       size: SizerUtil.deviceType == DeviceType.tablet
                    //           ? 6.w
                    //           : 5.w,
                    //     ),
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 1.h,
              // ),
              Row(
                children: [
                  SizedBox(
                    width: 2.h,
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  SizedBox(
                    width: 2.h,
                  ),
                ],
              ),
              // SizedBox(
              //   height: 1.h,
              // ),
              Form(
                key: _formKey,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     ProfileDetailRow(
                    //         title: 'Academic Year',
                    //         value:
                    //             '${UserPerson.updated == null ? 'N/A' : '${DateFormat('yyyy').format(DateTime.parse(UserPerson.updated!))} - ${DateFormat('yyyy').format(DateTime.parse(UserPerson.updated!).add(Duration(days: 365)))} '}'),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     ProfileDetailRow(
                    //       title: 'Programme',
                    //       value: '${UserPerson.avinya_type?.focus ?? 'N/A'}',
                    //     ),
                    //     ProfileDetailRow(
                    //         title: 'Class',
                    //         value:
                    //             '${UserPerson.organization!.description ?? 'N/A'}'),
                    //   ],
                    // ),
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: kTextBlackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 15.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 16.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 14.sp
                                        : 15.sp,
                          ),
                    ),
                    sizedBox,
                    // sizedBox,
                    ProfileDetailColumn(
                      title: 'Phone Number',
                      value: '${AlumniUserPerson.phone ?? 'N/A'}',
                      onChanged: (newValue) {
                       // setState(() {
                          AlumniUserPerson.phone = int.tryParse(newValue);
                      //  });
                      },
                      maxLines: 1,
                      isRequired: true,
                      validator: _validatePhone,
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'Email',
                      value: '${AlumniUserPerson.email ?? 'N/A'}',
                      onChanged: (newValue) {
                       // setState(() {
                          AlumniUserPerson.email = newValue;
                       // });
                      },
                      maxLines: 1,
                      isRequired: true,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'Address',
                      value:
                          '${AlumniUserPerson.mailing_address?.street_address ?? 'N/A'}',
                      onChanged: (newValue) {
                        // setState(() {
                        //   AlumniUserPerson.mailing_address?.street_address =
                        //       newValue;
                        // });
                        if (AlumniUserPerson.mailing_address == null) {
                          AlumniUserPerson.mailing_address =
                              Address(street_address: newValue);
                        } else {
                          AlumniUserPerson.mailing_address!.street_address =
                              newValue;
                        }
                      },
                      maxLines: 3,
                      isRequired: true,
                      validator: _validateAddress,
                    ),
                    FutureBuilder<List<District>>(
                        future: fetchDistrictList(),
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
                            int? districtId = getDistrictIdByCityId(
                                selectedCityId, districts);
                            ;
                            selectedDistrictId =
                                districtId ?? selectedDistrictId;
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
                    Row(
                      children: [
                        SizedBox(
                          width: 2.h,
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        SizedBox(
                          width: 2.h,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Social Media Profiles',
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
                            ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'LinkedIn Profile Link',
                      value: '${AlumniUserPerson.alumni?.linkedin_id ?? 'N/A'}',
                      onChanged: (newValue) {
                        //setState(() {
                          AlumniUserPerson.alumni?.linkedin_id = newValue;
                       // });
                      },
                      maxLines: 1,
                      isRequired: false,
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'Facebook Profile Link',
                      value: '${AlumniUserPerson.alumni?.facebook_id ?? 'N/A'}',
                      onChanged: (newValue) {
                        //setState(() {
                          AlumniUserPerson.alumni?.facebook_id = newValue;
                        //});
                      },
                      maxLines: 1,
                      isRequired: true,
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'Instagram Profile Link',
                      value:
                          '${AlumniUserPerson.alumni?.instagram_id ?? 'N/A'}',
                      onChanged: (newValue) {
                       // setState(() {
                          AlumniUserPerson.alumni?.instagram_id = newValue;
                       // });
                      },
                      maxLines: 1,
                      isRequired: false,
                    ),
                    SizedBox(height: 10),
                    ProfileDetailColumn(
                      title: 'TikTok Profile Link',
                      value: '${AlumniUserPerson.alumni?.tiktok_id ?? 'N/A'}',
                      onChanged: (newValue) {
                       // setState(() {
                          AlumniUserPerson.alumni?.tiktok_id = newValue;
                      //  });
                      },
                      maxLines: 1,
                      isRequired: true,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? kDarkModeSurfaceColor
                                : kOtherColor,
                        value: AlumniUserPerson.alumni?.status,
                        decoration: InputDecoration(
                          labelText: "Employment Status",
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 14.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 16.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 12.sp
                                            : 14.sp,
                                color: kTextBlackColor,
                              ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 14.0),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.redAccent,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 12.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 14.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 12.sp
                                                  : 12.sp),
                        ),
                        items: statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an employment status';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          setState(() {
                            AlumniUserPerson.alumni?.status = newValue;
                          });
                        },
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? 16.sp
                                  : SizerUtil.deviceType == DeviceType.tablet
                                      ? 18.sp
                                      : SizerUtil.deviceType == DeviceType.web
                                          ? 14.sp
                                          : 14.sp,
                              color: kTextBlackColor,
                            ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _submitAlumniData(AlumniUserPerson,
                                      UserPerson.id, selectedDistrictId);
                                }
                              },
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16.sp, // Responsive font size
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 24.0),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10.0), // Curved edges
                            ),
                            backgroundColor: turquoiseBlue,
                            foregroundColor: kPrimaryColor,
                            elevation: 3),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildWorkSection(UserPerson.id),
                    SizedBox(height: 20),
                    _buildStudySection(UserPerson.id),
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    TimelineWidget(
                      personName: UserPerson.preferred_name!,
                      workTimeline: AlumniUserPerson.alumni_work_experience !=
                              null
                          ? AlumniUserPerson.alumni_work_experience!
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
                      educationTimeline: AlumniUserPerson
                                  .alumni_education_qualifications !=
                              null
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
            ],
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
    if (!phoneRegex.hasMatch(value) || value.length < 9) {
      return 'Enter a valid phone number (at least 9 digits)';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.length < 5) {
      return 'Address must be at least 5 characters long';
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
        child: Text(
          district.name?.name_en ?? 'Unknown',
        ),
      );
    }).toList();
  }

  // Future<void> _loadCities(int? districtId) async {
  //   final fetchedCities = await fetchCities(districtId);
  //   setState(() {
  //     cityList = fetchedCities;
  //     selectedCityId = null; // Reset selected city
  //   });
  // }

  Future<void> _loadCities(int? districtId, int? cityid) async {
    final fetchedCities = await fetchCities(districtId);
    setState(() {
      cityList = fetchedCities;
      selectedCityId = cityid;
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
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? kDarkModeSurfaceColor
                  : kOtherColor,
              value: selectedDistrictId,
              items: _getDistrictOptions(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a district';
                }
                return null;
              },
              onChanged: (value) async {
                await _loadCities(value, null);
                //setState(() {
                  selectedDistrictId = value;
                  if (AlumniUserPerson.mailing_address == null &&
                      AlumniUserPerson.mailing_address!.city == null) {
                    AlumniUserPerson.mailing_address?.city?.district = District(
                      id: value, // Use named parameter for city_id
                    );
                    AlumniUserPerson.mailing_address?.city?.district?.id =
                        value;
                  } else {
                    AlumniUserPerson.mailing_address!.city?.district = District(
                      id: value, // Use named parameter for city_id
                    );
                    AlumniUserPerson.mailing_address?.city?.district?.id =
                        value;
                  }
               // });
              },
              decoration: InputDecoration(
                labelText: 'Select District',
                labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 12.sp
                                  : 14.sp,
                      color: kTextBlackColor,
                    ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: Colors.grey.shade800, width: 1.5),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.redAccent,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 12.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 12.sp
                                : 12.sp),
              ),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: SizerUtil.deviceType == DeviceType.mobile
                      ? 16.sp
                      : SizerUtil.deviceType == DeviceType.tablet
                          ? 18.sp
                          : SizerUtil.deviceType == DeviceType.web
                              ? 14.sp
                              : 14.sp,
                  color: kTextBlackColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    //Ensure selectedCityId is valid or set to null if not found in the current city's list
    if (cityList.isNotEmpty && selectedCityId != null) {
      bool cityExists = cityList.any((city) => city.id == selectedCityId);
      if (!cityExists) {
        selectedCityId = null;
      }
      // else {
      //   selectedCityId = AlumniUserPerson.mailing_address!.city!.id;
      // }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? kDarkModeSurfaceColor
            : kOtherColor,
        value: selectedCityId,
        items: cityList
            .map((city) => DropdownMenuItem<int>(
                  value: city.id,
                  child: Text(city.name?.name_en ?? 'Unknown City'),
                ))
            .toList(),
        validator: (value) {
          if (value == null) {
            return 'Please select a city';
          }
          return null;
        },
        onChanged: (value) {
         // setState(() {
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
         // });
        },
        decoration: InputDecoration(
          labelText: 'Select City',
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: SizerUtil.deviceType == DeviceType.mobile
                    ? 14.sp
                    : SizerUtil.deviceType == DeviceType.tablet
                        ? 16.sp
                        : SizerUtil.deviceType == DeviceType.web
                            ? 12.sp
                            : 14.sp,
                color: kTextBlackColor,
              ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide:
                BorderSide(color: Colors.grey.shade800, width: 1.5),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 5.0, vertical: 14.0),
          errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.normal,
              color: Colors.redAccent,
              fontSize: SizerUtil.deviceType == DeviceType.mobile
                  ? 12.sp
                  : SizerUtil.deviceType == DeviceType.tablet
                      ? 14.sp
                      : SizerUtil.deviceType == DeviceType.web
                          ? 12.sp
                          : 12.sp),
        ),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: SizerUtil.deviceType == DeviceType.mobile
                ? 16.sp
                : SizerUtil.deviceType == DeviceType.tablet
                    ? 18.sp
                    : SizerUtil.deviceType == DeviceType.web
                        ? 14.sp
                        : 14.sp,
            color: kTextBlackColor),
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
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade500
          : kOtherColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("Add Work Experience",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: kTextBlackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 15.sp,
                      )),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Name',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 17.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 15.sp
                                    : 15.sp,
                      ),
                  controller: companyController,
                  decoration: InputDecoration(
                    //labelText: "Company Name",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.grey.shade800,
                          width: 1.5), // Highlight on focus
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Title',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 17.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 15.sp
                                    : 15.sp,
                      ),
                  controller: jobTitleController,
                  decoration: InputDecoration(
                      //labelText: "Job Title",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade800, width: 1.5),
                      )),
                ),
              ],
            ),
            SwitchListTile(
              title: Text(
                "Currently Working Here?",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 14.sp
                                  : 14.sp,
                    ),
              ),
              value: isCurrentWork,
              onChanged: (bool value) {
                setState(() {
                  isCurrentWork = value;
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context, workStartDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 15.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 17.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 15.sp
                                        : 15.sp,
                          ),
                      controller: workStartDateController,
                      decoration: InputDecoration(
                          //labelText: "Start Date",
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.5),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                if (!isCurrentWork)
                  GestureDetector(
                    onTap: () => _selectDate(context, endDateController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: kTextBlackColor,
                              fontSize: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? 15.sp
                                  : SizerUtil.deviceType == DeviceType.tablet
                                      ? 17.sp
                                      : SizerUtil.deviceType == DeviceType.web
                                          ? 15.sp
                                          : 15.sp,
                            ),
                        controller: endDateController,
                        decoration: InputDecoration(
                            //labelText: "End Date",
                            suffixIcon: Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800, width: 1.5),
                            )),
                      ),
                    ),
                  ),
              ],
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
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmittingWorkExperience
                    ? null
                    : () {
                        _submitWorkExperience(id);
                      },
                child: Text(
                  "Add Work Experience",
                  style: TextStyle(
                    fontSize: 16.sp, // Responsive font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Curved edges
                    ),
                    backgroundColor: turquoiseBlue,
                    foregroundColor: kPrimaryColor,
                    elevation: 3),
              ),
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
            child: child!,
            data: Theme.of(context).copyWith(
              dialogBackgroundColor:
                  Colors.white, // Change background color here
              colorScheme: ColorScheme.light(
                primary: kPrimaryButtonColor, // Header background
                // onPrimary: Colors.white,          // Header text color
                // onSurface: Colors.black,          // Date text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: kPrimaryButtonColor, // Button text color
                ),
              ),
            ));
      },
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
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade500
          : kOtherColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Add Study Experience",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 15.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 14.sp
                                  : 15.sp,
                    ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'University/School',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 17.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 15.sp
                                    : 15.sp,
                      ),
                  controller: universityController,
                  decoration: InputDecoration(
                      //labelText: "University/School",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade800, width: 1.5),
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Degree/Course',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 15.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 17.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 15.sp
                                    : 15.sp,
                      ),
                  controller: degreeController,
                  decoration: InputDecoration(
                      //labelText: "Degree/Course",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade800, width: 1.5),
                      )),
                ),
              ],
            ),
            SwitchListTile(
              title: Text(
                "Currently Studying Here?",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 14.sp
                                  : 14.sp,
                    ),
              ),
              value: isCurrentStudy,
              onChanged: (bool value) {
                setState(() {
                  isCurrentStudy = value;
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context, studyStartDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 15.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 17.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 15.sp
                                        : 15.sp,
                          ),
                      controller: studyStartDateController,
                      decoration: InputDecoration(
                          //labelText: "Start Date",
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.5),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                if (!isCurrentStudy)
                  GestureDetector(
                    onTap: () => _selectDate(context, studyEndDateController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: kTextBlackColor,
                              fontSize: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? 15.sp
                                  : SizerUtil.deviceType == DeviceType.tablet
                                      ? 17.sp
                                      : SizerUtil.deviceType == DeviceType.web
                                          ? 15.sp
                                          : 15.sp,
                            ),
                        controller: studyEndDateController,
                        decoration: InputDecoration(
                            //labelText: "End Date",
                            suffixIcon: Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800, width: 1.5),
                            )),
                      ),
                    ),
                  ),
              ],
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
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmittingStudyExperience
                    ? null
                    : () {
                        _submitStudyExperience(id);
                      },
                child: Text(
                  "Add Study Experience",
                  style: TextStyle(
                    fontSize: 16.sp, // Responsive font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Curved edges
                    ),
                    backgroundColor: turquoiseBlue,
                    foregroundColor: kPrimaryColor,
                    elevation: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitWorkExperience(id) async {
    if (_isSubmittingWorkExperience) return;

    _isSubmittingWorkExperience = true;
    setState(() {});

    if (companyController.text.trim().isNotEmpty &&
        jobTitleController.text.trim().isNotEmpty) {
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
        companyController.text = '';
        jobTitleController.text = '';
        isCurrentWork = false;
        workStartDateController.text = '';
        endDateController.text = '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Work experience added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add work experience: $e')),
        );
      } finally {
        _isSubmittingWorkExperience = false;
        setState(() {});
      }
    } else {
      _isSubmittingWorkExperience = false;
      setState(() {});
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
    if (_isSubmitting) return;

    _isSubmitting = true;
    setState(() {});

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
          district: District(
              id: AlumniUserPerson.mailing_address?.city?.district?.id,
              name: Name(name_en: "Kalutara")),
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
    AlumniPerson alumniPersonResponse;
    try {
      if (AlumniUserPerson.alumni?.id != null) {
        alumniPersonResponse =
            await updateAlumniPerson(person2, id, selectedDistrictId);
      } else {
        alumniPersonResponse =
            await createAlumniPerson(person2, selectedDistrictId);
      }
      setState(() {
        print("After sucess response:${jsonEncode(AlumniUserPerson.toJson())}");
        AlumniUserPerson.alumni = alumniPersonResponse.alumni;
        AlumniUserPerson.mailing_address = alumniPersonResponse.mailing_address;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alumni data processed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process alumni data: $e')),
      );
    } finally {
      _isSubmitting = false;
      setState(() {});
    }
  }

  void _submitStudyExperience(id) async {
    if (_isSubmittingStudyExperience) return;

    _isSubmittingStudyExperience = true;
    setState(() {});

    if (universityController.text.trim().isNotEmpty &&
        degreeController.text.trim().isNotEmpty) {
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
        universityController.text = '';
        degreeController.text = '';
        isCurrentStudy = false;
        studyStartDateController.text = '';
        studyEndDateController.text = '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Study experience added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add study experience: $e')),
        );
      } finally {
        _isSubmittingStudyExperience = false;
        setState(() {});
      }
    } else {
      _isSubmittingStudyExperience = false;
      setState(() {});
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
  final bool isRequired;
  final String? Function(String?)? validator;

  ProfileDetailColumn({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.maxLines,
    required this.isRequired,
    this.validator,
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
          Row(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 14.sp
                                  : 14.sp,
                    ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kErrorBorderColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: kTextBlackColor,
                  fontSize: SizerUtil.deviceType == DeviceType.mobile
                      ? 15.sp
                      : SizerUtil.deviceType == DeviceType.tablet
                          ? 17.sp
                          : SizerUtil.deviceType == DeviceType.web
                              ? 15.sp
                              : 15.sp,
                ),
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter ${widget.title}",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Colors.grey.shade800,
                    width: 1.5), // Highlight on focus
              ),
              errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.redAccent,
                  fontSize: SizerUtil.deviceType == DeviceType.mobile
                      ? 12.sp
                      : SizerUtil.deviceType == DeviceType.tablet
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.web
                              ? 12.sp
                              : 12.sp),
            ),
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            validator: widget.validator,
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
            child: child!,
            data: Theme.of(context).copyWith(
              dialogBackgroundColor:
                  Colors.white, // Change background color here
              colorScheme: ColorScheme.light(
                primary: kPrimaryButtonColor, // Header background
                // onPrimary: Colors.white,          // Header text color
                // onSurface: Colors.black,          // Date text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: kPrimaryButtonColor, // Button text color
                ),
              ),
            ));
      },
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
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? kDarkModeSurfaceColor
              : kOtherColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.type == 'work'
                  ? 'Edit Work Experience'
                  : 'Edit Study Experience',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: kTextBlackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 15.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 16.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 14.sp
                                : 15.sp,
                  ),
            ),
            SizedBox(height: 16),
            if (widget.type == 'work') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Name',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 16.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 14.sp
                                      : 14.sp,
                        ),
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 15.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 17.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 15.sp
                                      : 15.sp,
                        ),
                    controller: companyController,
                    decoration: InputDecoration(
                        //labelText: "Company Name",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade800, width: 1.5),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Title',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 16.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 14.sp
                                      : 14.sp,
                        ),
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 15.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 17.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 15.sp
                                      : 15.sp,
                        ),
                    controller: jobTitleController,
                    decoration: InputDecoration(
                        //labelText: "Job Title",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade800, width: 1.5),
                        )),
                  ),
                ],
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'University/School',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 16.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 14.sp
                                      : 14.sp,
                        ),
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 15.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 17.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 15.sp
                                      : 15.sp,
                        ),
                    controller: universityController,
                    decoration: InputDecoration(
                        //labelText: "University/School",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade800, width: 1.5),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Degree/Course',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: kTextBlackColor,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 14.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 16.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 14.sp
                                      : 14.sp,
                        ),
                  ),
                  TextFormField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 15.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 17.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 15.sp
                                        : 15.sp,
                          ),
                      controller: courseController,
                      decoration: InputDecoration(
                        //labelText: "Degree/Course",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade800, width: 1.5),
                        ),
                      )),
                ],
              ),
            ],
            SwitchListTile(
              activeColor: Colors.grey,
              title: Text(
                widget.type == 'work'
                    ? "Currently Working Here?"
                    : "Currently Studying Here?",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 14.sp
                          : SizerUtil.deviceType == DeviceType.tablet
                              ? 16.sp
                              : SizerUtil.deviceType == DeviceType.web
                                  ? 14.sp
                                  : 14.sp,
                    ),
              ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context, startDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: kTextBlackColor,
                            fontSize: SizerUtil.deviceType == DeviceType.mobile
                                ? 15.sp
                                : SizerUtil.deviceType == DeviceType.tablet
                                    ? 17.sp
                                    : SizerUtil.deviceType == DeviceType.web
                                        ? 15.sp
                                        : 15.sp,
                          ),
                      controller: startDateController,
                      decoration: InputDecoration(
                          //labelText: "Start Date",
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.5),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Date',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: kTextBlackColor,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 14.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 16.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 14.sp
                                    : 14.sp,
                      ),
                ),
                if (!isCurrent)
                  GestureDetector(
                    onTap: () => _selectDate(context, endDateController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: kTextBlackColor,
                              fontSize: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? 15.sp
                                  : SizerUtil.deviceType == DeviceType.tablet
                                      ? 17.sp
                                      : SizerUtil.deviceType == DeviceType.web
                                          ? 15.sp
                                          : 15.sp,
                            ),
                        controller: endDateController,
                        decoration: InputDecoration(
                            //labelText: "End Date",
                            suffixIcon: Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800, width: 1.5),
                            )),
                      ),
                    ),
                  ),
              ],
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
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Curved edges
                      ),
                      backgroundColor: kSecondaryButtonColor,
                      foregroundColor: kPrimaryColor,
                      elevation: 3),
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 16.sp, // Responsive font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontSize: 16.sp, // Responsive font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Curved edges
                      ),
                      backgroundColor: kPrimaryButtonColor,
                      foregroundColor: kPrimaryColor,
                      elevation: 3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Curved Bottom Clipper  Clipper for Background
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Top bar of T
    path.lineTo(0, size.height - 50);

    path.lineTo(0, size.height - 50); // Move to bottom left (before curve)

    // Create a smooth curved bottom
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);

    path.lineTo(size.width, 0); // Move to top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
