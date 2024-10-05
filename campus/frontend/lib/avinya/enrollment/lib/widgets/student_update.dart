import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';

class StudentUpdate extends StatefulWidget {
  final int? id;
  const StudentUpdate({Key? key, this.id}) : super(key: key);

  @override
  State<StudentUpdate> createState() => _StudentUpdateState();
}

class _StudentUpdateState extends State<StudentUpdate> {
  late Person userPerson = Person();
  List<District> districts = [];
  List<MainOrganization> organizations = [];
  List<AvinyaType> avinyaTypes = [];
  List<MainOrganization> classes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedSex;
  int? selectedCityId;
  int? selectedDistrictId;
  int? selectedOrgId;
  int? selectedClassId;
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getUserPerson();
    await fetchDistrictList();
    await fetchOrganizationList();
    await fetchAvinyaTypeList();
  }

  Future<void> getUserPerson() async {
    Person user = await fetchPerson(widget.id);
    classes = await fetchClasses(
        (user.organization?.parent_organizations?.isNotEmpty ?? false)
            ? user.organization?.parent_organizations?.first.id
            : null);

    setState(() {
      classes = classes;
      userPerson = user;
      selectedSex = userPerson.sex;
      userPerson.avinya_type_id = user.avinya_type?.id;

      // Safely assign city and organization IDs with fallbacks
      selectedCityId = userPerson.mailing_address?.city?.id ??
          0; // Default to 0 or another fallback value
      selectedOrgId =
          userPerson.organization?.id ?? 0; // Similarly handle organization ID
      selectedClassId = userPerson.organization?.id ??
          0; // Ensure organization ID is used for class as well

      // Handling date of birth
      String? dob = userPerson.date_of_birth;
      print("Date of Birth String: $dob");

      // Safely try parsing the date of birth
      if (dob == null || dob.isEmpty) {
        selectedDateOfBirth = DateTime.now(); // Default if dob is null or empty
      } else {
        try {
          selectedDateOfBirth =
              DateTime.parse(dob); // Use DateTime.parse directly
        } catch (e) {
          print('Error parsing date: $e');
          selectedDateOfBirth =
              DateTime.now(); // Fallback to now if parsing fails
        }
      }
    });
  }

  Future<void> fetchDistrictList() async {
    List<District> districtList = await fetchDistricts();
    int? districtId = getDistrictIdByCityId(selectedCityId, districtList);
    if (mounted) {
      setState(() {
        districts = districtList;
        selectedDistrictId = districtId ?? selectedDistrictId;
        // if (districtId != null) {
        //   // Update the cities based on the district
        //   selectedCityId = null; // Reset city selection when district changes
        // }
      });
    }
  }

  Future<void> fetchOrganizationList() async {
    List<MainOrganization> orgList = await fetchOrganizations();
    if (mounted) {
      setState(() {
        organizations = orgList;
      });
    }
  }

  Future<void> fetchAvinyaTypeList() async {
    List<AvinyaType> avinyaTypeList = await fetchAvinyaTypes();
    if (mounted) {
      setState(() {
        avinyaTypes = avinyaTypeList;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userPerson.preferred_name == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 800,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(context),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Student Information'),
                        _buildEditableField(
                            'Preferred Name', userPerson.preferred_name,
                            (value) {
                          userPerson.preferred_name = value;
                        }),
                        _buildEditableField('Full Name', userPerson.full_name,
                            (value) {
                          userPerson.full_name = value;
                        }),
                        _buildDateOfBirthField(context),
                        _buildSexField(),
                        const SizedBox(height: 10),
                        _buildOrganizationField(),
                        _buildStudentClassField(), // Student Class based on organization.description
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Contact Information'),
                        _buildEditableField('Personal Email', userPerson.email,
                            (value) {
                          userPerson.email = value;
                        }),
                        _buildEditableField(
                            'Phone', userPerson.phone?.toString() ?? '',
                            (value) {
                          userPerson.phone = int.tryParse(value);
                        }),
                        _buildEditableField('Street Address',
                            userPerson.mailing_address?.street_address ?? 'N/A',
                            (value) {
                          if (userPerson.mailing_address == null) {
                            userPerson.mailing_address =
                                Address(street_address: value);
                          } else {
                            userPerson.mailing_address!.street_address = value;
                          }
                        }),
                        _buildDistrictField(),
                        _buildCityField(),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Digital Information'),
                        _buildEditableField('Digital ID', userPerson.digital_id,
                            (value) {
                          userPerson.digital_id = value;
                        }),
                        _buildAvinyaTypeField(),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Bank Information'),
                        _buildEditableField('Bank Name', userPerson.bank_name,
                            (value) {
                          userPerson.bank_name = value;
                        }),
                        _buildEditableField(
                            'Bank Branch', userPerson.bank_branch, (value) {
                          userPerson.bank_branch = value;
                        }),
                        _buildEditableField(
                            'Bank Account Name', userPerson.bank_account_name,
                            (value) {
                          userPerson.bank_account_name = value;
                        }),
                        _buildEditableField(
                            'Account Number', userPerson.bank_account_number,
                            (value) {
                          userPerson.bank_account_number = value;
                        }),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Professional Information'),
                        _buildEditableField(
                            'Current Job', userPerson.current_job, (value) {
                          userPerson.current_job = value;
                        }),
                        _buildEditableTextArea('Comments', userPerson.notes,
                            (value) {
                          userPerson.notes = value;
                        }),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    String imagePath = selectedSex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpeg'; // Default or female profile image

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userPerson.full_name ?? 'N/A',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              userPerson.organization?.parent_organizations != null &&
                      userPerson.organization!.parent_organizations!.isNotEmpty
                  ? userPerson.organization?.parent_organizations!.first.name
                          ?.name_en ??
                      'N/A'
                  : 'N/A',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEditableField(
      String label, String? initialValue, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: TextFormField(
              initialValue: initialValue ?? '',
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => onSave(value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextArea(
      String label, String? initialValue, Function(String) onSave,
      {int minLines = 1, int maxLines = 5}) {
    // Set maxLines to a desired value for textarea
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: TextFormField(
              initialValue: initialValue ?? '',
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => onSave(value!),
              minLines: minLines, // Minimum lines to display
              maxLines: maxLines, // Maximum lines to display
              maxLength: 1000, // Maximum character limit
              buildCounter: (BuildContext context,
                  {required int currentLength,
                  required bool isFocused,
                  required int? maxLength}) {
                return Text(
                  '$currentLength/${maxLength ?? 1000}', // Display character count
                  style: TextStyle(
                    color: currentLength > (maxLength ?? 1000)
                        ? Colors.red
                        : null, // Change color if limit exceeded
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Sex',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<String>(
              value: selectedSex,
              items: ['Male', 'Female', 'Other']
                  .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSex = value;
                  userPerson.sex = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'District',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: selectedDistrictId,
              items: _getDistrictOptions(),
              onChanged: (value) {
                setState(() {
                  selectedDistrictId = value;
                  userPerson.mailing_address?.district_id = value;
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
    List<City> cityList = districts
            .firstWhere(
              (district) => district.id == selectedDistrictId,
              orElse: () => District(
                id: 0,
                name: Name(name_en: 'Unknown'),
                cities: [],
              ),
            )
            .cities ??
        [];

    // Ensure selectedCityId is valid or set to null if not found in the current city's list
    if (cityList.isNotEmpty && selectedCityId != null) {
      bool cityExists = cityList.any((city) => city.id == selectedCityId);
      if (!cityExists) {
        selectedCityId = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'City',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
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
                  userPerson.mailing_address?.city_id = value;

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

  Widget _buildOrganizationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Main Organization',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value:
                  userPerson.organization?.parent_organizations?.first.id ?? 0,
              items: organizations
                  .where((org) =>
                      org.avinya_type?.id == 105 ||
                      org.avinya_type?.id == 86) // Filter organizations
                  .map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name?.name_en ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (int? newValue) async {
                classes = await fetchClasses(newValue);
                setState(() {
                  classes = classes;
                  userPerson.organization_id =
                      newValue; // Update the organization ID
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Organization',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvinyaTypeField() {
    // Function to calculate age from a String date of birth
    int? calculateAge(String? birthDateString) {
      if (birthDateString == null || birthDateString.isEmpty) return null;

      try {
        final birthDate =
            DateTime.parse(birthDateString); // Parse the date string
        final currentDate = DateTime.now();
        int age = currentDate.year - birthDate.year;
        if (currentDate.month < birthDate.month ||
            (currentDate.month == birthDate.month &&
                currentDate.day < birthDate.day)) {
          age--;
        }
        return age;
      } catch (e) {
        // Handle invalid date format
        print('Invalid date format: $birthDateString');
        return null;
      }
    }

    // Determine the Avinya Type ID
    final int? avinyaTypeId = (userPerson.date_of_birth != null &&
            calculateAge(userPerson.date_of_birth) != null &&
            calculateAge(userPerson.date_of_birth)! < 19)
        ? 103 // Auto-select Future Enrollees if under 18
        : userPerson.avinya_type?.id;

    // Filter avinyaTypes based on the selected IDs
    final filteredAvinyaTypes = avinyaTypes.where((org) {
      return org.id == 26 || // student applicant
          org.id == 37 || // empower-student
          org.id == 10 || // Vocational IT
          org.id == 96 || // Vocational CS
          org.id == 93 || // dropout-empower-student
          org.id == 100 || // dropout-cs-student
          org.id == 99 || // dropout-it-student
          org.id == 103 || // Future Enrollees
          org.id == 94; // dropout-student-applicant
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Avinya Type',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              // Ensure the value matches one of the filtered Avinya Types
              value: filteredAvinyaTypes.any((org) => org.id == avinyaTypeId)
                  ? avinyaTypeId
                  : null,
              items: filteredAvinyaTypes.map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  userPerson.avinya_type_id =
                      newValue; // Update the Avinya Type ID
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Avinya Type',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    return DateFormat('d MMM, yyyy').format(DateTime.parse(date));
  }

  List<DropdownMenuItem<int>> _getDistrictOptions() {
    return districts.map((district) {
      return DropdownMenuItem<int>(
        value: district.id as int,
        child: Text(district.name?.name_en ?? 'Unknown'),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _getCityOptions() {
    if (selectedDistrictId != null) {
      final selectedDistrict =
          districts.firstWhere((district) => district.id == selectedDistrictId);

      List<City>? cities = selectedDistrict.cities;

      return cities!.map((city) {
        return DropdownMenuItem<int>(
          value: city.id as int, // Cast city ID to int
          child: Text(city.name?.name_en as String), // Display the English name
        );
      }).toList();
    } else {
      return [];
    }
  }

  List<DropdownMenuItem<int>> _getClassOptions() {
    return classes
        .map((classe) => DropdownMenuItem<int>(
              value: classe.id, // Access id directly from MainOrganization
              child: Text(classe.description ??
                  'No description'), // Handle null description
            ))
        .toList();
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Save userPerson changes
            updatePerson(userPerson);
          }
        },
        child: const Text('Save Changes'),
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Date of Birth',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDateOfBirth ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDateOfBirth = pickedDate;
                    userPerson.date_of_birth =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Date Of Birth',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDateOfBirth == null
                      ? 'Select Date'
                      : DateFormat('d MMM, yyyy').format(selectedDateOfBirth!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentClassField() {
    if (classes.isEmpty) {
      return Container();
    } else {
      // Ensure selectedClassId exists in the class list, otherwise set it to null
      final isValidClass = classes.any((cls) => cls.id == selectedClassId);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                'Class',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Expanded(
              flex: 6,
              child: DropdownButtonFormField<int>(
                value: isValidClass
                    ? selectedClassId
                    : null, // Validate selectedClassId
                items: _getClassOptions(),
                onChanged: (value) {
                  setState(() {
                    selectedClassId = value;
                    userPerson.organization?.id = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
