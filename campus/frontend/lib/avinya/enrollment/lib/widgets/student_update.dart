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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedSex;
  int? selectedCityId;
  int? selectedOrgId;
  int? selectedClassId;
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    getUserPerson();
  }

  Future<void> getUserPerson() async {
    Person user = await fetchPerson(widget.id);
    setState(() {
      userPerson = user;
      selectedSex = userPerson.sex;
      selectedCityId = userPerson.mailing_address?.city?.id;
      selectedOrgId = userPerson.organization?.id;
      selectedClassId = userPerson.organization?.id;
      selectedDateOfBirth = DateTime.tryParse(userPerson.date_of_birth ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userPerson.full_name == null
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
                        _buildCityField(),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, 'Digital Information'),
                        _buildEditableField('Digital ID', userPerson.digital_id,
                            (value) {
                          userPerson.digital_id = value;
                        }),
                        _buildEditableField('Avinya Type',
                            userPerson.avinya_type?.name ?? 'N/A', (value) {
                          userPerson.avinya_type?.name = value;
                        }),
                        _buildOrganizationField(),
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
              userPerson.organization?.name?.nameEn ?? 'N/A',
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

  Widget _buildCityField() {
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
              items: _getCityOptions(),
              onChanged: (value) {
                setState(() {
                  selectedCityId = value;
                  userPerson.mailing_address?.city_id = value;
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
    // Example list of organizations
    List<Map<String, dynamic>> organizations = [
      {'id': 1, 'name': 'Org 1'},
      {'id': 2, 'name': 'Org 2'},
      {'id': 18, 'name': 'Bandaragama - Group 1'}, // Make sure this is included
    ];

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
                value: userPerson.organization
                    ?.id, // Set the initial value to match one in the list
                items: organizations.map((org) {
                  return DropdownMenuItem<int>(
                    value: org['id'],
                    child: Text(org['name']),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    userPerson.organization_id =
                        newValue; // Update the organization ID
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Organization',
                  border: OutlineInputBorder(),
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    return DateFormat('d MMM, yyyy').format(DateTime.parse(date));
  }

  List<DropdownMenuItem<int>> _getCityOptions() {
    // You can replace this with the actual data source
    List<Map<String, dynamic>> cities = [
      {
        'id': 690,
        'name': {'name_en': 'Horana', 'name_si': 'හොරණ', 'name_ta': 'ஹொரன'}
      },
      {
        'id': 1,
        'name': {'name_en': 'Colombo', 'name_si': 'කොළඹ', 'name_ta': 'கொலம்பு'}
      },
      {
        'id': 2,
        'name': {'name_en': 'Galle', 'name_si': 'ගාලු', 'name_ta': 'கல்லி'}
      },
      {
        'id': 3,
        'name': {'name_en': 'Kandy', 'name_si': 'කාන්ඩි', 'name_ta': 'காண்டி'}
      },
      {
        'id': 4,
        'name': {
          'name_en': 'Jaffna',
          'name_si': 'යාපනය',
          'name_ta': 'யாழ்ப்பாணம்'
        }
      },
    ];

    return cities.map((city) {
      return DropdownMenuItem<int>(
        value: city['id'] as int, // Explicitly cast to int
        child: Text(city['name']['name_en']
            as String), // Use the English name or adjust as needed
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _getClassOptions() {
    List<Map<String, dynamic>> classes = [
      {'id': 18, 'description': 'Leopards'},
      {'id': 2, 'description': 'Dolphine'},
      {'id': 3, 'description': 'Bees'},
      {'id': 4, 'description': 'Elephents'},
    ];

    return classes
        .map((classe) => DropdownMenuItem<int>(
              value: classe['id'] as int, // Explicitly cast to int
              child: Text(
                  classe['description'] as String), // Explicitly cast to String
            ))
        .toList();
  }

  List<DropdownMenuItem<int>> _getOrganizationOptions() {
    List<Map<String, dynamic>> organizations = [
      {'id': 1, 'name': 'Avinya Academy - Colombo'},
      {'id': 2, 'name': 'Avinya Academy - Galle'},
      {'id': 3, 'name': 'Avinya Academy - Jaffna'},
    ];

    return organizations
        .map((org) => DropdownMenuItem(
              value: org['id'] as int,
              child: Text(org['name'] as String),
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
            // savePerson(userPerson);
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
              value: selectedClassId,
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
