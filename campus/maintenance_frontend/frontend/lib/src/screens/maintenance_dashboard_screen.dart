import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../data/activity_attendance.dart';
import '../data/task_item.dart';
import 'kanban_screen.dart';


enum DashboardView { management, teacher }

class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _MaintenanceDashboardScreenState createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends State<MaintenanceDashboardScreen> with TickerProviderStateMixin {
  // --- Environment Configuration ---
  static const String _roleEnvironment = String.fromEnvironment('ROLE', defaultValue: '');
  static final bool _roleFixed = _roleEnvironment.isNotEmpty;
  
  // --- View Mode ---
  late DashboardView _currentView;
  bool _viewSelected = false; // whether the startup picker has been dismissed

  // --- Data States ---
  bool _isFetching = true;
  List<dynamic> _fetchedPieChartData = [];
  List<Map<String, dynamic>> _classData = [];
  List<Map<String, dynamic>> _staffTaskSummaries = [];
  Set<int> _overduePersonIds = {};
  Set<int> _overdueTaskActivityIds = {}; // Store activity IDs of overdue tasks
  List<Map<String, dynamic>> _lateAttendanceData = [];

  // Stores full task details per person: personId -> list of task maps
  Map<int, List<Map<String, dynamic>>> _staffTaskDetails = {};
  
  // Dynamic attendance data for Teacher View
  List<Map<String, dynamic>> _bestAttendanceStudents = [];
  List<Map<String, dynamic>> _worstAttendanceStudents = [];
  String _attendanceFromDate = '2026-01-01';
  String _attendanceToDate = '';

  // Food waste data
  List<Map<String, dynamic>> _foodWasteData = [];

  Timer? _blinkTimer;
  bool _blinkOn = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // For view switch animation
  late AnimationController _viewSwitchController;
  late Animation<double> _viewSwitchAnimation;

  int totalStudentCount = 0;
  int totalAttendance = 0;
  String? _hoveredPieSegment;

  Timer? _clockTimer;
  Timer? _autoRefreshTimer;
  DateTime _now = DateTime.now();
  DateTime? _lastAutoRefresh;

  // Light theme palette
  static const Color _primary   = Color(0xFF1BB6E8);
  static const Color _bgPage    = Color(0xFFF0F4F8);
  static const Color _bgCard    = Colors.white;
  static const Color _textDark  = Color(0xFF1A2B3C);
  static const Color _textMid   = Color(0xFF5A7184);
  static const Color _textLight = Color(0xFF8EA8BC);
  static const Color _green     = Color(0xFF27AE60);
  static const Color _red       = Color(0xFFD32F2F);
  static const Color _orange    = Color(0xFFFFC107);
  static const Color _divider   = Color(0xFFE4EBF0);

  @override
  void initState() {
    super.initState();

    // Initialize view based on ROLE environment variable
    if (_roleFixed) {
      _currentView = _roleEnvironment.toLowerCase() == 'teacher'
          ? DashboardView.teacher
          : DashboardView.management;
      _viewSelected = true; // Skip picker if role is fixed
    } else {
      _currentView = DashboardView.management;
    }

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

    _viewSwitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _viewSwitchAnimation = CurvedAnimation(
      parent: _viewSwitchController,
      curve: Curves.easeInOut,
    );
    _viewSwitchController.forward();

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (!mounted) return;
      setState(() => _blinkOn = !_blinkOn);
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });

    _startAutoRefreshTimer();
    _loadAllDashboardData();

    // Show view picker on first launch only if role is not fixed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_roleFixed) _showViewPickerDialog();
    });
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAutoRefresh();
    });
  }

  void _checkAutoRefresh() {
    final now = DateTime.now();
    final minute = now.minute;
    final hour = now.hour;
    // generate times
    bool shouldRefresh = false;
    // between 7:15 and 8:15, refresh every 3 minutes (inclusive)
    if ((hour == 7 && minute >= 15) || (hour == 8 && minute <= 30)) {
      final totalMinutes = hour * 60 + minute;
      final start = 7 * 60 + 15; // 7:15 in minutes
      if ((totalMinutes - start) % 3 == 0) {
        shouldRefresh = true;
      }
    }
    // fixed checkpoints around breakfast hours
    if (hour == 8 && minute == 33) shouldRefresh = true;
    if (hour == 8 && minute == 45) shouldRefresh = true;
    if (hour == 9 && (minute == 0 || minute == 30)) shouldRefresh = true;
    if (hour == 10 && minute == 0) shouldRefresh = true;
    // thereafter, on the hour every hour from 10am through 6am next day
    if ((hour >= 10 || hour < 7) && minute == 0) {
      shouldRefresh = true;
    }

    if (shouldRefresh) {
      // avoid repeated in same minute
      if (_lastAutoRefresh == null ||
          now.difference(_lastAutoRefresh!).inMinutes >= 1) {
        _lastAutoRefresh = now;
        _loadAllDashboardData(silent: true);
      }
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _clockTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _glowController.dispose();
    _viewSwitchController.dispose();
    super.dispose();
  }

  void _switchView(DashboardView view) {
    if (view == _currentView) return;
    _viewSwitchController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentView = view);
      _viewSwitchController.forward();
    });
  }

  // ─────────────────────────────────────────────
  //  Startup View Picker Dialog
  // ─────────────────────────────────────────────
  void _showViewPickerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon + title
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.dashboard_rounded,
                      color: _primary, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose Your View',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select the dashboard view that matches your role.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textMid),
                ),
                const SizedBox(height: 28),

                // Management option
                _viewPickerOption(
                  ctx: ctx,
                  icon: Icons.business_center_rounded,
                  title: 'Management View',
                  color: _primary,
                  view: DashboardView.management,
                ),
                const SizedBox(height: 12),

                // Teacher option
                _viewPickerOption(
                  ctx: ctx,
                  icon: Icons.school_rounded,
                  title: 'Teacher View',
                  color: _green,
                  view: DashboardView.teacher,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewPickerOption({
    required BuildContext ctx,
    required IconData icon,
    required String title,
    required Color color,
    required DashboardView view,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(ctx).pop();
          setState(() {
            _currentView = view;
            _viewSelected = true;
          });
          _viewSwitchController.forward(from: 0);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color)),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic ---
  Future<void> _loadAllDashboardData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isFetching = true);
    try {
      _fetchedPieChartData = await getDailyStudentsAttendanceByParentOrg(2);

      // fetch late attendance for today's date
      final rawLateData = await getLateAttendanceSummary(2, 4);
      final List<Color> palette = [
        const Color(0xFF2ECC71),
        const Color(0xFF3498DB),
        const Color(0xFFF39C12),
        const Color(0xFFE67E22),
        const Color(0xFFE74C3C),
      ];
      final Map<String, Color> colorByLabel = {
        'Before 07:30': palette[0],
        '07:30 - 07:45': palette[1],
        '07:45 - 08:00': palette[2],
        '08:00 - 08:30': palette[3],
        'After 08:30': palette[4],
      };
      _lateAttendanceData = rawLateData.map<Map<String, dynamic>>((item) {
        final label = item['label'] as String? ?? '';
        final rawNames = item['student_name'] as String? ?? '';
        final List<String> students = rawNames
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        return {
          'label': label,
          'value': item['student_count'] as int? ?? 0,
          'color': colorByLabel[label] ??
              palette[_lateAttendanceData.length % palette.length],
          'students': students,
        };
      }).toList();

      if (!mounted) return;
      totalStudentCount = calculateTotalStudentCount(_fetchedPieChartData);
      totalAttendance   = calculateTotalAttendance(_fetchedPieChartData);
      _loadClassWiseData();
      await _fetchClassAttendanceRanking();
      await _fetchStaffTaskSummaries();
      await _fetchAttendanceRanking();
      await _fetchFoodWasteData();
    } catch (error) {
      print('Dashboard Load Error: $error');
    } finally {
      if (mounted && !silent) setState(() => _isFetching = false);
    }
  }

  Future<void> _fetchStaffTaskSummaries() async {
    _overduePersonIds.clear();
    _overdueTaskActivityIds.clear();
    _staffTaskDetails.clear();

    try {
      List<dynamic> overdueTasks = await getOverdueTasks(2);
      if (mounted) {
        for (var task in overdueTasks) {
          final activityId = task['id'] as int?;
          if (activityId != null) {
            _overdueTaskActivityIds.add(activityId);
          }
          final participants = task['activity_participants'] as List<dynamic>;
          for (var p in participants) {
            _overduePersonIds.add(p['person']['id'] as int);
          }
        }
      }
    } catch (e) {
      print('Error fetching overdue tasks: $e');
    }

// fetch pending and in-progress separately to reduce payload
    // include a seven‑day toDate window for both requests
    final DateTime sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    List<dynamic> pendingTasks = await getOrganizationTasksByStatus(
        2, 'Pending', toDate: sevenDaysFromNow, limit: 1000);
    List<dynamic> inProgressTasks = await getOrganizationTasksByStatus(
        2, 'InProgress', toDate: sevenDaysFromNow, limit: 1000);
    if (!mounted) return;

    List<dynamic> tasks = [];
    tasks.addAll(pendingTasks);
    tasks.addAll(inProgressTasks);

    Map<int, Map<String, dynamic>> staffTaskMap = {};
    for (var task in tasks) {
      final activityParticipants = task['activity_participants'] as List<dynamic>;
      // Extract task info from nested task object
      final taskObj = task['task'] as Map<String, dynamic>? ?? {};
      final String taskTitle       = taskObj['title'] as String? ?? 'Untitled Task';
      final String? taskDescription = taskObj['description'] as String?;
      final String? taskEndTime    = task['end_time'] as String?;
      final String? taskStartTime  = task['start_time'] as String?;

      for (var participant in activityParticipants) {
        final personId   = participant['person']['id'] as int;
        final personName = participant['person']['preferred_name'] as String;
        final status     = participant['participant_task_status'] as String;
        if (!staffTaskMap.containsKey(personId)) {
          staffTaskMap[personId] = {
            'personId': personId,
            'name':     personName,
            'pending':  0,
            'progress': 0,
          };
          _staffTaskDetails[personId] = [];
        }
        if (status == 'Pending') {
          staffTaskMap[personId]!['pending'] = (staffTaskMap[personId]!['pending'] as int) + 1;
        } else if (status == 'InProgress') {
          staffTaskMap[personId]!['progress'] = (staffTaskMap[personId]!['progress'] as int) + 1;
        }

        // Store task detail for the popup with correct field names
        _staffTaskDetails[personId]!.add({
          'id':          task['id'], // Store activity ID for overdue check
          'title':       taskTitle,
          'status':      status,
          'due_date':    taskEndTime,
          'description': taskDescription,
        });
      }
    }

    _staffTaskSummaries = staffTaskMap.values
        .where((s) => (s['pending'] as int) > 0 || (s['progress'] as int) > 0)
        .toList();
  }

  Future<void> _fetchAttendanceRanking() async {
    try {
      final now = DateTime.now();
      final fromDate = '2026-01-01';
      final toDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final bestStudents = await getAttendanceRanking(
        organizationId: 46,
        sort: 'DESC',
        fromDate: fromDate,
        toDate: toDate,
        limit: 120,
      );
      final worstStudents = await getAttendanceRanking(
        organizationId: 46,
        sort: 'ASC',
        fromDate: fromDate,
        toDate: toDate,
        limit: 120,
      );
      
      if (mounted) {
        setState(() {
          _bestAttendanceStudents = bestStudents;
          _worstAttendanceStudents = worstStudents;
          _attendanceFromDate = fromDate;
          _attendanceToDate = toDate;
        });
      }
    } catch (e) {
      print('Error fetching attendance ranking: $e');
    }
  }

  Future<void> _fetchClassAttendanceRanking() async {
    try {
      final now = DateTime.now();
      final fromDate = '2026-01-01';
      final toDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final ranks = await getClassAttendanceRanking(
        organizationId: 46,
        sort: 'DESC',
        fromDate: fromDate,
        toDate: toDate,
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          if (_classData.isNotEmpty && ranks.isNotEmpty) {
            for (var classItem in _classData) {
              double? foundPercentage;
              for (var rank in ranks) {
                if (rank['id'] == classItem['organizationId']) {
                  foundPercentage = rank['attendance_percentage'] as double;
                  break;
                }
              }
              classItem['attendance_percentage'] = foundPercentage ?? 0.0;
            }
            _classData.sort((a, b) => (b['attendance_percentage'] as double).compareTo(a['attendance_percentage'] as double));
          }
        });
      }
    } catch (e) {
      print('Error fetching class attendance ranking: $e');
    }
  }

  Future<void> _fetchFoodWasteData() async {
    try {
      final wasteDataRaw = await getFoodWasteData(2, 7);
      if (mounted) {
        setState(() {
          // Reverse the data so oldest date appears first
          final reversedData = wasteDataRaw.reversed.toList();
          _foodWasteData = reversedData.map<Map<String, dynamic>>((item) {
            final dateStr = item['date'] as String? ?? '';
            String dayLabel = '';
            try {
              final date = DateTime.parse(dateStr);
              dayLabel = '${date.month}/${date.day}';
            } catch (_) {
              dayLabel = dateStr;
            }
            return {
              'day': dayLabel,
              'cost': item['total_waste'] as double? ?? 0.0,
              'color': _orange,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching food waste data: $e');
    }
  }


  void _loadClassWiseData() {
    Map<String, String> classEmojis = {
      'Bees': '🐝', 'Zebras': '🦓', 'Dolphins': '🐬', 'Leopards': '🐆',
      'Bears': '🐻', 'Eagles': '🦅', 'Sharks': '🦈', 'Penguins': '🐧',
    };
    _classData = _fetchedPieChartData.map((item) {
      String className = (item is ActivityAttendance
          ? item.description : item['description']) ?? 'Unknown';
      int total   = (item is ActivityAttendance
          ? item.total_student_count : item['total_student_count']) ?? 0;
      int present = (item is ActivityAttendance
          ? item.present_count : item['present_count']) ?? 0;
      int organizationId = (item is ActivityAttendance
          ? item.id : item['id']) ?? 53;
      return {
        'name':           className,
        'emoji':          classEmojis[className] ?? '📚',
        'total':          total,
        'present':        present,
        'organizationId': organizationId,
        'attendance_percentage': 0.0,
      };
    }).toList();
  }

  int calculateTotalStudentCount(List<dynamic> data) {
    return data.fold(0, (sum, a) =>
        sum + ((a is ActivityAttendance
            ? a.total_student_count
            : a['total_student_count'] as int?) ?? 0));
  }

  int calculateTotalAttendance(List<dynamic> data) {
    return data.fold(0, (sum, a) =>
        sum + ((a is ActivityAttendance
            ? a.present_count
            : a['present_count'] as int?) ?? 0));
  }

  // ─────────────────────────────────────────────
  //  Absent Students Popup
  // ─────────────────────────────────────────────
  void _showAbsentStudentsPopup(
      BuildContext context, Map<String, dynamic> classData) {
    final int organizationId = classData['organizationId'] as int;
    final int total = classData['total'] as int;
    final int present = classData['present'] as int;
    final String className = classData['name'] as String;
    final String emoji = classData['emoji'] as String;
    final int activityId = 4; // Fixed activity ID for attendance tracking

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(className,
                              style: const TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w800, color: _textDark)),
                          FutureBuilder<Map<String, dynamic>>(
                            future: getDailyAbsenceSummary(organizationId, activityId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading absent students...',
                                    style: TextStyle(fontSize: 11, color: _textMid));
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}',
                                    style: const TextStyle(fontSize: 11, color: _red));
                              } else {
                                final absenceData = snapshot.data ?? {};
                                final absentCount = absenceData['absent_count'] as int? ?? 0;
                                return Text(
                                  '$absentCount student${absentCount > 1 ? 's' : ''} absent today',
                                  style: const TextStyle(fontSize: 11, color: _red),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: _textLight),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: _divider),
                const SizedBox(height: 14),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: getDailyAbsenceSummary(organizationId, activityId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SpinKitFadingCircle(
                            color: _primary,
                            size: 30,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load absent students',
                            style: const TextStyle(fontSize: 13, color: _red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        final absenceData = snapshot.data ?? {};
                        final absentNamesStr = absenceData['absent_names'] as String? ?? '';
                        final absentList = absentNamesStr.isNotEmpty
                            ? absentNamesStr.split(',').map((e) => e.trim()).toList()
                            : <String>[];

                        if (absentList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No absent students',
                              style: TextStyle(fontSize: 13, color: _green),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: absentList.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: _divider),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                      color: _red.withOpacity(0.1),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(absentList[i][0].toUpperCase(),
                                        style: const TextStyle(fontSize: 13,
                                            fontWeight: FontWeight.w800, color: _red)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(absentList[i],
                                      style: const TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.w600, color: _textDark)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _red.withOpacity(0.2)),
                                  ),
                                  child: const Text('Absent',
                                      style: TextStyle(fontSize: 10,
                                          fontWeight: FontWeight.w700, color: _red)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: _bgPage, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Present: $present/$total',
                          style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700, color: _green)),
                      FutureBuilder<Map<String, dynamic>>(
                        future: getDailyAbsenceSummary(organizationId, activityId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final absenceData = snapshot.data ?? {};
                            final absentCount = absenceData['absent_count'] as int? ?? 0;
                            return Text('Absent: $absentCount',
                                style: const TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w700, color: _red));
                          }
                          return const Text('Absent: --',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w700, color: _red));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Staff Task Details Popup
  // ─────────────────────────────────────────────
  void _showStaffTaskDetailsPopup(
    BuildContext context,
    Map<String, dynamic> staffSummary,
    String filterStatus, // 'Pending' or 'InProgress'
  ) {
    final int personId       = staffSummary['personId'] as int;
    final String personName  = staffSummary['name'] as String;
    final List<Map<String, dynamic>> allTasks =
        _staffTaskDetails[personId] ?? [];
    final List<Map<String, dynamic>> filtered =
        allTasks.where((t) => t['status'] == filterStatus).toList();

    if (filtered.isEmpty) return;

    final bool isPending   = filterStatus == 'Pending';
    final Color chipColor  = isPending ? _orange : _primary;
    final String statusLabel = isPending ? 'Pending' : 'In Progress';
    final IconData statusIcon =
        isPending ? Icons.hourglass_empty_rounded : Icons.autorenew_rounded;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: chipColor.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          personName.isNotEmpty
                              ? personName[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800, color: chipColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(personName,
                              style: const TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w800, color: _textDark)),
                          Row(
                            children: [
                              Icon(statusIcon, size: 11, color: chipColor),
                              const SizedBox(width: 4),
                              Text('$statusLabel Tasks (${filtered.length})',
                                  style: TextStyle(fontSize: 11,
                                      color: chipColor,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: _textLight),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: _divider),
                const SizedBox(height: 12),

                // ── Task list ──
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final task        = filtered[i];
                      final String title = task['title'] as String? ?? 'Untitled';
                      final String? dueDate =
                          task['due_date'] as String?;
                      final String? description =
                          task['description'] as String?;
                      final int? activityId = task['id'] as int?;

                      // Parse and format due date
                      String? formattedDue;
                      // Check if task is in the overdue set AND person has overdue tasks
                      bool isOverdue = personId != null && 
                          _overduePersonIds.contains(personId) &&
                          activityId != null && 
                          _overdueTaskActivityIds.contains(activityId);
                      if (dueDate != null) {
                        try {
                          final dt = DateTime.parse(dueDate);
                          formattedDue = DateFormat('d MMM yyyy').format(dt);
                        } catch (_) {
                          formattedDue = dueDate;
                        }
                      }

                      final Color rowColor = isOverdue ? _red : chipColor;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: rowColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: rowColor.withOpacity(0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                      color: rowColor,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(title,
                                      style: const TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark)),
                                ),
                                const SizedBox(width: 8),
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rowColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: rowColor.withOpacity(0.25)),
                                  ),
                                  child: Text(
                                    isOverdue ? 'Overdue' : statusLabel,
                                    style: TextStyle(fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: rowColor),
                                  ),
                                ),
                              ],
                            ),

                            // Description
                            if (description != null &&
                                description.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11, color: _textMid)),
                              ),
                            ],

                            // Due date
                            if (formattedDue != null) ...[
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 10, color: rowColor),
                                    const SizedBox(width: 4),
                                    Text('Due: $formattedDue',
                                        style: TextStyle(fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: rowColor)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ── Footer ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: _bgPage,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, size: 12, color: chipColor),
                          const SizedBox(width: 5),
                          Text('$statusLabel: ${filtered.length}',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: chipColor)),
                        ],
                      ),
                      if (_overduePersonIds.contains(personId))
                        Visibility(
                          visible: filtered.any((task) {
                            final taskActivityId = task['id'] as int?;
                            return taskActivityId != null &&
                                _overdueTaskActivityIds.contains(taskActivityId);
                          }),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 12, color: _red),
                              SizedBox(width: 4),
                              Text('Has overdue tasks',
                                  style: TextStyle(fontSize: 11,
                                      fontWeight: FontWeight.w700, color: _red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: FadeTransition(
                    opacity: _viewSwitchAnimation,
                    child: _buildMainGrid(),
                  ),
                ),
              ],
            ),
          ),
          if (_isFetching) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(_now);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                letterSpacing: 2.5, color: _textDark,
              ),
            ),
            Text(dateStr,
                style: const TextStyle(fontSize: 10, color: _textMid, letterSpacing: 0.3)),
          ],
        ),
        const Spacer(),

        // ── View Toggle ──
        if (!_roleFixed) ...[
          _buildViewToggle(),
          const SizedBox(width: 14),
        ],

        // Clock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _divider),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Text(timeStr,
            style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: _primary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Refresh
        IconButton(
          onPressed: _loadAllDashboardData,
          icon: const Icon(Icons.refresh_rounded, color: _primary),
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            backgroundColor: _bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: _divider),
          ),
        ),
        const SizedBox(width: 10),

        // Manage Tasks — hidden in Teacher view
        if (_currentView == DashboardView.management)
          ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const KanbanScreen()))
                .then((_) { if (mounted) _loadAllDashboardData(); });
          },
          icon: const Icon(Icons.task_alt, size: 16),
          label: const Text('MANAGE TASKS'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.0, fontSize: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ── View Toggle Widget ──────────────────────
  Widget _buildViewToggle() {
    // Hide view toggle if role is fixed via environment variable
    if (_roleFixed) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _viewToggleButton(
            label: 'Management',
            icon: Icons.business_center_rounded,
            isActive: _currentView == DashboardView.management,
            onTap: () => _switchView(DashboardView.management),
          ),
          const SizedBox(width: 2),
          _viewToggleButton(
            label: 'Teacher',
            icon: Icons.school_rounded,
            isActive: _currentView == DashboardView.teacher,
            onTap: () => _switchView(DashboardView.teacher),
          ),
        ],
      ),
    );
  }

  Widget _viewToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isActive ? Colors.white : _textMid),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: isActive ? Colors.white : _textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3-column grid ────────────────────────────
  Widget _buildMainGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT: Attendance donut + Late analysis
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(flex: 4, child: _buildAttendanceSummaryCard()),
              const SizedBox(height: 10),
              Expanded(flex: 5, child: _buildLateAnalysisCard()),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // MIDDLE: Class-wise
        Expanded(flex: 5, child: _buildClassWiseCard()),
        const SizedBox(width: 10),

        // RIGHT: Staff tasks + food waste
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                child: _currentView == DashboardView.management
                    ? _buildStaffTaskOverviewCard()
                    : _buildStudentAttendanceRankCard(),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildFoodWasteCard()),
            ],
          ),
        ),
      ],
    );
  }

  // ── Attendance Summary Card ──────────────────
  Widget _buildAttendanceSummaryCard() {
    double percentage = totalStudentCount > 0
        ? (totalAttendance / totalStudentCount) * 100
        : 0;

    return _card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150, height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: CircularProgressIndicator(
                      value: 1, strokeWidth: 16,
                      backgroundColor: const Color(0xFFECF0F1),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFECF0F1)),
                    ),
                  ),
                  SizedBox(
                    width: 140, height: 140,
                    child: CircularProgressIndicator(
                      value: percentage / 100, strokeWidth: 16,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF1BB6E8)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$totalAttendance',
                          style: const TextStyle(fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50))),
                      Text('of $totalStudentCount',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Students Present',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${percentage.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27AE60))),
            ),
          ],
        ),
      ),
    );
  }
  // ── Late Analysis Card ───────────────────────
  Widget _buildLateAnalysisCard() {
    final List<Map<String, dynamic>> lateAttendanceData =
        _lateAttendanceData.isNotEmpty ? _lateAttendanceData : [];
    if (lateAttendanceData.isEmpty) {
      return _card(
        child: Center(
          child: Text('No late attendance data',
              style: TextStyle(fontSize: 12, color: _textLight)),
        ),
      );
    }
    int totalLate =
        lateAttendanceData.fold(0, (s, i) => s + (i['value'] as int));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LATE ATTENDANCE ANALYSIS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.5, color: _textMid)),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SizedBox(
                      width: 150, height: 150,
                      child: GestureDetector(
                        onTapUp: (d) => _handlePieChartTap(
                            d.localPosition, lateAttendanceData, 150),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onHover: (e) => _handlePieChartHover(
                              e.localPosition, lateAttendanceData, 150),
                          onExit: (_) =>
                              setState(() => _hoveredPieSegment = null),
                          child: Stack(
                            children: [
                              CustomPaint(
                                painter: _PieChartPainter(
                                    lateAttendanceData, Colors.white),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('$totalAttendance',
                                          style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: _textDark)),
                                      const Text('Students',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: _textMid)),
                                    ],
                                  ),
                                ),
                              ),
                              if (_hoveredPieSegment != null)
                                Positioned(
                                  top: 0, left: 0, right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _textDark,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        boxShadow: [BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.15),
                                            blurRadius: 4)],
                                      ),
                                      child: Text(_hoveredPieSegment!,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Legend + bars
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: lateAttendanceData.map((item) {
                      double pct =
                          (item['value'] as int) / totalLate * 100;
                      final color = item['color'] as Color;
                      final label = item['label'] as String;
                      final value = item['value'] as int;
                      return GestureDetector(
                        onTap: () => _showStudentsByTimeRange(label, value),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 9, height: 9,
                                  decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(label,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: _textDark,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 3),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: pct / 100,
                                          minHeight: 5,
                                          backgroundColor:
                                              const Color(0xFFE8F0F5),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$value',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: color)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Class-wise Card ──────────────────────────
  Widget _buildClassWiseCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CLASS-WISE ATTENDANCE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: _textMid)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${_classData.length} Classes',
                    style: const TextStyle(fontSize: 10, color: _primary,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _classData.isEmpty
                ? const Center(child: Text('No class data',
                    style: TextStyle(color: _textLight)))
                : ListView.builder(
                    itemCount: _classData.length,
                    itemBuilder: (context, index) {
                      final c = _classData[index];
                      final pct = c['total'] > 0
                          ? (c['present'] as int) / (c['total'] as int)
                          : 0.0;
                      final absentCount = c['total'] - c['present'];

                      return InkWell(
                        onTap: () => _showAbsentStudentsPopup(context, c),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4, height: 32,
                                decoration: BoxDecoration(
                                    color: _primary,
                                    borderRadius:
                                        BorderRadius.circular(2)),
                              ),
                              const SizedBox(width: 10),
                              Text(c['emoji'],
                                  style:
                                      const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(c['name'],
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _textDark)),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: ((c['attendance_percentage'] as double?) ?? 0) >= 0
                                                      ? _green.withOpacity(0.1)
                                                      : _red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  'Y.T.D - ${((c['attendance_percentage'] as double?) ?? 0).toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      color: ((c['attendance_percentage'] as double?) ?? 0) >= 0
                                                          ? _green
                                                          : _red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index == 0) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                            child: const Row(
                                              children: [
                                                Text('😊', style: TextStyle(fontSize: 10)),
                                                SizedBox(width: 2),
                                                Text('Best Attendance', style: TextStyle(fontSize: 8, color: _green, fontWeight: FontWeight.bold)),
                                              ]
                                            ),
                                          )
                                        ],
                                        if (index == _classData.length - 1 && _classData.length > 1) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(color: _red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                            child: const Row(
                                              children: [
                                                Text('😞', style: TextStyle(fontSize: 10)),
                                                SizedBox(width: 2),
                                                Text('Worst Attendance', style: TextStyle(fontSize: 8, color: _red, fontWeight: FontWeight.bold)),
                                              ]
                                            ),
                                          )
                                        ],
                                        const SizedBox(width: 8),
                                        Text(
                                            '${c['present']}/${c['total']}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: _primary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 4,
                                        backgroundColor:
                                            const Color(0xFFDEEDF5),
                                        valueColor:
                                            const AlwaysStoppedAnimation<
                                                Color>(_primary),
                                      ),
                                    ),
                                    if (absentCount > 0) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            'Absent ($absentCount)',
                                            style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: _red),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                              Icons.open_in_new_rounded,
                                              size: 11,
                                              color: _red),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Staff Task Overview Card ─────────────────
  Widget _buildStaffTaskOverviewCard() {
    // Count staff with actual overdue pending/in-progress tasks
    int actualOverdueCount = 0;
    for (var s in _staffTaskSummaries) {
      final int personId = s['personId'] as int;
      final personTasks = _staffTaskDetails[personId] ?? [];
      final hasOverdue = personTasks.any((task) {
        final taskActivityId = task['id'] as int?;
        final status = task['status'] as String?;
        return taskActivityId != null &&
            _overdueTaskActivityIds.contains(taskActivityId) &&
            (status == 'Pending' || status == 'InProgress');
      });
      if (hasOverdue) actualOverdueCount++;
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('STAFF TASK STATUS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: _textMid)),
              const Spacer(),
              if (actualOverdueCount > 0)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color.lerp(const Color(0xFFFFE5E5),
                          const Color(0xFFFFCCCC), _glowAnimation.value),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _red.withOpacity(
                              0.4 + _glowAnimation.value * 0.3)),
                      boxShadow: [BoxShadow(
                          color: _red.withOpacity(
                              _glowAnimation.value * 0.25),
                          blurRadius: 8, spreadRadius: 1)],
                    ),
                    child: Text(
                      '⚠  $actualOverdueCount OVERDUE',
                      style: const TextStyle(fontSize: 10, color: _red,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            children: [
              _legendDot(_orange, 'Pending'),
              const SizedBox(width: 14),
              _legendDot(_primary, 'In Progress'),
              const SizedBox(width: 14),
              _legendDot(_red, 'Overdue'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _staffTaskSummaries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, color: _green, size: 38),
                        SizedBox(height: 8),
                        Text('All caught up!',
                            style: TextStyle(color: _green,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text('No Ongoing tasks',
                            style: TextStyle(
                                color: _textLight, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _staffTaskSummaries.length,
                    itemBuilder: (context, index) {
                      final s = _staffTaskSummaries[index];
                      final int personId = s['personId'] as int;
                      // Check if person has any overdue tasks in their task list
                      final personTasks = _staffTaskDetails[personId] ?? [];
                      final bool hasOverdue = personTasks.any((task) {
                        final taskActivityId = task['id'] as int?;
                        final status = task['status'] as String?;
                        // Only count as overdue if their status is Pending/InProgress AND task is in overdue set
                        return taskActivityId != null &&
                            _overdueTaskActivityIds.contains(taskActivityId) &&
                            (status == 'Pending' || status == 'InProgress');
                      });

                      return AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (_, __) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasOverdue
                                ? Color.lerp(
                                    const Color(0xFFFFF5F5),
                                    const Color(0xFFFFEBEB),
                                    _glowAnimation.value)
                                : const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasOverdue
                                  ? _red.withOpacity(
                                      0.3 + _glowAnimation.value * 0.3)
                                  : _divider,
                              width: 1.5,
                            ),
                            boxShadow: hasOverdue
                                ? [BoxShadow(
                                    color: _red.withOpacity(
                                        _glowAnimation.value * 0.15),
                                    blurRadius: 8)]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Avatar initial
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: hasOverdue
                                      ? _red.withOpacity(0.12)
                                      : _primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (s['name'] as String).isNotEmpty
                                        ? (s['name'] as String)[0]
                                            .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: hasOverdue
                                            ? _red : _primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Name
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        s['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: hasOverdue
                                              ? (_blinkOn
                                                  ? _red
                                                  : const Color(
                                                      0xFFC0392B))
                                              : _textDark,
                                        ),
                                      ),
                                    ),
                                    if (hasOverdue) ...[
                                      const SizedBox(width: 4),
                                      Text(_blinkOn ? '⚠' : ' ',
                                          style: const TextStyle(
                                              fontSize: 11)),
                                    ],
                                  ],
                                ),
                              ),

                              // ── Clickable chips ──
                              if ((s['pending'] as int) > 0)
                                GestureDetector(
                                  onTap: () =>
                                      _showStaffTaskDetailsPopup(
                                          context, s, 'Pending'),
                                  child: _taskChip(
                                      '${s['pending']} Pending',
                                      _orange),
                                ),
                              const SizedBox(width: 4),
                              if ((s['progress'] as int) > 0)
                                GestureDetector(
                                  onTap: () =>
                                      _showStaffTaskDetailsPopup(
                                          context, s, 'InProgress'),
                                  child: _taskChip(
                                      '${s['progress']} Ongoing',
                                      _primary),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Student Attendance Rank Card (Teacher View) ──
  Widget _buildStudentAttendanceRankCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('STUDENT ATTENDANCE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: _textMid)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 9, color: _primary),
                    const SizedBox(width: 4),
                    Text('${_formatDateRange(_attendanceFromDate)} - ${_formatDateRange(_attendanceToDate)}',
                        style: const TextStyle(fontSize: 10, color: _primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Column headers
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: _green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    const Text('Best Attendance',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: _green)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: _red, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    const Text('Worst Attendance',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: _red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _divider),
          const SizedBox(height: 8),

          // Two scrollable columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Best attendance column
                Expanded(
                  child: ListView.builder(
                    itemCount: _bestAttendanceStudents.length,
                    itemBuilder: (context, index) {
                      final student = _bestAttendanceStudents[index];
                      final double percentage = student['percentage'] as double;
                      return _attendanceRankRow(
                        rank: index + 1,
                        name: student['name'] as String,
                        className: student['class'] as String,
                        statLabel: '${percentage.toStringAsFixed(1)}%',
                        pct: percentage / 100,
                        color: _green,
                        isBest: true,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Divider
                Container(width: 1, color: _divider),
                const SizedBox(width: 8),
                // Worst attendance column
                Expanded(
                  child: ListView.builder(
                    itemCount: _worstAttendanceStudents.length,
                    itemBuilder: (context, index) {
                      final student = _worstAttendanceStudents[index];
                      final double percentage = student['percentage'] as double;
                      return _attendanceRankRow(
                        rank: index + 1,
                        name: student['name'] as String,
                        className: student['class'] as String,
                        statLabel: '${percentage.toStringAsFixed(1)}%',
                        pct: percentage / 100,
                        color: _red,
                        isBest: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceRankRow({
    required int rank,
    required String name,
    required String className,
    required String statLabel,
    required double pct,
    required Color color,
    required bool isBest,
  }) {
    final bool isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isTopThree
            ? color.withOpacity(0.06)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTopThree ? color.withOpacity(0.2) : _divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: isTopThree ? color : color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isTopThree ? Colors.white : color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isTopThree ? _textDark : _textMid,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Class name chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  className,
                  style: const TextStyle(fontSize: 8,
                      fontWeight: FontWeight.w700, color: _primary),
                ),
              ),
              Text(
                statLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 3,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ── Food Waste Card ──────────────────────────
  Widget _buildFoodWasteCard() {
    final List<Map<String, dynamic>> wasteData = _foodWasteData.isNotEmpty 
        ? _foodWasteData 
        : [];

    if (wasteData.isEmpty) {
      return _card(
        child: Center(
          child: Text('No food waste data',
              style: TextStyle(fontSize: 12, color: _textLight)),
        ),
      );
    }

    final maxCost = wasteData.map((d) => d['cost'] as double).reduce(max);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FOOD WASTE TREND',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: _textMid)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Last 7 Days',
                    style: TextStyle(fontSize: 10, color: _orange,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Line chart
          Expanded(
            flex: 6,
            child: LayoutBuilder(builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final pointCount = wasteData.length;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(4, (i) {
                    final y = h - (i / 3) * h * 0.75 - h * 0.1;
                    return Positioned(
                      top: y - 8, 
                      left: 0, 
                      right: 0,
                      child: Container(
                        height: 1,
                        color: _divider
                      ),
                    );
                  }),
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        lineColor: _orange,
                        fillColor: _orange.withOpacity(0.08),
                        maxCost: maxCost,
                        data: wasteData,
                      ),
                    ),
                  ),

                  // Day labels + cost labels on points
                  ...List.generate(pointCount, (i) {
                    final cost = wasteData[i]['cost'] as double;
                    final x = i * (w / (pointCount - 1));
                    final y = h - (cost / maxCost) * (h * 0.75) - h * 0.1;
                    return Positioned(
                      left: x - 20,
                      top: y - 22,
                      child: SizedBox(
                        width: 40,
                        child: Text(
                            'LKR ${cost.toInt()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 7,
                                color: _textMid,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  }),
                  ...List.generate(pointCount, (i) {
                    final x = i * (w / (pointCount - 1));
                    return Positioned(
                      left: x - 16,
                      bottom: 0,
                      child: SizedBox(
                        width: 32,
                        child: Text(
                          wasteData[i]['day'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 8, color: _textMid)),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _divider),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Shared helpers ───────────────────────────
  String _formatDateRange(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: color,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _taskChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(color: color, fontSize: 10,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 3),
          Icon(Icons.arrow_forward_ios_rounded, size: 8, color: color),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.6),
      child: const Center(child: SpinKitCircle(color: _primary, size: 56)),
    );
  }

  // ── Pie chart interaction ────────────────────
  void _handlePieChartHover(Offset localPosition,
      List<Map<String, dynamic>> data, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = size / 2;
    final innerRadius = radius * 0.6;

    if (distance < innerRadius || distance > radius) {
      if (_hoveredPieSegment != null) setState(() => _hoveredPieSegment = null);
      return;
    }

    double hoverAngle = atan2(dy, dx);
    if (hoverAngle < 0) hoverAngle += 2 * pi;
    hoverAngle = (hoverAngle + pi / 2) % (2 * pi);

    int total = data.fold(0, (s, i) => s + (i['value'] as int));
    double currentAngle = 0;
    for (var item in data) {
      final value = item['value'] as int;
      final sweepAngle = (value / total) * 2 * pi;
      if (hoverAngle >= currentAngle && hoverAngle < currentAngle + sweepAngle) {
        String label = '${item['label']}: $value students';
        if (_hoveredPieSegment != label) setState(() => _hoveredPieSegment = label);
        return;
      }
      currentAngle += sweepAngle;
    }
  }

  void _handlePieChartTap(Offset localPosition,
      List<Map<String, dynamic>> data, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = size / 2;
    final innerRadius = radius * 0.6;
    if (distance < innerRadius || distance > radius) return;

    double tapAngle = atan2(dy, dx);
    if (tapAngle < 0) tapAngle += 2 * pi;
    tapAngle = (tapAngle + pi / 2) % (2 * pi);

    int total = data.fold(0, (s, i) => s + (i['value'] as int));
    double currentAngle = 0;
    for (var item in data) {
      final value = item['value'] as int;
      final sweepAngle = (value / total) * 2 * pi;
      if (tapAngle >= currentAngle && tapAngle < currentAngle + sweepAngle) {
        // Show students for this time range
        _showStudentsByTimeRange(item['label'] as String, value);
        return;
      }
      currentAngle += sweepAngle;
    }
  }

  void _showStudentsByTimeRange(String timeRange, int studentCount) {
    // Get student names for this time range from late attendance data
    List<String> names = [];
    for (var entry in _lateAttendanceData) {
      if (entry['label'] == timeRange) {
        if (entry['students'] is List<String>) {
          names = List<String>.from(entry['students']);
        }
        break;
      }
    }

    // Convert names to student list format
    List<Map<String, String>> students;
    if (names.isNotEmpty) {
      students = names.map((n) => {'name': n, 'id': ''}).toList();
    } else {
      students = [];
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Late Students - $timeRange',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$studentCount students in this time range',
                              style: TextStyle(
                                fontSize: 13,
                                color: _textMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                        color: _textLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _divider),
                  const SizedBox(height: 12),

                  // ── Student List ──
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Text(
                              'No student data available',
                              style: TextStyle(
                                fontSize: 13,
                                color: _textLight,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: students.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              final student = students[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F9FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _divider,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _orange.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          student['name']!
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: _orange,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['name']!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────
class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color gapColor;
  _PieChartPainter(this.data, this.gapColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final bool isSingleItem = data.length == 1;
    final innerRadius = isSingleItem ? 0.0 : radius * 0.6;
    int total = data.fold(0, (s, i) => s + (i['value'] as int));
    double startAngle = -pi / 2;

    for (var item in data) {
      final sweepAngle = (item['value'] / total) * 2 * pi;
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.fill;
      
      final Path path;
      if (isSingleItem) {
        // For single item, draw a ring without center fill
        path = Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius))
          ..fillType = PathFillType.evenOdd
          ..addOval(Rect.fromCircle(center: center, radius: radius * 0.6));
      } else {
        // For multiple items, draw the donut segment
        path = Path()
          ..moveTo(center.dx + innerRadius * cos(startAngle),
              center.dy + innerRadius * sin(startAngle))
          ..lineTo(center.dx + radius * cos(startAngle),
              center.dy + radius * sin(startAngle))
          ..arcTo(Rect.fromCircle(center: center, radius: radius),
              startAngle, sweepAngle, false)
          ..lineTo(
              center.dx + innerRadius * cos(startAngle + sweepAngle),
              center.dy + innerRadius * sin(startAngle + sweepAngle))
          ..arcTo(Rect.fromCircle(center: center, radius: innerRadius),
              startAngle + sweepAngle, -sweepAngle, false)
          ..close();
        
        final gapPaint = Paint()
          ..color = gapColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(path, gapPaint);
      }
      
      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple painter for the food waste line chart
class _LineChartPainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;
  final double maxCost;
  final List<Map<String, dynamic>> data;

  _LineChartPainter({
    required this.lineColor,
    required this.fillColor,
    required this.maxCost,
    required this.data,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final int count = data.length;

    // draw vertical dotted guidelines for each point
    final dashPaint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < count; i++) {
      final double x = i * (w / (count - 1));
      double y = 0;
      const double dashHeight = 4;
      const double gapHeight = 4;
      while (y < h) {
        final double y2 = (y + dashHeight).clamp(0, h);
        canvas.drawLine(Offset(x, y), Offset(x, y2), dashPaint);
        y += dashHeight + gapHeight;
      }
    }

    for (int i = 0; i < count; i++) {
      final double x = i * (w / (count - 1));
      final double value = data[i]['cost'] as double;
      final double y = h - (value / maxCost) * (h * 0.75) - h * 0.1;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // draw colored circles at each point
    for (int i = 0; i < count; i++) {
      final double x = i * (w / (count - 1));
      final double value = data[i]['cost'] as double;
      final double y = h - (value / maxCost) * (h * 0.75) - h * 0.1;
      final Color dotColor = data[i]['color'] as Color? ?? lineColor;
      canvas.drawCircle(Offset(x, y), 4.0, Paint()..color = dotColor);
    }

    // fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) {
    return old.data != data ||
        old.maxCost != maxCost ||
        old.lineColor != lineColor ||
        old.fillColor != fillColor;
  }
}
