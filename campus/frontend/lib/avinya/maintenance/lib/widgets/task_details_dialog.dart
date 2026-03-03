import 'package:flutter/material.dart';
import '../data/maintenance_finance.dart';
import '../data/activity_instance.dart';
import '../data/activity_participant.dart';
import 'common/button.dart';
import 'common/colourful_dropdown.dart';
import '../data/task_item.dart';
import 'package:gallery/avinya/maintenance/lib/data.dart';

class TaskDetailsDialog extends StatefulWidget {
  final ActivityInstance activityInstance;
  final VoidCallback? onSave;

  const TaskDetailsDialog({super.key, required this.activityInstance, this.onSave});

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  // Map to track original participant statuses to detect changes
  Map<int, ProgressStatus> _originalParticipantStatuses = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Store original participant statuses
    if (widget.activityInstance.activityParticipants != null) {
      for (var participant in widget.activityInstance.activityParticipants!) {
        if (participant.person?.id != null && participant.status != null) {
          _originalParticipantStatuses[participant.person!.id!] =
              participant.status!;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600
        ? screenWidth * 0.9 // 90% width on mobile
        : (screenWidth < 1200
            ? 500.0 // 500px on tablets
            : 600.0); // 600px on desktop

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(screenWidth < 600 ? 16 : 24),
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.activityInstance.maintenanceTask?.title ?? "_",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const Divider(),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // --- Task Details ---
                    _buildDetailRow(
                        Icons.description,
                        "Description",
                        widget.activityInstance.maintenanceTask?.description ??
                            "-"),
                    _buildDetailRow(
                        Icons.location_on,
                        "Location",
                        widget.activityInstance.maintenanceTask?.location
                                ?.name ??
                            "-"),
                    _buildDetailRow(Icons.calendar_today, "Timeline",
                        "${widget.activityInstance.start_time?.split(' ')[0] ?? '-'} to ${widget.activityInstance.end_time?.split(' ')[0] ?? '-'}"),
                    _buildDetailRow(
                      Icons.attach_money,
                      "Financial Status",
                      widget.activityInstance.financialInformation != null
                          ? (widget.activityInstance.financialInformation!
                                      .status ==
                                  FinanceStatus.approved
                              ? "Approved"
                              : (widget.activityInstance.financialInformation!
                                          .status ==
                                      FinanceStatus.rejected
                                  ? "Rejected"
                                  : (widget.activityInstance
                                              .financialInformation!.status ==
                                          FinanceStatus.pending
                                      ? "Pending"
                                      : "Unknown")))
                          : "No Financial Info",
                      isStatus: true,
                    ),
                    if (widget.activityInstance.financialInformation != null &&
                        widget.activityInstance.financialInformation!
                                .status ==
                            FinanceStatus.rejected &&
                        widget.activityInstance.financialInformation!
                                .rejectionReason !=
                            null)
                      _buildDetailRow(
                          Icons.error_outline,
                          "Rejection Reason",
                          widget.activityInstance.financialInformation!
                              .rejectionReason!,
                          isStatus: false,
                          color: Colors.red),
                    if ((widget.activityInstance.financialInformation != null && campusAppsPortalInstance.isFinance) || 
                        (widget.activityInstance.financialInformation != null && campusAppsPortalInstance.isOperations && widget.activityInstance.financialInformation!.status != FinanceStatus.pending))
                      Column(
                        children: [
                          _buildDetailRow(
                              Icons.price_change_outlined,
                              "Estimated Cost",
                              "Rs. ${widget.activityInstance.financialInformation?.estimatedCost ?? 0}"),
                          _buildDetailRow(
                              Icons.calculate_outlined,
                              "Total Cost",
                              "Rs. ${widget.activityInstance.financialInformation?.totalCost ?? 0}"),
                        ],
                      ),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- Participants Section ---
                    const Text(
                      "Assigned Personnel",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          if (widget.activityInstance.activityParticipants !=
                              null)
                            ...widget.activityInstance.activityParticipants!
                                .map((participant) {
                              return Column(
                                children: [
                                  _buildParticipantRow(participant),
                                  const Divider(height: 1),
                                ],
                              );
                            }).toList()
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No participants assigned"),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save and Cancel Buttons
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Button(
                          label: _isSaving ? "Saving..." : "Save",
                          buttonColor: _isSaving ? Colors.grey : Colors.blue,
                          textColor: Colors.white,
                          height: 40,
                          fontSize: 14,
                          onPressed: () {
                            if (_isSaving) return;
                            _handleSave();
                          },
                        ),
                        Button(
                          label: "Cancel",
                          buttonColor: Colors.grey[300],
                          textColor: Colors.black87,
                          height: 40,
                          fontSize: 14,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.activityInstance.activityParticipants != null) {
        List<String> updateErrors = [];

        for (var participant in widget.activityInstance.activityParticipants!) {
          if (participant.person?.id != null && participant.status != null) {
            int personId = participant.person!.id!;
            ProgressStatus currentStatus = participant.status!;
            ProgressStatus? originalStatus =
                _originalParticipantStatuses[personId];

            if (originalStatus != currentStatus) {
              String status =
                  progressStatusToString(currentStatus).replaceAll(' ', '');

              try {
                await updateTaskStatus(
                  widget.activityInstance.id!,
                  personId,
                  status,
                );
                _originalParticipantStatuses[personId] = currentStatus;
              } catch (e) {
                updateErrors.add('${participant.person?.preferred_name}: $e');
              }
            }
          }
        }

        if (updateErrors.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to update status for:\n${updateErrors.join('\n')}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        // Check for actual changes for success message
        bool hasChanges = _originalParticipantStatuses.entries.any((entry) =>
            widget.activityInstance.activityParticipants!.any(
                (p) => p.person?.id == entry.key && p.status == entry.value));

        if (hasChanges && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task status updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      widget.onSave?.call();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  // Helper Widget for Rows
  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isStatus = false, Color? color,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ??
                    (isStatus
                        ? Colors.black
                        : Colors.black87),
                fontWeight:
                    isStatus ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Participants
  Widget _buildParticipantRow(ActivityParticipant participant) {
    final currentStatus = participant.status != null
        ? progressStatusToString(participant.status!)
        : "Pending";

    return ListTile(
      title: Text(participant.person?.preferred_name ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: ColourfulDropdown(
        value: currentStatus,
        items: const [
          DropdownMenuItem(
              value: "Pending",
              child: Text("Pending",
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold))),
          DropdownMenuItem(
              value: "In Progress",
              child: Text("In Progress",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold))),
          DropdownMenuItem(
              value: "Completed",
              child: Text("Completed",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold))),
        ],
        onChanged: (newStatus) {
          if (newStatus != null) {
            // Check financial status
            final financialStatus =
                widget.activityInstance.financialInformation?.status;
            if (financialStatus == FinanceStatus.pending ||
                financialStatus == FinanceStatus.rejected) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cannot Update Status"),
                  content: const Text(
                      "Financial details are not approved for this task."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              return;
            }
            setState(() {
              // Update participant status
              if (newStatus == "Pending") {
                participant.status = ProgressStatus.pending;
              } else if (newStatus == "In Progress") {
                participant.status = ProgressStatus.inProgress;
              } else if (newStatus == "Completed") {
                participant.status = ProgressStatus.completed;
              }
            });
          }
        },
        getColorForValue: (value) {
          if (value == "Completed") {
            return Colors.green;
          } else if (value == "In Progress") {
            return Colors.blue;
          } else {
            return Colors.orange;
          }
        },
      ),
    );
  }
}
