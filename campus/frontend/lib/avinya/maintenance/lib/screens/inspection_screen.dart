import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common/page_title.dart';
import '../widgets/task_details_dialog.dart';
import '../data/activity_instance.dart';
import '../data/activity_participant.dart';
import '../data/person.dart';
import '../data/maintenance_task.dart';
import 'package:gallery/config/app_config.dart';
import 'package:gallery/data/campus_apps_portal.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({Key? key}) : super(key: key);

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  DateTime _selectedDate = DateTime.now();
  List<ActivityInstance> _allActivities = [];
  List<ActivityInstance> _filteredActivities = [];
  bool _isLoading = true;

  // --- THEME CONSTANTS ---
  final Color _primaryText = const Color(0xFF172B4D);
  final Color _secondaryText = const Color(0xFF6B778C);
  final Color _bgLight = const Color(0xFFF4F5F7);
  final Color _accentBlue = const Color(0xFF0052CC);
  final Color _successGreen = const Color(0xFF36B37E);
  final Color _warningOrange = const Color(0xFFFFA500);
  final double _cardRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      // Use mock data for testing
      setState(() {
        _allActivities = _generateMockActivities();
        _isLoading = false;
      });
      _filterActivities();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activities: $e')),
        );
      }
    }
  }

  List<ActivityInstance> _generateMockActivities() {
    final now = DateTime.now();
    final mockParticipants = [
      'John Silva',
      'Maria Fernando',
      'David Perera',
      'Priya Jayasinghe',
      'Michael De Silva',
    ];

    final mockTasks = [
      {
        'title': 'Fire Extinguisher Inspection',
        'description':
            'Check pressure and expiration dates of all fire extinguishers',
        'location': 'Main Building'
      },
      {
        'title': 'HVAC Filter Replacement',
        'description': 'Replace HVAC filters in all zones',
        'location': 'Building A'
      },
      {
        'title': 'Emergency Lighting Test',
        'description': 'Test all emergency lighting systems',
        'location': 'Entire Campus'
      },
      {
        'title': 'Roof Drainage Clearance',
        'description': 'Clear debris from roof drains',
        'location': 'Rooftop'
      },
      {
        'title': 'Electrical Panel Audit',
        'description': 'Inspect and document electrical panel conditions',
        'location': 'Basement'
      },
    ];

    List<ActivityInstance> activities = [];
    int id = 1;

    for (var i = 0; i < 8; i++) {
      final daysAgo = i ~/ 2; // Spread across past few days
      final completionDate = DateTime(
        now.year,
        now.month,
        now.day - daysAgo,
        9 + (i % 6), // Vary the hour
      );

      final taskData = mockTasks[i % mockTasks.length];

      // Create participants with mixed statuses
      final numParticipants = (i % 3) + 2; // 2-4 participants per task
      final participants = <ActivityParticipant>[];

      for (int p = 0; p < numParticipants; p++) {
        // Mix of completed and pending statuses
        final isCompleted = p < (numParticipants ~/ 2) + (i % 2);

        participants.add(
          ActivityParticipant(
            id: id + p,
            person: Person(
              id: id + p,
              preferred_name:
                  mockParticipants[(i + p) % mockParticipants.length],
            ),
            status: isCompleted
                ? ProgressStatus.completed
                : ProgressStatus.inProgress,
          ),
        );
      }

      activities.add(
        ActivityInstance(
          id: id,
          activity_id: i + 1,
          name: taskData['title'],
          description: taskData['description'],
          end_time:
              '${completionDate.year}-${completionDate.month.toString().padLeft(2, '0')}-${completionDate.day.toString().padLeft(2, '0')} ${completionDate.hour.toString().padLeft(2, '0')}:00:00',
          activityParticipants: participants,
          maintenanceTask: MaintenanceTask(
            id: i + 1,
            title: taskData['title']!,
            description: taskData['description'],
          ),
          overallTaskStatus: i % 3 == 0
              ? 'completed'
              : (i % 3 == 1 ? 'inprogress' : 'pending'),
        ),
      );

      id += numParticipants + 1;
    }

    return activities;
  }

  void _filterActivities() {
    setState(() {
      // Filter activities where at least one participant has marked task as completed
      // on the selected date
      _filteredActivities = _allActivities.where((activity) {
        if (activity.activityParticipants == null ||
            activity.activityParticipants!.isEmpty) {
          return false;
        }

        // Check if any participant has completed status and the end_time matches the selected date
        return activity.activityParticipants!.any((participant) {
          if (participant.status == null) return false;

          // Parse end_time to check if it matches selected date
          if (activity.end_time == null) return false;

          try {
            final completionDate = DateTime.parse(activity.end_time!);
            return participant.status.toString() ==
                    'ProgressStatus.completed' &&
                DateUtils.isSameDay(completionDate, _selectedDate);
          } catch (e) {
            return false;
          }
        });
      }).toList();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _filterActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth <= 800;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. HEADER ---
                          _buildHeader(isMobile),
                          const SizedBox(height: 20),

                          // --- 2. DATE SELECTOR ---
                          _buildDateSelector(),
                          const SizedBox(height: 20),

                          // --- 3. ACTIVITY LIST ---
                          _buildActivityList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: PageTitle(
            title: "Task Inspection",
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: _primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF6B778C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _onDateSelected(picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  DateFormat('MMMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: _primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_filteredActivities.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: PageTitle(
              title:
                  "Tasks for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _primaryText,
            ),
          ),
          const Divider(height: 1),

          // Activity list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredActivities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = _filteredActivities[index];
              return _ActivityListItem(
                activity: activity,
                onTap: () => _showActivityDetailsDialog(context, activity),
                onTaskStatusChanged: (status) =>
                    _updateTaskStatus(activity, status),
                primaryText: _primaryText,
                secondaryText: _secondaryText,
                successColor: _successGreen,
                warningColor: _warningOrange,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: _secondaryText.withOpacity(0.5)),
            const SizedBox(height: 16),
            PageTitle(
              title: "No tasks found",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _primaryText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks were completed on ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
              style: TextStyle(color: _secondaryText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsDialog(
      BuildContext context, ActivityInstance activity) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(
        activityInstance: activity,
        onSave: () {
          _loadActivities(); // Refresh the list after save
        },
      ),
    );
  }

  void _updateTaskStatus(ActivityInstance activity, String newStatus) {
    setState(() {
      activity.overallTaskStatus = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task status updated to $newStatus'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Activity List Item Widget
// ──────────────────────────────────────────────────────────────────────────────

class _ActivityListItem extends StatefulWidget {
  final ActivityInstance activity;
  final VoidCallback onTap;
  final Function(String) onTaskStatusChanged;
  final Color primaryText;
  final Color secondaryText;
  final Color successColor;
  final Color warningColor;

  const _ActivityListItem({
    required this.activity,
    required this.onTap,
    required this.onTaskStatusChanged,
    required this.primaryText,
    required this.secondaryText,
    required this.successColor,
    required this.warningColor,
  });

  @override
  State<_ActivityListItem> createState() => _ActivityListItemState();
}

class _ActivityListItemState extends State<_ActivityListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final taskTitle = widget.activity.maintenanceTask?.title ?? "Unknown Task";
    final participants = widget.activity.activityParticipants ?? [];

    // Count completed and pending statuses
    final completedCount = participants
        .where((p) => p.status.toString() == 'ProgressStatus.completed')
        .length;
    final totalCount = participants.length;

    // Get partially completed status
    final hasPartialCompletion =
        completedCount > 0 && completedCount < totalCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _isHovered ? const Color(0xFFF4F5F7) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator bar
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: hasPartialCompletion
                      ? widget.warningColor
                      : widget.successColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Activity info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            taskTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: widget.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildCompletionBadge(
                          completedCount,
                          totalCount,
                          hasPartialCompletion,
                        ),
                        const SizedBox(width: 12),
                        _buildTaskStatusDropdown(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Description
                    if (widget.activity.maintenanceTask?.description != null)
                      Text(
                        widget.activity.maintenanceTask!.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Participants list
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: participants.take(3).map((participant) {
                        final isCompleted = participant.status.toString() ==
                            'ProgressStatus.completed';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? widget.successColor.withOpacity(0.15)
                                : widget.secondaryText.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isCompleted
                                  ? widget.successColor.withOpacity(0.3)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                Icon(
                                  Icons.check,
                                  size: 12,
                                  color: widget.successColor,
                                )
                              else
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: widget.secondaryText,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                participant.person?.preferred_name ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.primaryText,
                                  fontWeight: isCompleted
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (participants.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${participants.length - 3} more',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(
    int completed,
    int total,
    bool isPartial,
  ) {
    String label = isPartial ? '$completed/$total Completed' : 'Completed';
    Color bgColor = isPartial
        ? widget.warningColor.withOpacity(0.15)
        : widget.successColor.withOpacity(0.15);
    Color textColor = isPartial ? widget.warningColor : widget.successColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTaskStatusDropdown() {
    final currentStatus = widget.activity.overallTaskStatus ?? 'pending';
    final statusOptions = ['pending', 'inprogress', 'completed'];

    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newStatus) {
        if (newStatus != null) {
          setState(() {
            widget.activity.overallTaskStatus = newStatus;
          });
          widget.onTaskStatusChanged(newStatus);
        }
      },
      items: statusOptions.map((status) {
        Color statusColor;
        IconData statusIcon;
        String displayLabel;

        switch (status) {
          case 'pending':
            statusColor = Colors.orange;
            statusIcon = Icons.pending_actions;
            displayLabel = 'Pending';
            break;
          case 'inprogress':
            statusColor = Colors.blue;
            statusIcon = Icons.hourglass_top;
            displayLabel = 'In Progress';
            break;
          case 'completed':
            statusColor = widget.successColor;
            statusIcon = Icons.check_circle;
            displayLabel = 'Completed';
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help;
            displayLabel = status;
        }

        return DropdownMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      underline: Container(),
      isDense: true,
    );
  }
}
