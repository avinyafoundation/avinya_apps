import 'package:flutter/material.dart';
import 'package:attendance/data/evaluation.dart';

class DeleteAbsenceReasonDialog extends StatelessWidget {
  final Evaluation evaluation;
  final Function(Evaluation) onEvaluationDeleted;

  const DeleteAbsenceReasonDialog({
    Key? key,
    required this.evaluation,
    required this.onEvaluationDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 400,
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
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFE74C3C),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delete Absence Reason',
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
            const SizedBox(height: 16),

            Text(
              'Are you sure you want to delete this absence reason? This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
                height: 1.5,
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
                      await deleteEvaluation(evaluation.id!.toString());
                      await onEvaluationDeleted(evaluation);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete absence reason'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Delete',
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
