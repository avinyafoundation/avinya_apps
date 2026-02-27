import 'package:flutter/material.dart';
import 'package:attendance/data.dart';
import 'package:attendance/data/evaluation.dart';
import 'package:attendance/data/activity_instance.dart';

class AbsenceReasonDialog extends StatefulWidget {
  final Person person;
  final Evaluation? evaluation;
  final int activityId;
  final ActivityInstance activityInstance;
  final Function(ActivityInstance, Evaluation?) onEvaluationSaved;

  const AbsenceReasonDialog({
    Key? key,
    required this.person,
    this.evaluation,
    required this.activityId,
    required this.activityInstance,
    required this.onEvaluationSaved,
  }) : super(key: key);

  @override
  _AbsenceReasonDialogState createState() => _AbsenceReasonDialogState();
}

class _AbsenceReasonDialogState extends State<AbsenceReasonDialog> {
  late String selectedReason;
  late String notes;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    selectedReason = widget.evaluation?.response ?? 'Unexcused absence';
    notes = widget.evaluation?.notes ?? '';
    notesController = TextEditingController(text: notes);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_off,
                  color: const Color(0xFF1BB6E8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.evaluation != null
                        ? 'Edit Absence Reason'
                        : 'Add Absence Reason',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  color: const Color(0xFF6C757D),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  splashRadius: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Student: ${widget.person.preferred_name}',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 24),

            // Absence Reason Dropdown
            Text(
              'Absence Reason',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE0E6ED)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                underline: SizedBox.shrink(),
                icon: Icon(Icons.arrow_drop_down, color: Color(0xFF6C757D)),
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
                items: [
                  'Unexcused absence',
                  'Illness',
                  'Medical appointment',
                  'Family emergency',
                  'Bereavement',
                  'Mental health',
                  'Religious observance',
                  'School-related activities',
                  'Personal or family vacation',
                  'Transportation issues',
                  'Weather-related issues',
                  'Suspensions or disciplinary actions',
                  'Lack of parental supervision or support',
                  'Childcare responsibilities',
                  'Work or financial commitments',
                  'Educational neglect',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedReason = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Notes Field
            Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add additional notes...',
                hintStyle: TextStyle(
                  color: Color(0xFF6C757D),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFE0E6ED)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF1BB6E8)),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      var newActivityInstance = widget.activityInstance;

                      // Check if activity instance is valid, if not fetch checkin activity instance
                      if (newActivityInstance.id == -1) {
                        newActivityInstance =
                            await campusAttendanceSystemInstance
                                .getCheckinActivityInstance(widget.activityId);
                      }

                      if (widget.evaluation != null) {
                        // Update existing evaluation
                        widget.evaluation!.activity_instance_id =
                            newActivityInstance.id;
                        widget.evaluation!.response = selectedReason;
                        widget.evaluation!.notes =
                            notesController.text.isNotEmpty
                                ? notesController.text
                                : null;

                        await updateEvaluation(widget.evaluation!);
                      } else {
                        // Create new evaluation
                        var newEvaluation = Evaluation(
                          evaluator_id:
                              campusAppsPortalInstance.getUserPerson().id,
                          evaluatee_id: widget.person.id,
                          activity_instance_id: newActivityInstance.id,
                          grade: 0,
                          evaluation_criteria_id: 54,
                          response: selectedReason,
                          notes: notesController.text.isNotEmpty
                              ? notesController.text
                              : null,
                        );

                        await createEvaluation([newEvaluation]);
                      }

                      // Call callback to notify parent
                      await widget.onEvaluationSaved(
                          newActivityInstance, widget.evaluation);

                      // Return the selected response and notes so callers can update UI immediately
                      Navigator.pop(context, {
                        'response':
                            widget.evaluation?.response ?? selectedReason,
                        'notes': widget.evaluation?.notes ??
                            (notesController.text.isNotEmpty
                                ? notesController.text
                                : null),
                      });
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.evaluation != null
                              ? 'Failed to update absence reason'
                              : 'Failed to add absence reason'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1BB6E8),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.evaluation != null ? 'Update Reason' : 'Add Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
