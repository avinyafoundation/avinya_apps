import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/data.dart';
import 'package:gallery/avinya/maintenance/lib/data/person.dart';
import '../data/academy_location.dart';
import '../data/maintenance_finance.dart';
import '../data/maintenance_task.dart';
import '../data/material_cost.dart';
//import '../widgets/common/button.dart';
import '../widgets/common/date_picker.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/material_cost_table.dart';
import '../widgets/common/multi_select_list.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/text_field.dart';

class TaskCreateForm extends StatefulWidget {
  const TaskCreateForm({super.key});

  @override
  State<TaskCreateForm> createState() => _TaskCreateFormState();
}

class _TaskCreateFormState extends State<TaskCreateForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController exceptionDaysController = TextEditingController();
  final TextEditingController estimatedCostController = TextEditingController();
  final TextEditingController labourCostController = TextEditingController();

  int? selectedTaskType = 1;
  int? selectedFrequency = 1;
  int? selectedLocation;
  int? selectedStatus = 1;
  List<int> selectedPerson = [];
  String? selectedDate;
  String? displayDate;
  List<MaterialCost> materialCosts = [];

  final taskTypes = {
    1: "Recurring",
    2: "One Time",
  };

  final frequencies = {
    1: "Daily",
    2: "Weekly",
    3: "Bi-Weekly",
    4: "Monthly",
    5: "Quarterly",
    6: "Bi-Annually",
    7: "Annually",
  };

  final statuses = {
    1: "Pending",
    2: "In Progress",
    3: "Completed",
  };

  Future<List<AcademyLocation>>? locationsFuture;
  Future<List<Person>>? personsFuture;
  //List<String> selectedPeople = [];

  //bool isLoading = true;

  @override
  void initState() {
    super.initState();
    locationsFuture = fetchAllAcademyLocations(2);
    personsFuture = fetchEmployeeListByOrganization(2);
  }


  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convert int → MaintenanceType Enum
        MaintenanceType? taskTypeEnum =
            selectedTaskType == 1 ? MaintenanceType.recurring : MaintenanceType.oneTime;

        // Convert int → MaintenanceFrequency Enum
        MaintenanceFrequency? frequencyEnum = {
          1: MaintenanceFrequency.daily,
          2: MaintenanceFrequency.weekly,
          3: MaintenanceFrequency.biWeekly,
          4: MaintenanceFrequency.monthly,
          5: MaintenanceFrequency.quarterly,
          6: MaintenanceFrequency.biAnnually,
          7: MaintenanceFrequency.annually,
        }[selectedFrequency];

        // Check if the financial information section is filled
        bool hasFinancialInfoBool =
            estimatedCostController.text.isNotEmpty ||
            labourCostController.text.isNotEmpty ||
            materialCosts.isNotEmpty;

        int hasFinancialInfo = hasFinancialInfoBool? 1 : 0;

        // Build the financial information object
        MaintenanceFinance? financeInfo;

        if (hasFinancialInfoBool) {
          financeInfo = MaintenanceFinance(
            estimatedCost: estimatedCostController.text.isNotEmpty
                ? double.parse(estimatedCostController.text)
                : 0,
            labourCost: labourCostController.text.isNotEmpty
                ? double.parse(labourCostController.text)
                : 0,
            materialCosts: materialCosts,
          );
    }

      // Create Task Object
      MaintenanceTask newTask = MaintenanceTask(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: taskTypeEnum,
        frequency: frequencyEnum,
        locationId: selectedLocation,
        personId: selectedPerson,
        startDate: selectedDate,
        exceptionDeadline: int.tryParse(exceptionDaysController.text),
        hasFinancialInfo: hasFinancialInfo,
        financialInformation: financeInfo,
        modifiedBy: campusAppsPortalInstance.getDigitalId(), 
        //isActive: 1,
        //statusText: statuses[selectedStatus],
      );

      print(jsonEncode(newTask.toJson())
      );

      // Call API
      final response = await saveMaintenanceTask(newTask);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      resetForm();

    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving task: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}





  void resetForm() {
    // Clear text fields
    titleController.clear();
    descriptionController.clear();
    startDateController.clear();
    exceptionDaysController.clear();
    estimatedCostController.clear();
    labourCostController.clear();

    // Reset dropdowns
    selectedTaskType = 1;
    selectedFrequency = 1;
    selectedStatus = 1;
    selectedLocation = null;

    // Reset persons
    selectedPerson = [];

    // Reset date
    selectedDate = null;
    displayDate = null;

    // Reset material costs
    materialCosts = [];

    // Rebuild UI
    setState(() {});
  }




  //Validators
  String? validateNotEmpty(String? value){
    if(value == null || value.isEmpty){
      return "This field cannot be empty";
    }
    return null;
  }


  String? validateDropdown(dynamic value){
    if(value == null){
      return "Please make a selection";
    }
    return null;
  }

  String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) return "Please enter a valid number";
    if (number <= 0) return "Value cannot be negative or zero";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 800,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                PageTitle(
                  title: "Add New Task",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  //color: const Color.fromARGB(255, 30, 41, 243),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,             
                  height: 10,           
                  color: Colors.blue[700],   
                ),
                const SizedBox(height: 30),
                TextFieldForm(
                  label: "Task Title",
                  hintText: "eg: Academy Lights",
                  controller: titleController,
                  validator: (v) => 
                    v == null || v.isEmpty ? "Please enter a task title" : null,
                ),
                const SizedBox(height: 16),
                TextFieldForm(
                  label: "Task Description",
                  hintText: "eg: Check and replace lights in the academy",
                  controller: descriptionController,
                  //maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropDown<int>(
                        label: 'Task Type',
                        items: taskTypes.keys.toList(),
                        selectedValues: selectedTaskType,
                        valueField: (v) => v,
                        displayField: (v) => taskTypes[v]!,
                        onChanged: (v) => setState(() {
                          selectedTaskType = v;

                          if (selectedTaskType == 2) {
                            selectedFrequency = null;
                          }
                        }),
                        validator: (v) => validateDropdown(v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (selectedTaskType == 1) ...[
                      Expanded(
                        child: DropDown<int>(
                          label: 'Frequency',
                          items: frequencies.keys.toList(),
                          selectedValues: selectedFrequency,
                          valueField: (v) => v,
                          displayField: (v) => frequencies[v]!,
                          onChanged: (v) => setState(() => selectedFrequency = v),
                          validator: (v) => validateDropdown(v),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: DropDown<int>(
                        label: 'Status',
                        items: statuses.keys.toList(),
                        selectedValues: selectedStatus,
                        valueField: (v) => v,
                        displayField: (v) => statuses[v]!,
                        enabled: false,
                        onChanged: (v) => setState(() => selectedStatus = v),
                        validator: (v) => validateDropdown(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FutureBuilder<List<AcademyLocation>>(
                        future: locationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            //return const CircularProgressIndicator();
                            return const Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 3),
                              ),
                            );
                          }
                                      
                        if (snapshot.hasError) {
                          return const Text("Error loading locations");
                        }
                                      
                        final locations = snapshot.data!;
                                      
                        return DropDown<AcademyLocation>(
                          label: "Select Location",
                          items: locations,
                          selectedValues: selectedLocation,
                          valueField: (loc) => loc.id!,
                          displayField: (loc) => loc.name ?? '',
                          onChanged: (value) {
                            setState(() => selectedLocation = value);
                          },
                          validator: (value) =>
                              value == null ? "Select a location" : null,
                        );
                      },
                                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<List<Person>>(
                        future: personsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            //return const CircularProgressIndicator();
                            return const Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 3),
                              ),
                            );
                          }
                                    
                          if (snapshot.hasError) {
                            return const Text("Error loading persons");
                          }
                                    
                          final persons = snapshot.data!;
                                    
                          final personNames = persons.map((p) => "${p.full_name}").toList();
                      
                          return MultiSelectDropdown<Person>(
                            label: "Select Persons",
                            items: persons,
                            selectedItems: selectedPerson,
                            valueField: (p) => p.id!,
                            displayField: (p) => p.preferred_name!,
                            onSelect: (id) {
                              setState(() => selectedPerson.add(id));
                              print(selectedPerson);
                            },
                            onUnselect: (id) {
                              setState(() => selectedPerson.remove(id));
                              print(selectedPerson);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select at least one person";
                              }
                              return null;
                            },
                          );
                        },
                                ),
                    )
                    ]
                    ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        label: "Start Date",
                        selectedDateString: displayDate,
                        initialDate: DateTime.now(),
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date + " 00:00:00";
                            displayDate = date;
                          });
                        },
                        validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a date";
                            }
                            return null;
                          },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFieldForm(
                        label: "Exception Days",
                        hintText: "eg: 2",
                        controller: exceptionDaysController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Exception days is required";
                          }
                          if (int.tryParse(value) == null) {
                            return "Enter a valid number";
                          }
                          if (int.parse(value) <= 0) {
                            return "Value must be greater than 0";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  //backgroundColor: Colors.grey[200],
                  title: Text(
                    "Financial Information (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  childrenPadding: const EdgeInsets.all(8.0),
                  children: [
                    TextFieldForm(
                      label: "Estimated Total Cost",
                      controller: estimatedCostController,
                      hintText: "eg: 4000",
                      keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: validatePositiveNumber,
                      // validator: (v) => 
                      //   v == null || v.isEmpty ? "Please enter estimated cost" : null,
                    ),
                    const SizedBox(height: 16),
                    MaterialCostTable(
                      items: materialCosts,
                      caption: "Material Costs",
                      onChanged: (updatedList) {
                        setState(() => materialCosts = updatedList);
                        print(materialCosts.map((e) => e.toJson()).toList());
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldForm(
                      label: "Labour Cost",
                      controller: labourCostController,
                      hintText: "eg: 1500",
                      keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: validatePositiveNumber,
                      // validator: (v) => 
                      //   v == null || v.isEmpty ? "Please enter labour cost" : null,
                    ),
                ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: resetForm,
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // SAVE BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 127, 6),
                      ),
                      onPressed: submitForm,
                      child: const Text(
                        "Save Task",
                        style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

              ],
            )
          ),
        ),
      ),
    );
  }
}
