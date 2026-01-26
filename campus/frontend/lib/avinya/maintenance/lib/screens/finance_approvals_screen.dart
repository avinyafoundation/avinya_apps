import 'package:flutter/material.dart';
import 'package:gallery/avinya/maintenance/lib/data.dart';
import 'package:gallery/avinya/maintenance/lib/widgets/task_edit_form.dart';
import '../data/activity_instance.dart';
import '../data/maintenance_finance.dart';
import '../widgets/common/data_table.dart';
import '../widgets/common/page_title.dart';
import '../widgets/finance_task_details_dialog.dart';
import '../widgets/common/pagination_controls.dart';
import '../widgets/common/button.dart';

class FinanceApprovalsScreen extends StatefulWidget {
  const FinanceApprovalsScreen({super.key});

  @override
  State<FinanceApprovalsScreen> createState() => _FinanceApprovalsScreenState();
}

class _FinanceApprovalsScreenState extends State<FinanceApprovalsScreen> {
  // State variables
  List<ActivityInstance> _pendingTasks = [];
  bool _isLoading = true;

  // Pagination state
  int _offset = 0;
  int _limit = 5;

  // Theme Colors
  final Color _headerColor = const Color(0xFF2C3E50);
  final Color _approveGreen = const Color(0xFF36B37E);
  final Color _rejectRed = const Color(0xFFFF5630);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final person = campusAppsPortalInstance.getUserPerson();
    final organizationId = person.organization?.id ?? 2;

    try {
      // Fetch tasks with financialStatus=Pending and includeFinance=true
      final tasks = await getOrganizationTasks(
        organizationId: organizationId,
        financialStatus: 'Pending',
        includeFinance: true,
        limit: _limit + 1,
        offset: _offset,
      );

      if (mounted) {
        setState(() {
          _pendingTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading data: $e");
      debugPrint("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateRow(ActivityInstance updated) {
    setState(() {
      final index = _pendingTasks.indexWhere(
        (e) => e.id == updated.id,
      );

      if (index != -1) {
        _pendingTasks[index] = updated;
      }
    });
  }

  // --- ACTIONS ---

  Future<void> _handleApprove(ActivityInstance instance) async {
    if (instance.financialInformation == null) return;

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Approval"),
        content: const Text("Are you sure you want to approve this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1. Prepare the update object
    MaintenanceFinance updateData = MaintenanceFinance(
      id: instance.financialInformation!.id,
      status: FinanceStatus.approved,
      reviewedBy: campusAppsPortalInstance.getDigitalId(),
      reviewedDate: DateTime.now().toIso8601String(),
    );

    try {
      // 2. Call API
      int organizationId =
          instance.maintenanceTask?.location?.organizationId ?? 1;
      await updateTaskFinance(organizationId, updateData);

      // 3. Update UI
      setState(() {
        _pendingTasks.removeWhere((task) => task.id == instance.id);
      });

      // 4. Show Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "'${instance.maintenanceTask?.title}' Approved Successfully"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error approving task: $e"),
          ),
        );
      }
    }
  }

  void _handleReject(ActivityInstance instance) {
    TextEditingController reasonController = TextEditingController();

    // Show Dialog to get rejection reason
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Request"),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please provide a reason for rejection:"),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: "Enter reason (e.g. Budget exceeded)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          Button(
            label: "Cancel",
            onPressed: () => Navigator.pop(context),
            buttonColor: Colors.grey[300],
            textColor: Colors.black87,
            height: 40,
            fontSize: 14,
          ),
          Button(
            label: "Reject Task",
            buttonColor: _rejectRed,
            textColor: Colors.white,
            height: 40,
            fontSize: 14,
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reason is required.")),
                );
                return;
              }
              // Close dialog and process rejection
              Navigator.pop(context);
              _submitRejection(instance, reasonController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitRejection(
      ActivityInstance instance, String reason) async {
    if (instance.financialInformation == null) return;

    MaintenanceFinance updateData = MaintenanceFinance(
      id: instance.financialInformation!.id,
      status: FinanceStatus.rejected,
      rejectionReason: reason,
      reviewedBy: campusAppsPortalInstance.getDigitalId(),
      reviewedDate: DateTime.now().toIso8601String(),
    );

    try {
      // Call API
      int organizationId =
          instance.maintenanceTask?.location?.organizationId ?? 1;
      await updateTaskFinance(organizationId, updateData);

      setState(() {
        _pendingTasks.removeWhere((task) => task.id == instance.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Task Rejected: $reason"),
            // backgroundColor: _rejectRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error rejecting task: $e"),
            // backgroundColor: _rejectRed,
          ),
        );
      }
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageTitle(
                      title: "Finance Team - Pending Approvals",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172B4D),
                    ),
                    Text(
                      "Review cost estimates and approve maintenance requests submitted by operations.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Table Section
            _isLoading
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : _pendingTasks.isEmpty
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildEmptyState(),
                      )
                    : _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            SizedBox(height: 10),
            Text("All caught up! No pending approvals.",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {

    final bool hasNext = _pendingTasks.length > _limit;
    final bool hasPrevious = _offset > 0;

    final List<ActivityInstance> displayTasks = hasNext ? _pendingTasks.sublist(0, _limit) : _pendingTasks;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: CustomDataTable(
                  width: null,
                  headingRowColor: _headerColor,
                  borderColor: Colors.grey.shade300,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(
                        label: Text("Task Name",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    DataColumn(
                        label: Text("Location",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    DataColumn(
                        label: Text("Estimated Cost",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    DataColumn(
                        label: Text("Assign To",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    DataColumn(
                        label: Text("Scheduled Date",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    DataColumn(
                        label: Text("Actions",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                  ],

                  rows: displayTasks.map((instance) {
                    return _buildDataRow(instance);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            PaginationControls(
              hasPrevious: hasPrevious,
              hasNext: hasNext,
              limit: _limit,
              onPrevious: () async {
                if (!hasPrevious || _isLoading) return;
                setState(() {
                  _offset = _offset - _limit;
                  if (_offset < 0) _offset = 0;
                });
                _loadData();
              },
              onNext: () async {
                if (!hasNext || _isLoading) return;
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
              },
            ),
          ],
        );
      },
    );
  }

  DataRow _buildDataRow(ActivityInstance instance) {
    // 1. Parse Task Name
    String taskName = instance.maintenanceTask?.title ?? "Unknown Task";

    // 2. Parse Location
    // Based on your JSON, location is nested. Adjust if your model handles it differently.
    String location =
        instance.maintenanceTask?.location?.name ?? "Unknown Location";

    // 3. Parse Cost
    double cost = instance.financialInformation?.estimatedCost ?? 0.0;

    // 4. Parse Assigned Persons (Join names with commas)
    String assignedTo = "Unassigned";
    if (instance.activityParticipants != null &&
        instance.activityParticipants!.isNotEmpty) {
      assignedTo = instance.activityParticipants!
          .map((p) => p.person?.preferred_name ?? "")
          .where((name) => name.isNotEmpty)
          .join(", ");
    }

    // 5. Parse Date
    String dateStr = "-";
    if (instance.start_time != null) {
      try {
        dateStr = DateTime.parse(instance.start_time!)
            .toLocal()
            .toString()
            .split(' ')[0];
      } catch (e) {
        dateStr = instance.start_time!;
      }
    }

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
            builder: (context) => FinanceTaskDetailsDialog(activityInstance: instance),
          );
        }
      },
      cells: [
        DataCell(Text(taskName,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(location)),
        DataCell(Text("\Rs. ${cost.toStringAsFixed(2)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87))),
        DataCell(Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(assignedTo, overflow: TextOverflow.ellipsis),
        )),
        DataCell(Text(dateStr)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Approve Button
            Button(
              label: "Approve",
              onPressed: () => _handleApprove(instance),
              buttonColor: _approveGreen,
              textColor: Colors.white,
              height: 32,
              fontSize: 13,
            ),
            const SizedBox(width: 8),
            // Reject Button
            Button(
              label: "Reject",
              onPressed: () => _handleReject(instance),
              buttonColor: _rejectRed,
              textColor: Colors.white,
              height: 32,
              fontSize: 13,
            ),
            const SizedBox(width: 8),
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () async {
                final updatedInstance = await showDialog<ActivityInstance>(
                  context: context,
                  builder: (context) =>
                      TaskEditForm(activityInstance: instance),
                );

                if (updatedInstance != null) {
                  _updateRow(updatedInstance);
                }
              },
            ),
          ],
        )),
      ],
    );
  }
}
