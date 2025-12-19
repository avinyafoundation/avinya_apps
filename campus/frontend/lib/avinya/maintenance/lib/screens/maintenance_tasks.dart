import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/widgets/task_edit_form.dart';
import '../data/activity_instance.dart';
import '../data/maintenance_finance.dart';
import '../widgets/common/button.dart';
import '../widgets/common/data_table.dart';
import '../widgets/common/date_picker.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/text_field.dart';
import '../widgets/common/pagination_controls.dart';
import '../widgets/task_details_dialog.dart';

class ReportScreen extends StatefulWidget {

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<ActivityInstance> _allActivityInstances = [];
  List<ActivityInstance> _overdueActivityInstances = [];

  // Filter States
  String? selectedPerson;
  String? selectedStatusFilter;
  String? selectedTitleFilter;
  Map<String, String> taskStatuses = {};
  String selectedMonth = "October 2025"; // Mock value
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController titleController = TextEditingController();

  // Pagination state
  int _offset = 0;
  int _limit = 5;

  @override
  void initState() {
    super.initState();
    titleController.text = selectedTitleFilter ?? '';
    titleController.addListener(() {
      setState(() {
        selectedTitleFilter =
            titleController.text.isEmpty ? null : titleController.text;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _loadData() {
    // 1. Load data using the new functions
    _allActivityInstances = getMockActivityInstancesData();

    // 2. Overdue data
    _overdueActivityInstances = getMockOverdueActivityInstancesData();
    print("Overdue Activity Instances: $_overdueActivityInstances");
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                        maxWidth: 1200), // Match Kanban Width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TITLE ---
                        const SizedBox(height: 20),
                        const PageTitle(
                          title: "Maintenance Monthly Tasks Report - Overview",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172B4D),
                        ),

                        const SizedBox(height: 25),

                        // --- 1. FILTERS SECTION ---
                        _buildFilterSection(),

                        const SizedBox(height: 30),

                        // --- 2. OVERDUE TASKS SECTION ---
                        if (_overdueActivityInstances.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.red, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Overdue Tasks",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildOverdueTable(),
                          const SizedBox(height: 30),
                        ],

                        // --- 3. ALL TASKS SECTION ---
                        const PageTitle(
                          title: "All Maintenance Tasks",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172B4D),
                        ),
                        const SizedBox(height: 10),
                        _buildAllTasksTable(),

                        const SizedBox(height: 50), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILDERS
  // ---------------------------------------------------------------------------

  // --- FILTER SECTION ---
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Filter Tasks",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: DropDown<String>(
                  label: "Filter by Person",
                  items: ["Lahiru", "Sakuna", "Basuru"],
                  selectedValues: ["Lahiru", "Sakuna", "Basuru"]
                              .indexOf(selectedPerson ?? "") >=
                          0
                      ? ["Lahiru", "Sakuna", "Basuru"].indexOf(selectedPerson!)
                      : null,
                  valueField: (item) =>
                      ["Lahiru", "Sakuna", "Basuru"].indexOf(item),
                  displayField: (item) => item,
                  onChanged: (index) => setState(() => selectedPerson =
                      index != null
                          ? ["Lahiru", "Sakuna", "Basuru"][index]
                          : null),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomDatePicker(
                  label: "From Date",
                  selectedDateString:
                      fromDate?.toLocal().toString().split(' ')[0],
                  onDateSelected: (dateString) =>
                      setState(() => fromDate = DateTime.parse(dateString)),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomDatePicker(
                  label: "To Date",
                  selectedDateString:
                      toDate?.toLocal().toString().split(' ')[0],
                  onDateSelected: (dateString) =>
                      setState(() => toDate = DateTime.parse(dateString)),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropDown<String>(
                  label: "Task Status",
                  items: ["Pending", "In Progress", "Completed"],
                  selectedValues: ["Pending", "In Progress", "Completed"]
                              .indexOf(selectedStatusFilter ?? "") >=
                          0
                      ? ["Pending", "In Progress", "Completed"]
                          .indexOf(selectedStatusFilter!)
                      : null,
                  valueField: (item) =>
                      ["Pending", "In Progress", "Completed"].indexOf(item),
                  displayField: (item) => item,
                  onChanged: (index) => setState(() => selectedStatusFilter =
                      index != null
                          ? ["Pending", "In Progress", "Completed"][index]
                          : null),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextFieldForm(
                  label: "Filter by Title",
                  controller: titleController,
                ),
              ),

              // Search Button
              Button(
                label: "Search",
                buttonColor: Colors.blue,
                textColor: Colors.white,
                height: 40,
                fontSize: 14,
                onPressed: () {
                  // Trigger search/filter action
                  _loadData();
                },
              ),
              // Clear Button
              Button(
                label: "Clear",
                buttonColor: Colors.grey[300],
                textColor: Colors.black87,
                height: 40,
                fontSize: 14,
                onPressed: () {
                  setState(() {
                    selectedPerson = null;
                    selectedStatusFilter = null;
                    selectedTitleFilter = null;
                    fromDate = null;
                    toDate = null;
                    titleController.clear();
                    _offset = 0; // Reset pagination
                  });
                  _loadData(); // Reload data
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- OVERDUE TASKS TABLE (Red Themed) ---
  Widget _buildOverdueTable() {
    return CustomDataTable(
      headingRowColor: const Color(0xFF2C3E50), // Dark Header
      dataRowColor: Colors.red.shade50, // Red Background for rows
      borderColor: Colors.red.shade100,
      columns: const [
        DataColumn(
            label: Text("Task Name",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Description",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Assigned To",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Start Date",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Overdue Days",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ],
      rows: _overdueActivityInstances.expand((instance) {
        return (instance.activityParticipants ?? []).map((participant) {
          return DataRow(cells: [
            DataCell(Text(instance.maintenanceTask?.title ?? "",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.red))),
            DataCell(Text(instance.maintenanceTask?.description ?? "-",
                style: const TextStyle(color: Colors.red))),
            DataCell(Text(participant.person?.preferred_name ?? "-",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red))),
            DataCell(Text(
              instance.start_time != null
                  ? DateTime.parse(instance.start_time!)
                      .toLocal()
                      .toString()
                      .split(' ')[0]
                  : "-",
              style: const TextStyle(color: Colors.red),
            )),
            DataCell(Center(
                child: Text(instance.overdueDays?.toString() ?? "-",
                    style: const TextStyle(color: Colors.red)))),
          ]);
        }).toList();
      }).toList(),
    );
  }

  // --- ALL TASKS TABLE (Standard Theme) ---
  Widget _buildAllTasksTable() {
    // Slice data for pagination
    final paginatedTasks =
        _allActivityInstances.skip(_offset).take(_limit).toList();
    final hasNext = _allActivityInstances.length > (_offset + _limit);
    final hasPrevious = _offset > 0;

    return Column(
      children: [
        CustomDataTable(
          showCheckboxColumn: false,
          headingRowColor: const Color(0xFF2C3E50), // Dark Header
          borderColor: Colors.grey.shade300,
          columns: const [
            DataColumn(
                label: Text("Task Name",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Location",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Start Date",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("End Date",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Task Status",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Financial Status",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Actions",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: paginatedTasks.map((instance) {
            // Mocking Data for columns not in TaskItem yet

            String financeState = instance.financialInformation != null
                ? (instance.financialInformation!.status ==
                        FinanceStatus.approved
                    ? "Approved"
                    : (instance.financialInformation!.status ==
                            FinanceStatus.rejected
                        ? "Rejected"
                        : (instance.financialInformation!.status ==
                                FinanceStatus.pending
                            ? "Pending"
                            : "Unknown")))
                : "No Financial Info";

            Color financeColor = financeState == "Approved"
                ? Colors.black
                : financeState == "Rejected"
                    ? Colors.black
                    : financeState == "Pending"
                        ? Colors.black
                        : Colors.grey;

            // Get the task status and its color
            String taskStatus = instance.overallTaskStatus ?? "Pending";
            Color statusColor = _getStatusColor(taskStatus);

            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.grey.shade100; // Color when hovering
                  }
                  return null; // Default color
                }),
                onSelectChanged: (bool? selected) {
                  if (selected != null) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          TaskDetailsDialog(activityInstance: instance),
                    );
                  }
                },
                cells: [
                  DataCell(Text(instance.maintenanceTask?.title ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(instance.maintenanceTask?.location?.name ??
                      "")), // Mock Location
                  DataCell(Text(
                    instance.start_time != null
                        ? DateTime.parse(instance.start_time!)
                            .toLocal()
                            .toString()
                            .split(' ')[0]
                        : "-",
                  )),
                  DataCell(Text(
                    instance.end_time != null
                        ? DateTime.parse(instance.end_time!)
                            .toLocal()
                            .toString()
                            .split(' ')[0]
                        : "-",
                  )),
                  DataCell(Text(instance.overallTaskStatus ?? "Pending",
                      style: TextStyle(color: statusColor))), // Dummy Status
                  DataCell(Text(financeState,
                      style: TextStyle(
                          color: financeColor, fontWeight: FontWeight.bold))),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.blue),
                        onPressed: () {
                          //Open task edit dialog
                          showDialog(
                            context: context,
                            builder: (context) =>
                                TaskEditForm(activityInstance: instance),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  )),
                ]);
          }).toList(),
        ),
        const SizedBox(height: 10),
        PaginationControls(
          hasPrevious: hasPrevious,
          hasNext: hasNext,
          limit: _limit,
          onPrevious: () {
            setState(() {
              _offset -= _limit;
              if (_offset < 0) _offset = 0;
            });
          },
          onNext: () {
            setState(() {
              _offset += _limit;
            });
          },
          onLimitChanged: (newLimit) {
            setState(() {
              _limit = newLimit;
              _offset = 0;
            });
          },
        ),
      ],
    );
  }
}
