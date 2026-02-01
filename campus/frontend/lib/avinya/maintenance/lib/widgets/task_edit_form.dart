import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery/auth.dart';
import 'package:gallery/avinya/maintenance/lib/data.dart';
import 'package:gallery/avinya/maintenance/lib/widgets/common/date_picker.dart';
import '../data/academy_location.dart';
import '../data/activity_instance.dart';
import '../data/activity_participant.dart';
import '../data/maintenance_finance.dart';
import '../data/maintenance_task.dart';
import '../data/material_cost.dart';
import '../data/person.dart';
//import 'package:mock_maintenance_web/widgets/button.dart';
import 'package:path_provider_android/messages.g.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/material_cost_table.dart';
import '../widgets/common/multi_select_list.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/text_field.dart';

class TaskEditForm extends StatefulWidget {
  final ActivityInstance activityInstance;

  const TaskEditForm({
    super.key,
    required this.activityInstance,
  });

  @override
  State<TaskEditForm> createState() => TaskEditFormState();
}

class TaskEditFormState extends State<TaskEditForm> {
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
  String? selectedLocationName;
  List<int> selectedPerson = [];
  String? selectedDate;
  String? displayDate;
  List<MaterialCost> materialCosts = [];
  Map<int, int> participantIdByPersonId = {};
  Map<int, Person> personById = {};

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

    _prefillForm();

    print("Prefilled Form Data ${widget.activityInstance.toJson()}");
  }

  void _prefillForm() {
    final activity = widget.activityInstance;

    titleController.text = activity.maintenanceTask!.title ?? '';
    descriptionController.text = activity.maintenanceTask!.description ?? '';
    exceptionDaysController.text =
        activity.maintenanceTask!.exceptionDeadline?.toString() ?? '';

    selectedTaskType =
        activity.maintenanceTask!.type == MaintenanceType.recurring ? 1 : 2;

    selectedFrequency = {
      MaintenanceFrequency.daily: 1,
      MaintenanceFrequency.weekly: 2,
      MaintenanceFrequency.biWeekly: 3,
      MaintenanceFrequency.monthly: 4,
      MaintenanceFrequency.quarterly: 5,
      MaintenanceFrequency.biAnnually: 6,
      MaintenanceFrequency.annually: 7,
    }[activity.maintenanceTask!.frequency];

    selectedStatus = statuses.entries
        .firstWhere(
          (e) => e.value == activity.overallTaskStatus,
          orElse: () => const MapEntry(1, "Pending"),
        )
        .key;

    selectedLocation = activity.maintenanceTask!.location!.id;

    // selectedPerson =
    //     activity.activityParticipants?.map((p) => p.person!.id!).toList() ?? [];

    selectedPerson = [];
    participantIdByPersonId.clear();

    for (final p in activity.activityParticipants ?? []) {
      final personId = p.person!.id!;
      selectedPerson.add(personId);

      if (p.id != null) {
        participantIdByPersonId[personId] = p.id!;
      }
    }

    selectedDate = activity.start_time;
    displayDate = selectedDate?.split(' ')[0];

    print("Finance Info:  ${activity.financialInformation?.toJson()}");
    if (activity.financialInformation != null) {
      estimatedCostController.text =
          activity.financialInformation!.estimatedCost?.toString() ?? '';
      labourCostController.text =
          activity.financialInformation!.labourCost?.toString() ?? '';
      materialCosts =
          List.from(activity.financialInformation!.materialCosts ?? []);
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convert int → MaintenanceType Enum
        MaintenanceType? taskTypeEnum = selectedTaskType == 1
            ? MaintenanceType.recurring
            : MaintenanceType.oneTime;

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
        bool hasFinancialInfoBool = estimatedCostController.text.isNotEmpty ||
            labourCostController.text.isNotEmpty ||
            materialCosts.isNotEmpty;

        int hasFinancialInfo = hasFinancialInfoBool ? 1 : 0;

        // Create Task Object
        MaintenanceTask newTask = MaintenanceTask(
          id: widget.activityInstance.maintenanceTask!.id,
          //title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          //type: taskTypeEnum,
          frequency: frequencyEnum,
          locationId: selectedLocation,
          //personId: selectedPerson,
          //startDate: selectedDate,
          exceptionDeadline: int.tryParse(exceptionDaysController.text),
          hasFinancialInfo: hasFinancialInfo,
          //financialInformation: financeInfo,
          modifiedBy: campusAppsPortalInstance.user_digital_id,
          //isActive: 1,
          //statusText: statuses[selectedStatus],
        );

        List<ActivityParticipant> participants = selectedPerson.map((personId) {
          final person = personById[personId];

          return ActivityParticipant(
            person: Person(
              id: personId,
              preferred_name: person?.preferred_name,
            ),
          );
        }).toList();

        //Create Material Cost Object List
        List<MaterialCost> materialCostList = materialCosts.map((material) {
          return MaterialCost(
            id: material.id,
            item: material.item,
            quantity: material.quantity,
            unit: material.unit,
            unitCost: material.unitCost,
          );
        }).toList();

        //Create Financial Information Object
        MaintenanceFinance? financialInfo;
        if (hasFinancialInfoBool) {
          financialInfo = MaintenanceFinance(
            id: widget.activityInstance.financialInformation?.id,
            estimatedCost: estimatedCostController.text.isNotEmpty
                ? double.parse(estimatedCostController.text)
                : 0,
            labourCost: labourCostController.text.isNotEmpty
                ? double.parse(labourCostController.text)
                : 0,
            materialCosts: materialCostList,
          );
        }

        //Create Avtivity Instance Object
        ActivityInstance activityInstance = ActivityInstance(
          id: widget.activityInstance.id,
          maintenanceTask: newTask,
          activityParticipants: participants,
          financialInformation: financialInfo,
        );

        print(jsonEncode(activityInstance.toJson()));

        // Call API
        final ActivityInstance response =
            await updateActivityInstance(activityInstance);

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task updated successfully!"),
            backgroundColor: Colors.orange,
          ),
        );

        Navigator.pop(context, response);
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

  //Validators
  String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "This field cannot be empty";
    }
    return null;
  }

  String? validateDropdown(dynamic value) {
    if (value == null) {
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
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          width: 800,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              //width: 600,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      PageTitle(
                        title: "Edit Task",
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
                        enabled: false,
                        validator: (v) => v == null || v.isEmpty
                            ? "Please enter a task title"
                            : null,
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
                              enabled: false,
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
                                onChanged: (v) =>
                                    setState(() => selectedFrequency = v),
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
                              onChanged: (v) =>
                                  setState(() => selectedStatus = v),
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
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    //return const CircularProgressIndicator();
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 3),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return const Text(
                                        "Error loading locations");
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
                                    validator: (value) => value == null
                                        ? "Select a location"
                                        : null,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FutureBuilder<List<Person>>(
                                future: personsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    //return const CircularProgressIndicator();
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 3),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return const Text("Error loading persons");
                                  }

                                  final persons = snapshot.data!;

                                  personById = {
                                    for (final p in persons) p.id!: p,
                                  };

                                  final personNames = persons
                                      .map((p) => "${p.full_name}")
                                      .toList();

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
                                  );
                                },
                              ),
                            )
                          ]),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomDatePicker(
                              label: "Start Date",
                              selectedDateString: displayDate,
                              onDateSelected: (date) {
                                setState(() {
                                  selectedDate = date + " 00:00:00";
                                  displayDate = date;
                                });
                              },
                              enabled: false,
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
                            validator: validatePositiveNumber,
                            // validator: (v) {
                            //   if (!hasFinancialInfo) return null;
                            //   if (v == null || v.isEmpty) return "Required";
                            //   return null;
                            // }
                          ),
                          const SizedBox(height: 16),
                          MaterialCostTable(
                            items: materialCosts,
                            caption: "Material Costs",
                            onChanged: (updatedList) {
                              setState(() => materialCosts = updatedList);
                              print(materialCosts
                                  .map((e) => e.toJson())
                                  .toList());
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFieldForm(
                            label: "Labour Cost",
                            controller: labourCostController,
                            hintText: "eg: 1500",
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
                          // SAVE BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 165, 0),
                            ),
                            onPressed: submitForm,
                            child: const Text(
                              "Update",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
