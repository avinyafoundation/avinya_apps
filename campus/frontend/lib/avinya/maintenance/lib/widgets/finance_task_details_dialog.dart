import 'package:flutter/material.dart';
import '../data/activity_instance.dart';
import '../data/material_cost.dart';
import '../data/maintenance_finance.dart';
import 'common/button.dart';
import 'package:gallery/data/campus_apps_portal.dart';

class FinanceTaskDetailsDialog extends StatefulWidget {
  final ActivityInstance activityInstance;
  final VoidCallback? onApprove;

  const FinanceTaskDetailsDialog(
      {super.key, required this.activityInstance, this.onApprove});

  @override
  State<FinanceTaskDetailsDialog> createState() =>
      _FinanceTaskDetailsDialogState();
}

class _FinanceTaskDetailsDialogState extends State<FinanceTaskDetailsDialog> {
  final Color _approveGreen = const Color(0xFF36B37E);
  final Color _rejectRed = const Color(0xFFFF5630);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600
        ? screenWidth * 0.9 // 90% width on mobile
        : (screenWidth < 1200
            ? 500.0 // 500px on tablets
            : 700.0); // 700px on desktop

    final financialInfo = widget.activityInstance.financialInformation;
    final materialCosts = financialInfo?.materialCosts ?? [];
    final totalCost = financialInfo?.totalCost ?? 0.0;

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
                  widget.activityInstance.maintenanceTask?.title ??
                      'Task Details',
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
                    _buildDetailRow(
                        Icons.calendar_today,
                        "Start Date",
                        DateTime.parse(widget.activityInstance.start_time!)
                            .toLocal()
                            .toString()
                            .split(' ')[0]),
                    _buildDetailRow(
                        Icons.calendar_today,
                        "End Date",
                        DateTime.parse(widget.activityInstance.end_time!)
                            .toLocal()
                            .toString()
                            .split(' ')[0]),
                    _buildDetailRow(Icons.attach_money, "Estimated Cost",
                        "Rs. ${financialInfo?.estimatedCost?.toStringAsFixed(2) ?? '0.00'}"),
                    _buildDetailRow(Icons.calculate_outlined, "Labour Cost",
                        "Rs. ${financialInfo?.labourCost?.toStringAsFixed(2) ?? '0.00'}"),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- Material Costs Section ---
                    const Text(
                      "Material Costs",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: materialCosts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No material costs listed"),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Item')),
                                  DataColumn(label: Text('Quantity')),
                                  DataColumn(label: Text('Unit')),
                                  DataColumn(label: Text('Unit Cost')),
                                  DataColumn(label: Text('Total')),
                                ],
                                rows: materialCosts.map((cost) {
                                  final quantity = cost.quantity ?? 0;
                                  final unitCost = cost.unitCost ?? 0;
                                  final total = quantity * unitCost;
                                  return DataRow(cells: [
                                    DataCell(Text(cost.item ?? 'N/A')),
                                    DataCell(Text(quantity.toString())),
                                    DataCell(Text(cost.unit != null
                                        ? unitToString(cost.unit!)
                                        : 'N/A')),
                                    DataCell(Text(
                                        'Rs. ${unitCost.toStringAsFixed(2)}')),
                                    DataCell(Text(
                                        'Rs. ${total.toStringAsFixed(2)}')),
                                  ]);
                                }).toList(),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- Total Cost ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            'Total Cost: Rs. ${totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Approve, Reject Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          label: "Approve",
                          onPressed: () =>
                              _handleApprove(widget.activityInstance),
                          buttonColor: _approveGreen,
                          textColor: Colors.white,
                          height: 32,
                          fontSize: 13,
                        ),
                        const SizedBox(width: 8),
                        Button(
                          label: "Reject",
                          onPressed: () =>
                              _handleReject(widget.activityInstance),
                          buttonColor: _rejectRed,
                          textColor: Colors.white,
                          height: 32,
                          fontSize: 13,
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

      // 3. Notify parent to update UI
      widget.onApprove?.call();

      // 4. Show Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "'${instance.maintenanceTask?.title}' Approved Successfully"),
          ),
        );
        Navigator.of(context).pop(); // Close dialog after approval
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Task Rejected: $reason"),
          ),
        );
        Navigator.of(context).pop(); // Close dialog after rejection
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error rejecting task: $e"),
          ),
        );
      }
    }
  }

  // Helper Widget for Rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
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
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
