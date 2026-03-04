import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/date_picker.dart';
import '../widgets/common/button.dart';

/// Simple model representing an inspection task
class InspectionTask {
  final int id;
  final String description;
  final DateTime completedDate;
  final List<String> assignees;
  bool? inspected; // null = not yet reviewed, true = passed, false = failed

  InspectionTask({
    required this.id,
    required this.description,
    required this.completedDate,
    required this.assignees,
    this.inspected,
  });
}

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({Key? key}) : super(key: key);

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  DateTime _selectedDate = DateTime.now();
  List<InspectionTask> _allTasks = [];
  List<InspectionTask> _filteredTasks = [];

  // --- THEME CONSTANTS ---
  final Color _primaryText = const Color(0xFF172B4D);
  final Color _secondaryText = const Color(0xFF6B778C);
  final Color _bgLight = const Color(0xFFF4F5F7);
  final Color _accentBlue = const Color(0xFF0052CC);
  final Color _successGreen = const Color(0xFF36B37E);
  final Color _errorRed = const Color(0xFFDE350B);
  final double _cardRadius = 12.0;

  @override
  void initState() {
    super.initState();
    // Populate with dummy data spread across a few days
    final now = DateTime.now();
    _allTasks = List.generate(20, (i) {
      // Spread tasks across today, yesterday, and 2 days ago
      final daysAgo = i % 3;
      final date = DateTime(
        now.year,
        now.month,
        now.day - daysAgo,
        8 + (i % 9), // vary the hour
      );
      return InspectionTask(
        id: i + 1,
        description: _taskDescriptions[i % _taskDescriptions.length],
        completedDate: date,
        assignees: _generateAssignees(i),
      );
    });
    _filterTasks();
  }

  static const List<String> _taskDescriptions = [
    'Fire extinguisher pressure check',
    'HVAC filter replacement',
    'Emergency lighting test',
    'Boiler pressure inspection',
    'Roof drainage clearance',
    'Elevator safety inspection',
    'Electrical panel audit',
    'Plumbing leak inspection',
    'Security camera functionality',
    'Sprinkler system test',
  ];

  static const List<String> _assigneeNames = [
    'John Silva',
    'Maria Fernando',
    'David Perera',
    'Priya Jayasinghe',
    'Michael De Silva',
    'Sarah Wickramasinghe',
    'Robert Gunasekara',
    'Ayesha Rathnayake',
    'Kevin Mendis',
    'Nimal Rajapakse',
  ];

  static List<String> _generateAssignees(int taskIndex) {
    // Generate 2-4 assignees per task
    final numAssignees = (taskIndex % 3) + 2;
    final assignees = <String>[];
    for (int i = 0; i < numAssignees; i++) {
      final assigneeIndex = (taskIndex + i) % _assigneeNames.length;
      assignees.add(_assigneeNames[assigneeIndex]);
    }
    return assignees;
  }

  void _filterTasks() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        return DateUtils.isSameDay(task.completedDate, _selectedDate);
      }).toList();
    });
  }

  void _onDateSelected(String dateString) {
    // Parse the date string and update _selectedDate
    try {
      final DateTime? parsed = DateTime.tryParse(dateString);
      if (parsed != null) {
        setState(() {
          _selectedDate = parsed;
        });
        _filterTasks();
      }
    } catch (e) {
      // Handle parsing error
      print('Error parsing date: $e');
    }
  }

  void _setInspectionResult(InspectionTask task, bool passed) {
    setState(() {
      task.inspected = passed;
    });
  }

  Color _statusColor(bool? inspected) {
    if (inspected == null) return _secondaryText;
    return inspected ? _successGreen : _errorRed;
  }

  int get _pendingCount =>
      _filteredTasks.where((t) => t.inspected == null).length;
  int get _passedCount =>
      _filteredTasks.where((t) => t.inspected == true).length;
  int get _failedCount =>
      _filteredTasks.where((t) => t.inspected == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: LayoutBuilder(
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

                    // --- 3. TASK LIST ---
                    _buildTaskList(),
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
            child: CustomDatePicker(
              label: "Completed Date",
              selectedDateString:
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
              onDateSelected: _onDateSelected,
              initialDate: _selectedDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(bool isMobile) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: _buildStatCard(
            'Total Tasks', _filteredTasks.length.toString(), _accentBlue),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color accentColor) {
    return StatCard(
      title: title,
      value: value,
      accentColor: accentColor,
      primaryText: _primaryText,
      secondaryText: _secondaryText,
      cardRadius: _cardRadius,
    );
  }

  Widget _buildTaskList() {
    if (_filteredTasks.isEmpty) {
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

          // Task list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredTasks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = _filteredTasks[index];
              return _TaskListItem(
                task: task,
                onPass: () => _setInspectionResult(task, true),
                onFail: () => _setInspectionResult(task, false),
                onReset: () => setState(() => task.inspected = null),
                statusColor: _statusColor(task.inspected),
                primaryText: _primaryText,
                secondaryText: _secondaryText,
                successColor: _successGreen,
                errorColor: _errorRed,
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
}

// ──────────────────────────────────────────────────────────────────────────────
// Task List Item Widget
// ──────────────────────────────────────────────────────────────────────────────

class _TaskListItem extends StatefulWidget {
  final InspectionTask task;
  final VoidCallback onPass;
  final VoidCallback onFail;
  final VoidCallback onReset;
  final Color statusColor;
  final Color primaryText;
  final Color secondaryText;
  final Color successColor;
  final Color errorColor;

  const _TaskListItem({
    required this.task,
    required this.onPass,
    required this.onFail,
    required this.onReset,
    required this.statusColor,
    required this.primaryText,
    required this.secondaryText,
    required this.successColor,
    required this.errorColor,
  });

  @override
  State<_TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<_TaskListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('h:mm a').format(widget.task.completedDate);
    final isReviewed = widget.task.inspected != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => _showTaskDetailsDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _isHovered ? const Color(0xFFF4F5F7) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.primaryText.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Task #${widget.task.id}',
                            style: TextStyle(
                              color: widget.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 14, color: widget.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: widget.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14, color: widget.secondaryText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.task.assignees.join(', '),
                            style: TextStyle(
                              color: widget.secondaryText,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isReviewed) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            widget.task.inspected!
                                ? Icons.check_circle
                                : Icons.error,
                            size: 16,
                            color: widget.statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.task.inspected!
                                ? 'Inspection Passed'
                                : 'Inspection Failed',
                            style: TextStyle(
                              color: widget.statusColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Undo button
                          InkWell(
                            onTap: widget.onReset,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: widget.secondaryText,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Action buttons
              if (!isReviewed)
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onPass,
                      icon: Icon(Icons.check, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: widget.successColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                      tooltip: 'Mark as passed',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onFail,
                      icon: Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: widget.errorColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                      tooltip: 'Mark as failed',
                    ),
                  ],
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: widget.statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    widget.task.inspected! ? Icons.check : Icons.close,
                    color: widget.statusColor,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _InspectionTaskDetailsDialog(
        task: widget.task,
        onPass: widget.onPass,
        onFail: widget.onFail,
        onReset: widget.onReset,
        successColor: widget.successColor,
        errorColor: widget.errorColor,
        primaryText: widget.primaryText,
        secondaryText: widget.secondaryText,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Inspection Task Details Dialog
// ──────────────────────────────────────────────────────────────────────────────

class _InspectionTaskDetailsDialog extends StatelessWidget {
  final InspectionTask task;
  final VoidCallback onPass;
  final VoidCallback onFail;
  final VoidCallback onReset;
  final Color successColor;
  final Color errorColor;
  final Color primaryText;
  final Color secondaryText;

  const _InspectionTaskDetailsDialog({
    required this.task,
    required this.onPass,
    required this.onFail,
    required this.onReset,
    required this.successColor,
    required this.errorColor,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('h:mm a').format(task.completedDate);
    final dateLabel = DateFormat('MMMM d, yyyy').format(task.completedDate);
    final isReviewed = task.inspected != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task #${task.id} Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Task Details
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        Icons.description, 'Description', task.description),
                    _buildDetailRow(
                        Icons.calendar_today, 'Completion Date', dateLabel),
                    _buildDetailRow(
                        Icons.access_time, 'Completion Time', timeLabel),
                    _buildDetailRow(
                        Icons.people, 'Assignees', task.assignees.join(', ')),
                    if (isReviewed)
                      _buildDetailRow(
                        task.inspected! ? Icons.check_circle : Icons.error,
                        'Inspection Status',
                        task.inspected! ? 'Passed' : 'Failed',
                        statusColor:
                            task.inspected! ? successColor : errorColor,
                      ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (!isReviewed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              onPass();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: successColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            tooltip: 'Mark as passed',
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              onFail();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: errorColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            tooltip: 'Mark as failed',
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  (task.inspected! ? successColor : errorColor)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (task.inspected!
                                        ? successColor
                                        : errorColor)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.inspected! ? Icons.check : Icons.close,
                                  color: task.inspected!
                                      ? successColor
                                      : errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  task.inspected!
                                      ? 'Inspection Passed'
                                      : 'Inspection Failed',
                                  style: TextStyle(
                                    color: task.inspected!
                                        ? successColor
                                        : errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              onReset();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Reset Inspection',
                              style: TextStyle(color: secondaryText),
                            ),
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

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: statusColor ?? secondaryText),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: statusColor ?? primaryText,
                fontWeight:
                    statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
