import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/data/maintenance_task.dart';
import 'package:gallery/avinya/maintenance/lib/widgets/task_edit_form.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';
import '../data/activity_instance.dart';
import '../data/activity_participant.dart';
import '../data/maintenance_finance.dart';
import '../data/person.dart';
import '../widgets/common/button.dart';
import '../widgets/common/multi_select_list.dart';
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
  bool _isLoading = true;
  List<Person> _personList = [];

  // Filter States
  List<int> selectedPersonIds = [];
  String? selectedStatusFilter;
  String? selectedTitleFilter;
  Map<String, String> taskStatuses = {};
  String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController titleController = TextEditingController();

  // Pagination state
  int _offset = 0;
  int _limit = 5;

  // Scroll controllers
  late ScrollController _verticalController;
  late ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();

    // Default date range: from today to one month ahead
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(now.year, now.month + 1, now.day);

    titleController.text = selectedTitleFilter ?? '';
    titleController.addListener(() {
      setState(() {
        selectedTitleFilter =
            titleController.text.isEmpty ? null : titleController.text;
      });
    });
    _loadPersonList();
    _loadData();
  }

  @override
  void dispose() {
    titleController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _loadPersonList() async {
    try {
      final persons = await fetchEmployeeListByOrganization(2);
      if (mounted) {
        setState(() {
          _personList = persons;
        });
      }
    } catch (e) {
      debugPrint('Error loading person list: $e');
    }
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final person = campusAppsPortalInstance.getUserPerson();
    final organizationId = person.organization?.id ?? 1;

    // Parse fromDate and toDate from the selectedMonth if needed
    String? fromDateStr;
    String? toDateStr;

    if (fromDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate!);
    }
    if (toDate != null) {
      toDateStr = DateFormat('yyyy-MM-dd').format(toDate!);
    }

    try {
      // 1. Load data using the real API
      print("Fetching tasks for organizationId: $organizationId");
      final allTasks = await getOrganizationTasks(
        organizationId: organizationId,
        personId: selectedPersonIds.isNotEmpty ? selectedPersonIds : null,
        fromDate: fromDateStr,
        toDate: toDateStr,
        overallTaskStatus: selectedStatusFilter,
        title: selectedTitleFilter,
        limit: _limit + 1,
        offset: _offset,
      );
      print("All tasks received: ${allTasks.length}");

      // 2. Overdue data
      final overdueTasks = await fetchOverdueActivityInstance(organizationId);
      print("Overdue tasks received: ${overdueTasks.length}");

      if (mounted) {
        setState(() {
          _allActivityInstances = allTasks;
          _overdueActivityInstances = overdueTasks;
          _isLoading = false;
        });
      }
      print("Overdue Activity Instances: $_overdueActivityInstances");
    } catch (e, stackTrace) {
      debugPrint("Error fetching data: $e");
      debugPrint("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'inprogress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _updateRow(ActivityInstance updated) {
    setState(() {
      final index = _allActivityInstances.indexWhere(
        (e) => e.id == updated.id,
      );

      if (index != -1) {
        _allActivityInstances[index] = updated;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalController,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Person Filter
              SizedBox(
                width: 250,
                child: MultiSelectDropdown<Person>(
                  label: "Filter by Person",
                  items: _personList,
                  selectedItems: selectedPersonIds,
                  valueField: (person) => person.id ?? 0,
                  displayField: (person) => person.preferred_name ?? 'Unknown',
                  onSelect: (personId) {
                    setState(() {
                      selectedPersonIds.add(personId);
                    });
                  },
                  onUnselect: (personId) {
                    setState(() {
                      selectedPersonIds.remove(personId);
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              // Right Column - Other Filters
              Expanded(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      width: 200,
                      child: CustomDatePicker(
                        label: "From Date",
                        selectedDateString:
                            fromDate?.toLocal().toString().split(' ')[0],
                        onDateSelected: (dateString) => setState(
                            () => fromDate = DateTime.parse(dateString)),
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
                        items: ["Pending", "InProgress", "Completed"],
                        selectedValues: ["Pending", "InProgress", "Completed"]
                                    .indexOf(selectedStatusFilter ?? "") >=
                                0
                            ? ["Pending", "InProgress", "Completed"]
                                .indexOf(selectedStatusFilter!)
                            : null,
                        valueField: (item) => [
                          "Pending",
                          "InProgress",
                          "Completed"
                        ].indexOf(item),
                        displayField: (item) => item,
                        onChanged: (index) => setState(() =>
                            selectedStatusFilter = index != null
                                ? ["Pending", "InProgress", "Completed"][index]
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
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
              const SizedBox(width: 10),
              // Clear Button
              Button(
                label: "Reset Filters",
                buttonColor: Colors.grey[300],
                textColor: Colors.black87,
                height: 40,
                fontSize: 14,
                onPressed: () {
                  setState(() {
                    selectedPersonIds.clear();
                    selectedStatusFilter = null;
                    selectedTitleFilter = null;
                    fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                    toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);
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
    // Count total overdue rows (can be multiple participants per task)
    int totalRows = _overdueActivityInstances.fold(0,
        (sum, instance) => sum + (instance.activityParticipants?.length ?? 0));

    final tableWidget = CustomDataTable(
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
            label: Text("Pending Assignees",
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
      rows: _overdueActivityInstances.map((instance) {
        // Filter to only show pending participants (not completed)
        final pendingParticipants = (instance.activityParticipants ?? [])
            .where((p) => p.status != ProgressStatus.completed)
            .toList();

        // Join pending participant names with comma
        final pendingNames = pendingParticipants
            .map((p) => p.person?.preferred_name ?? '-')
            .join(', ');

        return DataRow(cells: [
          DataCell(Text(instance.maintenanceTask?.title ?? "",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.red))),
          DataCell(Text(instance.maintenanceTask?.description ?? "-",
              style: const TextStyle(color: Colors.red))),
          DataCell(
            SizedBox(
              width: 200,
              child: Text(
                pendingNames.isNotEmpty ? pendingNames : "-",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
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
      }).toList(),
    );

    // If more than 5 rows, make it scrollable with fixed height
    if (totalRows > 5) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade100),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          child: tableWidget,
        ),
      );
    }

    return tableWidget;
  }

  void _deactivateTask(ActivityInstance instance) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deactivation"),
        content: const Text("Are you sure you want to deactivate this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        print("Deactivating task id: ${instance.maintenanceTask!.id}");
        print("Modified by digital id: ${campusAppsPortalInstance.getDigitalId().toString()}");
        await deactivateMaintenanceTask(instance.maintenanceTask!.id!, campusAppsPortalInstance.getDigitalId().toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task deactivated successfully")),
          );
        }
        _loadData(); // Reload data
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to deactivate task: $e")),
          );
        }
      }
    }
  }

  // --- ALL TASKS TABLE (Standard Theme) ---
  Widget _buildAllTasksTable() {
    // Slice data for pagination
    bool actuallyHasNextPage = _allActivityInstances.length > _limit;
    final displayTasks = actuallyHasNextPage
        ? _allActivityInstances.sublist(0, _limit)
        : _allActivityInstances;
    final hasPrevious = _offset > 0;

    // No-results placeholder
    if (displayTasks.isEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  color: Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No tasks found for the selected filters',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedPersonIds.clear();
                      selectedStatusFilter = null;
                      selectedTitleFilter = null;
                      fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                      toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);
                      titleController.clear();
                      _offset = 0;
                    });
                    _loadData();
                  },
                  child: const Text('Reset filters'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // keep pagination visible but disabled when there are no results
          PaginationControls(
            hasPrevious: false,
            hasNext: false,
            limit: _limit,
            onPrevious: () {},
            onNext: () {},
            onLimitChanged: (newLimit) async {
              setState(() {
                _limit = newLimit;
                _offset = 0;
              });
              _loadData();
            },
          ),
        ],
      );
    }


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
          rows: displayTasks.map((instance) {
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
                          TaskDetailsDialog(activityInstance: instance, onSave: _loadData),
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
                        onPressed: () async {
                          final updatedInstance =
                              await showDialog<ActivityInstance>(
                            context: context,
                            builder: (context) =>
                                TaskEditForm(activityInstance: instance),
                          );

                          if (updatedInstance != null) {
                            _updateRow(updatedInstance);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        onPressed: () => _deactivateTask(instance),
                      ),
                    ],
                  )),
                ]);
          }).toList(),
        ),
        const SizedBox(height: 10),
        PaginationControls(
          hasPrevious: hasPrevious,
          hasNext: actuallyHasNextPage,
          limit: _limit,
          onPrevious: () async {
            if (!hasPrevious || _isLoading) return;
            setState(() {
              _offset = _offset - _limit;
              if (_offset < 0) _offset = 0;
            });
            _loadData();
            if (_verticalController.hasClients) {
              _verticalController.animateTo(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            }
          },
          onNext: () async {
            setState(() {
              _offset = _offset + _limit;
            });
            _loadData();
          },
          onLimitChanged: (newLimit) async {
            if (_isLoading) return;
            setState(() {
              _limit = newLimit;
              _offset = 0;
            });
            _loadData();
            if (_verticalController.hasClients) {
              _verticalController.animateTo(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            }
          },
        ),
      ],
    );
  }
}
