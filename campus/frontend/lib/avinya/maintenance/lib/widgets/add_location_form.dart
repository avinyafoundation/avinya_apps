import 'package:flutter/material.dart';
import '../data/academy_location.dart';
import '../data/organization.dart';
import '../widgets/common/button.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/text_field.dart';

class AddLocationForm extends StatefulWidget {
  const AddLocationForm({super.key});

  @override
  State<AddLocationForm> createState() => _AddLocationFormState();
}

class _AddLocationFormState extends State<AddLocationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? selectedAcademy;
  Future<List<Organization>>? organizationsFuture;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //organizationsFuture = loadHardcodedOrganizations();
    organizationsFuture = fetchOrganizationsByAvinyaTypeAndStatus(2, null); 
  }

  // Hardcoded data
  // Future<List<Organization>> loadHardcodedOrganizations() async {
  //   return [
  //     Organization(id: 1, name: Name(name_en: "Avinya Academy - Colombo")),
  //     Organization(id: 2, name: Name(name_en: "Avinya Academy - Kandy")),
  //     Organization(id: 3, name: Name(name_en: "Avinya Academy - Galle")),
  //   ];
  // }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedAcademy == null) return;

      AcademyLocation academyLocation = AcademyLocation(
        organizationId: selectedAcademy!,
        name: nameController.text,
        description: descriptionController.text,
      );

      try {
        createAcademyLocation(academyLocation).then((response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Academy Location added successfully!')),
          );
          setState(() {
            selectedAcademy = null;
            nameController.clear();
            descriptionController.clear();
          });
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding location: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 800,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              PageTitle(
                title: "Add Academy Location",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              FutureBuilder<List<Organization>>(
                future: organizationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text("Error loading organizations");
                  }

                  final orgs = snapshot.data!;

                  if (selectedAcademy == null && orgs.isNotEmpty) {
                    selectedAcademy = orgs.first.id;
                  }

                  return DropDown<Organization>(
                    label: "Select Academy",
                    items: orgs,
                    selectedValues: selectedAcademy,
                    valueField: (org) => org.id!,
                    displayField: (org) => org.name?.name_en ?? '',
                    onChanged: (value) {
                      setState(() => selectedAcademy = value);
                    },
                    validator: (value) =>
                        value == null ? "Select an academy" : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFieldForm(
                label: "Location Name",
                hintText: "e.g. Pod 1, Front Office, Café",
                controller: nameController,
                validator: (v) => v == null || v.isEmpty
                    ? "Please enter location name"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFieldForm(
                label: "Location Description (Optional)",
                maxLines: 5,
                hintText: "Short description of the location",
                textAlignVertical: TextAlignVertical.top,
                controller: descriptionController,
              ),
              const SizedBox(height: 30),
              Button(
                label: "Add Location",
                width: double.infinity,
                onPressed: submitForm,
                buttonColor: Colors.blue,
                textColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
