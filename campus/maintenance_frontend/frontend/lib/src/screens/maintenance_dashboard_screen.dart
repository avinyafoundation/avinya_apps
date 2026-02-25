import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../data/activity_attendance.dart';
import '../data/task_item.dart';
import 'kanban_screen.dart';

class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _MaintenanceDashboardScreenState createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends State<MaintenanceDashboardScreen> with TickerProviderStateMixin {
  // --- Data States ---
  bool _isFetching = true;
  List<dynamic> _fetchedPieChartData = [];
  List<Map<String, dynamic>> _classData = [];
  List<Map<String, dynamic>> _staffTaskSummaries = [];
  Set<int> _overduePersonIds = {};

  Timer? _blinkTimer;
  bool _blinkOn = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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
  static const Color _red       = Color(0xFFE74C3C);
  static const Color _orange    = Color(0xFFF39C12);
  static const Color _divider   = Color(0xFFE4EBF0);

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

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
    if ((hour == 7 && minute >= 15) || (hour == 8 && minute <= 15)) {
      final totalMinutes = hour * 60 + minute;
      final start = 7 * 60 + 15; // 7:15 in minutes
      if ((totalMinutes - start) % 3 == 0) {
        shouldRefresh = true;
      }
    }
    // fixed checkpoints around breakfast hours
    if (hour == 8 && minute == 30) shouldRefresh = true;
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
    super.dispose();
  }

  // --- Logic ---
  Future<void> _loadAllDashboardData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isFetching = true);
    try {
      _fetchedPieChartData = await getDailyStudentsAttendanceByParentOrg(2);
      if (!mounted) return;
      totalStudentCount = calculateTotalStudentCount(_fetchedPieChartData);
      totalAttendance   = calculateTotalAttendance(_fetchedPieChartData);
      _loadClassWiseData();
      await _fetchStaffTaskSummaries();
    } catch (error) {
      print('Dashboard Load Error: $error');
    } finally {
      if (mounted && !silent) setState(() => _isFetching = false);
    }
  }

  Future<void> _fetchStaffTaskSummaries() async {
    _overduePersonIds.clear();
    try {
      List<dynamic> overdueTasks = await getOverdueTasks(2);
      if (mounted) {
        for (var task in overdueTasks) {
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
        }
        if (status == 'Pending') {
          staffTaskMap[personId]!['pending'] = (staffTaskMap[personId]!['pending'] as int) + 1;
        } else if (status == 'InProgress') {
          staffTaskMap[personId]!['progress'] = (staffTaskMap[personId]!['progress'] as int) + 1;
        }
      }
    }

    _staffTaskSummaries = staffTaskMap.values
        .where((s) => (s['pending'] as int) > 0 || (s['progress'] as int) > 0)
        .toList();
  }

  void _loadClassWiseData() {
    Map<String, String> classEmojis = {
      'Bees': '🐝', 'Zebras': '🦓', 'Dolphins': '🐬', 'Leopards': '🐆',
      'Bears': '🐻', 'Eagles': '🦅', 'Sharks': '🦈', 'Penguins': '🐧',
    };
    _classData = _fetchedPieChartData.map((item) {
      String className = (item is ActivityAttendance ? item.description : item['description']) ?? 'Unknown';
      int total   = (item is ActivityAttendance ? item.total_student_count : item['total_student_count']) ?? 0;
      int present = (item is ActivityAttendance ? item.present_count : item['present_count']) ?? 0;
      return {
        'name':    className,
        'emoji':   classEmojis[className] ?? '📚',
        'total':   total,
        'present': present,
      };
    }).toList();
  }

  int calculateTotalStudentCount(List<dynamic> data) {
    return data.fold(0, (sum, a) =>
        sum + ((a is ActivityAttendance ? a.total_student_count : a['total_student_count'] as int?) ?? 0));
  }

  int calculateTotalAttendance(List<dynamic> data) {
    return data.fold(0, (sum, a) =>
        sum + ((a is ActivityAttendance ? a.present_count : a['present_count'] as int?) ?? 0));
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
                Expanded(child: _buildMainGrid()),
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

        // Manage Tasks
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
              Expanded(child: _buildStaffTaskOverviewCard()),
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
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 16,
                      backgroundColor: const Color(0xFFECF0F1),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFECF0F1)),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 16,
                      backgroundColor: Colors.transparent,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF1BB6E8)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$totalAttendance',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'of $totalStudentCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Students Present',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 1),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${percentage.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27AE60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ── Late Analysis Card ───────────────────────
  Widget _buildLateAnalysisCard() {
    final List<Map<String, dynamic>> lateAttendanceData = [
      {'label': 'Before 7:30', 'value': 45, 'color': const Color(0xFF2ECC71)},
      {'label': '7:30 – 7:45', 'value': 25, 'color': const Color(0xFF3498DB)},
      {'label': '7:45 – 8:00', 'value': 15, 'color': const Color(0xFFF39C12)},
      {'label': '8:00 – 8:30', 'value': 10, 'color': const Color(0xFFE67E22)},
      {'label': 'After 8:30',  'value': 5,  'color': const Color(0xFFE74C3C)},
    ];
    int totalLate = lateAttendanceData.fold(0, (s, i) => s + (i['value'] as int));

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
                // Donut
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SizedBox(
                      width: 150, height: 150,
                      child: GestureDetector(
                        onTapUp: (d) =>
                            _handlePieChartTap(d.localPosition, lateAttendanceData, 150),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onHover: (e) =>
                              _handlePieChartHover(e.localPosition, lateAttendanceData, 150),
                          onExit: (_) => setState(() => _hoveredPieSegment = null),
                          child: Stack(
                            children: [
                              CustomPaint(
                                painter: _PieChartPainter(lateAttendanceData, Colors.white),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('$totalAttendance',
                                          style: const TextStyle(fontSize: 26,
                                              fontWeight: FontWeight.w800, color: _textDark)),
                                      const Text('Students',
                                          style: TextStyle(fontSize: 10, color: _textMid)),
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
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 4)],
                                      ),
                                      child: Text(_hoveredPieSegment!,
                                          style: const TextStyle(color: Colors.white,
                                              fontSize: 10, fontWeight: FontWeight.w600)),
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
                      double pct = (item['value'] as int) / totalLate * 100;
                      final color = item['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 9, height: 9,
                              decoration: BoxDecoration(
                                  color: color, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['label'] as String,
                                      style: const TextStyle(fontSize: 11,
                                          color: _textDark, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 3),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct / 100, minHeight: 5,
                                      backgroundColor: const Color(0xFFE8F0F5),
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${item['value']}',
                                style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w700, color: color)),
                          ],
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 10),
                            Text(c['emoji'], style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(c['name'],
                                          style: const TextStyle(fontSize: 12,
                                              fontWeight: FontWeight.w700, color: _textDark)),
                                      Text('${c['present']}/${c['total']}',
                                          style: const TextStyle(fontSize: 11,
                                              fontWeight: FontWeight.w700, color: _primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct, minHeight: 4,
                                      backgroundColor: const Color(0xFFDEEDF5),
                                      valueColor: const AlwaysStoppedAnimation<Color>(_primary),
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
    );
  }

  // ── Staff Task Overview Card ─────────────────
  Widget _buildStaffTaskOverviewCard() {
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
              if (_overduePersonIds.isNotEmpty)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                          const Color(0xFFFFE5E5), const Color(0xFFFFCCCC),
                          _glowAnimation.value),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _red.withOpacity(0.4 + _glowAnimation.value * 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: _red.withOpacity(_glowAnimation.value * 0.25),
                          blurRadius: 8, spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '⚠  ${_overduePersonIds.length} OVERDUE',
                      style: const TextStyle(fontSize: 10, color: _red,
                          fontWeight: FontWeight.w800, letterSpacing: 0.3),
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
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('No Ongoing tasks',
                            style: TextStyle(color: _textLight, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _staffTaskSummaries.length,
                    itemBuilder: (context, index) {
                      final s = _staffTaskSummaries[index];
                      final bool hasOverdue =
                          _overduePersonIds.contains(s['personId']);

                      return AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (_, __) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasOverdue
                                ? Color.lerp(const Color(0xFFFFF5F5),
                                    const Color(0xFFFFEBEB), _glowAnimation.value)
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
                                ? [
                                    BoxShadow(
                                      color: _red.withOpacity(
                                          _glowAnimation.value * 0.15),
                                      blurRadius: 8,
                                    ),
                                  ]
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
                                        ? (s['name'] as String)[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800,
                                      color: hasOverdue ? _red : _primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Name + hint
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            s['name'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: hasOverdue
                                                  ? (_blinkOn ? _red : const Color(0xFFC0392B))
                                                  : _textDark,
                                            ),
                                          ),
                                        ),
                                        if (hasOverdue) ...[
                                          const SizedBox(width: 4),
                                          Text(_blinkOn ? '⚠' : ' ',
                                              style: const TextStyle(fontSize: 11)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Chips
                              if ((s['pending'] as int) > 0)
                                _taskChip('${s['pending']} Pending', _orange),
                              const SizedBox(width: 4),
                              if ((s['progress'] as int) > 0)
                                _taskChip('${s['progress']} Ongoing', _primary),
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

  // ── Shared helpers ───────────────────────────
  // ── Food Waste Card ──────────────────────────
  Widget _buildFoodWasteCard() {
    // Hardcoded last-7-days data
    final List<Map<String, dynamic>> wasteData = [
      {'day': '2/18', 'cost': 320.0, 'color': _orange},
      {'day': '2/19', 'cost': 180.0, 'color': _orange},
      {'day': '2/20', 'cost': 400.0, 'color': _orange},
      {'day': '2/21', 'cost': 250.0, 'color': _orange},
      {'day': '2/22', 'cost': 250.0, 'color': _orange},
      {'day': '2/23', 'cost': 450.0, 'color': _orange},
      {'day': '2/24', 'cost': 1310.0, 'color': _orange},
    ];

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
                  // Horizontal grid lines (no value labels)
                  ...List.generate(4, (i) {
                    final y = h - (i / 3) * h * 0.75 - h * 0.1;
                    return Positioned(
                      top: y - 8,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: _divider,
                      ),
                    );
                  }),

                  // Chart area (full width)
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
                          style: const TextStyle(
                              fontSize: 7, color: _textMid,
                              fontWeight: FontWeight.w600),
                        ),
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
                          style: const TextStyle(fontSize: 8, color: _textMid),
                        ),
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
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10,
              fontWeight: FontWeight.w800)),
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
              blurRadius: 10, offset: const Offset(0, 3))
        ],
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
      if (tapAngle >= currentAngle && tapAngle < currentAngle + sweepAngle) return;
      currentAngle += sweepAngle;
    }
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
    final innerRadius = radius * 0.6;
    int total = data.fold(0, (s, i) => s + (i['value'] as int));
    double startAngle = -pi / 2;

    for (var item in data) {
      final sweepAngle = (item['value'] / total) * 2 * pi;
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(center.dx + innerRadius * cos(startAngle),
            center.dy + innerRadius * sin(startAngle))
        ..lineTo(center.dx + radius * cos(startAngle),
            center.dy + radius * sin(startAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: radius),
            startAngle, sweepAngle, false)
        ..lineTo(center.dx + innerRadius * cos(startAngle + sweepAngle),
            center.dy + innerRadius * sin(startAngle + sweepAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: innerRadius),
            startAngle + sweepAngle, -sweepAngle, false)
        ..close();
      canvas.drawPath(path, paint);

      final gapPaint = Paint()
        ..color = gapColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, gapPaint);

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
