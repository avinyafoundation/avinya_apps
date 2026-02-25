import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/attendance/lib/widgets/common/drop_down.dart';
import 'package:gallery/avinya/attendance/lib/widgets/common/date_picker.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _AttendanceDashboardScreenState createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  // Backend data lists
  List<dynamic> _fetchedPieChartData = [];
  List<dynamic> _fetchedWeeklyStudentData = [];
  List<dynamic> _fetchedWeeklyStaffData = [];
  Organization? _fetchedOrganization;
  List<Organization> _fetchedOrganizations = [];
  List<Organization> _batchData = [];
  int organizationId = 2;

  // Loading state
  bool _isFetching = true;

  // Selected values
  Organization? _selectedOrganizationValue;
  String _selectedMonth = '';
  String _selectedYear = '';
  String _selectedDate = '';

  // parent organization id for API calls
  int? _parentOrgId;

  // Date variables
  DateTime today = DateTime.now();
  String batchStartDate = "";
  String batchEndDate = "";

  // Attendance totals
  int totalStudentCount = 0;
  int totalAttendance = 0;

  // Class-wise attendance data
  List<Map<String, dynamic>> _classData = [];

  // Late attendance data (fetched from backend)
  List<dynamic> _fetchedLateAttendanceData = [];
  List<Map<String, dynamic>> _lateAttendanceData = [];
  final List<Color> _lateAttendanceColors = [
    const Color(0xFF2ECC71), // Green
    const Color(0xFF3498DB), // Blue
    const Color(0xFFF39C12), // Orange
    const Color(0xFFE67E22), // Deep Orange
    const Color(0xFFE74C3C), // Red
  ];
  final List<String> _lateAttendanceLabels = [
    'Before 07:30',
    '07:30 - 07:45',
    '07:45 - 08:00',
    '08:00 - 08:30',
    'After 08:30',
  ];

  // Pagination for charts
  int _studentChartPage = 0;
  int _staffChartPage = 0;
  final int _itemsPerPage = 5;

  // Hover state tracking for class cards
  Map<String, bool> _hoveredCards = {};

  // Pie chart hover tracking
  String? _hoveredPieSegment;

  // Scroll controller to maintain scroll position
  final ScrollController _scrollController = ScrollController();

  // Month and year lists
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final List<String> _years = List.generate(
    DateTime.now().year - 2026 + 1,
    (index) => (2026 + index).toString(),
  );

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    _selectedMonth = _months[today.month - 1];
    _selectedYear = today.year.toString();
    _selectedDate = DateFormat('yyyy-MM-dd').format(today);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isFetching = true;
    });

    try {
      // Load batch data
      _batchData = await fetchOrganizationsByAvinyaTypeAndStatus(null, null);
      _selectedOrganizationValue =
          _batchData.isNotEmpty ? _batchData.last : null;

      if (_selectedOrganizationValue != null) {
        // Get batch start and end dates
        batchStartDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
            _selectedOrganizationValue!.organization_metadata[0].value
                .toString()));
        batchEndDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
            _selectedOrganizationValue!.organization_metadata[1].value
                .toString()));

        // Fetch organization and child organizations
        int orgId = _selectedOrganizationValue!.id!;
        _fetchedOrganization = await fetchOrganization(orgId);
        _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      }

      // Load attendance data for today
      await _loadAttendanceData();
    } catch (error) {
      print('Error loading initial data: $error');
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isFetching = true;
    });

    try {
      int? parentOrgId =
          campusAppsPortalInstance.getUserPerson().organization!.id;
      _parentOrgId = parentOrgId; // save for later taps

      // Calculate start date as the first day of selected month
      int monthIndex = _months.indexOf(_selectedMonth) + 1;
      int year = int.parse(_selectedYear);
      DateTime startDate =
          DateTime(year, monthIndex, 1); // First day of the month

      // Calculate end date as the last day of selected month
      DateTime endDate =
          DateTime(year, monthIndex + 1, 0); // Last day of the month

      String endDateFormatted = DateFormat('yyyy-MM-dd').format(endDate);
      String startDateFormatted = DateFormat('yyyy-MM-dd').format(startDate);

      // Fetch attendance pie chart data for selected date
      _fetchedPieChartData =
          await getDailyStudentsAttendanceByParentOrg(parentOrgId);
      totalStudentCount = calculateTotalStudentCount(_fetchedPieChartData);
      totalAttendance = calculateTotalAttendance(_fetchedPieChartData);

      // Fetch class-wise data for selected date
      await _loadClassWiseData(parentOrgId, _selectedDate);

      // Fetch weekly student attendance data (using selected month date range)
      if (_selectedOrganizationValue != null) {
        _fetchedWeeklyStudentData = await getDailyAttendanceSummaryReport(
          _selectedOrganizationValue!
              .id!, //_selectedOrganizationValue!.id! (44 before)
          110, // activity type for students  (110) (37 before)
          startDateFormatted,
          endDateFormatted,
        );

        _fetchedWeeklyStaffData = await getDailyEmployeeAttendanceSummaryReport(
          organizationId,
          startDateFormatted,
          endDateFormatted,
        );

        // Fetch late attendance summary for selected date (defaults to today)
        if (parentOrgId != null) {
          String queryDate = _selectedDate;
          _fetchedLateAttendanceData =
              await getLateAttendanceSummary(parentOrgId, queryDate, 4);
          _lateAttendanceData = [];
          for (var item in _fetchedLateAttendanceData) {
            String label = item['label'] ?? '';
            int value = item['student_count'] ?? 0;
            String rawNames = item['student_name'] ?? '';
            List<String> students = rawNames
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

            // determine color index based on predefined label order
            int labelIndex = _lateAttendanceLabels.indexOf(label);
            if (labelIndex == -1) {
              // fallback to sequential order if label isn't recognized
              labelIndex = _lateAttendanceData.length;
            }
            Color color = _lateAttendanceColors[
                labelIndex % _lateAttendanceColors.length];
            _lateAttendanceData.add({
              'label': label,
              'value': value,
              'color': color,
              'students': students,
            });
          }

          // ensure the data respects the fixed label ordering
          _lateAttendanceData.sort((a, b) {
            int ia = _lateAttendanceLabels.indexOf(a['label']);
            int ib = _lateAttendanceLabels.indexOf(b['label']);
            return ia.compareTo(ib);
          });
        }
      }

      setState(() {
        _isFetching = false;
        _studentChartPage = 0;
        _staffChartPage = 0;
      });
    } catch (error) {
      print('Error loading attendance data: $error');
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _loadClassWiseData(int? parentOrgId, String date) async {
    // This assumes you have class-wise attendance data in _fetchedOrganizations
    List<Map<String, dynamic>> classDataList = [];

    // Define emoji mapping for classes
    Map<String, String> classEmojis = {
      'Bees': '🐝',
      'Zebras': '🦓',
      'Dolphins': '🐬',
      'Leopards': '🐆',
      'Bears': '🐻',
      'Eagles': '🦅',
      'Sharks': '🦈',
      'Penguins': '🐧',
    };

    print('DEBUG - Using parent org data: $_fetchedPieChartData');
    print(
        'DEBUG - Available organizations: ${_fetchedOrganizations.map((o) => '${o.description} (ID: ${o.id})').toList()}');

    // If we have attendance data from the parent organization
    if (_fetchedPieChartData.isNotEmpty) {
      for (var org in _fetchedOrganizations) {
        String className = org.description ?? org.name?.name_en ?? 'Unknown';

        // Find matching attendance data by class name/description
        dynamic matchingAttendance;
        try {
          matchingAttendance = _fetchedPieChartData.firstWhere(
            (attendance) {
              if (attendance is ActivityAttendance) {
                return attendance.description == className;
              } else if (attendance is Map<String, dynamic>) {
                return attendance['description'] == className;
              }
              return false;
            },
          );
        } catch (e) {
          // No matching attendance found
          matchingAttendance = null;
        }

        int classTotal = 0;
        int classPresent = 0;

        if (matchingAttendance != null) {
          if (matchingAttendance is ActivityAttendance) {
            classTotal = matchingAttendance.total_student_count ?? 0;
            classPresent = matchingAttendance.present_count ?? 0;
          } else if (matchingAttendance is Map<String, dynamic>) {
            classTotal =
                (matchingAttendance['total_student_count'] as int?) ?? 0;
            classPresent = (matchingAttendance['present_count'] as int?) ?? 0;
          }
        }

        print(
            'DEBUG - Class: $className, Total: $classTotal, Present: $classPresent');

        classDataList.add({
          'name': className,
          'emoji': classEmojis[className] ?? '📚',
          'total': classTotal,
          'present': classPresent,
        });
      }
    } else {
      // Fallback: create empty entries for all organizations
      for (var org in _fetchedOrganizations) {
        String className = org.description ?? org.name?.name_en ?? 'Unknown';

        classDataList.add({
          'name': className,
          'emoji': classEmojis[className] ?? '📚',
          'total': 0,
          'present': 0,
        });
      }
    }

    setState(() {
      _classData = classDataList;
    });
  }

  int calculateTotalStudentCount(List<dynamic> fetchedPieChartData) {
    int totalStudentCount = 0;
    for (var activityAttendance in fetchedPieChartData) {
      if (activityAttendance is ActivityAttendance) {
        int count = activityAttendance.total_student_count ?? 0;
        totalStudentCount += count;
      } else if (activityAttendance is Map<String, dynamic>) {
        int count = (activityAttendance['total_student_count'] as int?) ?? 0;
        totalStudentCount += count;
      } else {
        print('DEBUG - Unknown type: ${activityAttendance.runtimeType}');
      }
    }
    return totalStudentCount;
  }

  int calculateTotalAttendance(List<dynamic> fetchedPieChartData) {
    int totalAttendance = 0;
    for (var activityAttendance in fetchedPieChartData) {
      if (activityAttendance is ActivityAttendance) {
        totalAttendance += activityAttendance.present_count ?? 0;
      } else if (activityAttendance is Map<String, dynamic>) {
        totalAttendance += (activityAttendance['present_count'] as int?) ?? 0;
      }
    }
    return totalAttendance;
  }

  List<Map<String, dynamic>> _prepareWeeklyStudentChartData() {
    // Transform backend data to chart format
    List<Map<String, dynamic>> chartData = [];

    // Calculate pagination
    int startIndex = _studentChartPage * _itemsPerPage;
    int endIndex =
        (startIndex + _itemsPerPage).clamp(0, _fetchedWeeklyStudentData.length);

    if (startIndex >= _fetchedWeeklyStudentData.length) {
      return chartData;
    }

    for (int i = startIndex; i < endIndex; i++) {
      var dayData = _fetchedWeeklyStudentData[i];

      // Parse the data based on your backend structure
      // Adjust these field names according to your actual data structure
      chartData.add({
        'day': _formatDayLabel(dayData.sign_in_date ?? ''),
        'date': dayData.sign_in_date ?? '',
        'academyPresent': dayData.present_count ?? 0,
        'academyAbsent': dayData.absent_count ?? 0,
      });
    }

    return chartData;
  }

  List<Map<String, dynamic>> _prepareWeeklyStaffChartData() {
    // Transform backend data to chart format
    List<Map<String, dynamic>> chartData = [];

    // Calculate pagination
    int startIndex = _staffChartPage * _itemsPerPage;
    int endIndex =
        (startIndex + _itemsPerPage).clamp(0, _fetchedWeeklyStaffData.length);

    if (startIndex >= _fetchedWeeklyStaffData.length) {
      return chartData;
    }

    for (int i = startIndex; i < endIndex; i++) {
      var dayData = _fetchedWeeklyStaffData[i];

      chartData.add({
        'day': _formatDayLabel(dayData.sign_in_date ?? ''),
        'date': dayData.sign_in_date ?? '',
        'present': dayData.present_count ?? 0,
        'absent': dayData.absent_count ?? 0,
      });
    }

    return chartData;
  }

  String _formatDayLabel(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('EEE d\'th\' MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    bool isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1600),
                padding: EdgeInsets.all(isMobile ? 20 : 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Batch Filter
                    _buildBatchFilter(),
                    const SizedBox(height: 30),

                    // Top Summary Cards
                    if (isMobile || isTablet)
                      Column(
                        children: [
                          _buildTodayAttendanceCard(),
                          const SizedBox(height: 25),
                          _buildLateAttendanceCard(), // Moved here for mobile stacking
                          const SizedBox(height: 25),
                          _buildClassWiseAttendanceCard(),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Today's Total + Late Analysis
                          Expanded(
                            child: Column(
                              children: [
                                _buildTodayAttendanceCard(),
                                const SizedBox(height: 25),
                                _buildLateAttendanceCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 25),
                          // Right Column: Class-wise Attendance
                          Expanded(child: _buildClassWiseAttendanceCard()),
                        ],
                      ),
                    const SizedBox(height: 25),

                    // Month and Year Filters
                    _buildDateFilters(),
                    const SizedBox(height: 20),

                    // Weekly Student Attendance Chart
                    _buildWeeklyStudentChartCard(),
                    const SizedBox(height: 25),

                    // Weekly Staff Attendance Chart
                    _buildWeeklyStaffChartCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Loading overlay
          if (_isFetching)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SpinKitCircle(
                    color: Colors.blueAccent,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatchFilter() {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: CustomDatePicker(
            label: 'Select Date',
            selectedDateString: _selectedDate,
            lastDate: DateTime.now(),
            onDateSelected: (selectedDate) {
              setState(() {
                _selectedDate = selectedDate;
              });
              _loadAttendanceData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: DropDown<String>(
            label: 'Month',
            items: _months,
            selectedValues: _months.indexOf(_selectedMonth),
            valueField: (month) => _months.indexOf(month),
            displayField: (month) => month,
            onChanged: (index) {
              if (index != null) {
                setState(() {
                  _selectedMonth = _months[index];
                });
                _loadAttendanceData();
              }
            },
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 120,
          child: DropDown<String>(
            label: 'Year',
            items: _years,
            selectedValues: _years.indexOf(_selectedYear),
            valueField: (year) => _years.indexOf(year),
            displayField: (year) => year,
            onChanged: (index) {
              if (index != null) {
                setState(() {
                  _selectedYear = _years[index];
                });
                _loadAttendanceData();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAttendanceCard() {
    double percentage =
        totalStudentCount > 0 ? (totalAttendance / totalStudentCount) * 100 : 0;

    return Container(
      height: 417.5,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
            ),
            child: Text(
              "Student Attendance - ${DateFormat('MMM d, yyyy').format(DateTime.parse(_selectedDate))}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Attendance Circle
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 20,
                          backgroundColor: const Color(0xFFECF0F1),
                          valueColor:
                              const AlwaysStoppedAnimation(Color(0xFFECF0F1)),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 20,
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
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            'of $totalStudentCount',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Students Present',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassWiseAttendanceCard() {
    return Container(
      height: 860,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
            ),
            child: Text(
              'Class-wise Attendance - ${DateFormat('MMM d, yyyy').format(DateTime.parse(_selectedDate))}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Class Items
          _classData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No class data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: _classData.map((classInfo) {
                    return _buildClassItem(
                      emoji: classInfo['emoji'],
                      className: classInfo['name'],
                      totalStudents: classInfo['total'],
                      presentCount: classInfo['present'],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildClassItem({
    required String emoji,
    required String className,
    required int totalStudents,
    required int presentCount,
  }) {
    bool isHovered = _hoveredCards[className] ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredCards[className] = true),
      onExit: (_) => setState(() => _hoveredCards[className] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0),
        child: InkWell(
          onTap: () => _showAbsentStudentsDialog(
              className, totalStudents - presentCount),
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0xFFE3F2FD),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFF1BB6E8), width: 4),
              ),
            ),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Class Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: $totalStudents Students',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Present Count
                Text(
                  '$presentCount',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1BB6E8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAbsentStudentsDialog(String title, int absentCount,
      {String? date, List<String>? studentNames}) {
    // prepare list either from provided names or dummy
    List<Map<String, String>> absentStudents;
    if (studentNames != null && studentNames.isNotEmpty) {
      absentStudents = studentNames.map((n) => {'name': n, 'id': ''}).toList();
    } else {
      // Dummy data for absent students
      absentStudents = List.generate(
        absentCount,
        (index) => {
          'name': 'Student ${index + 1}',
          'id': 'ST${(1000 + index).toString()}',
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 450),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date != null ? '$title - $date' : title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date != null
                                ? '$absentCount students absent'
                                : '$absentCount students absent today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Student List
                absentCount == 0
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All students are present!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: absentStudents.length,
                          itemBuilder: (context, index) {
                            final student = absentStudents[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFE0E0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE74C3C),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        student['name']!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                        // const SizedBox(height: 2),
                                        // Text(
                                        //   'ID: ${student['id']}',
                                        //   style: TextStyle(
                                        //     fontSize: 13,
                                        //     color: Colors.grey[600],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE74C3C),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Absent',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
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
        );
      },
    );
  }

  Widget _buildWeeklyStudentChartCard() {
    List<Map<String, dynamic>> chartData = _prepareWeeklyStudentChartData();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Student Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  '${_selectedMonth} ${_selectedYear}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1BB6E8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildLegendItem(const Color(0xFF2ECC71), 'Student Present'),
              _buildLegendItem(const Color(0xFFE74C3C), 'Student Absent'),
            ],
          ),
          const SizedBox(height: 25),

          // Chart
          chartData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'No student attendance data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 330,
                  child: _buildStackedBarChart(chartData, 'student'),
                ),

          // Navigation buttons
          if (_fetchedWeeklyStudentData.length > _itemsPerPage)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _studentChartPage > 0
                        ? () {
                            setState(() {
                              _studentChartPage--;
                            });
                          }
                        : null,
                    tooltip: 'Previous',
                  ),
                  Text(
                    'Page ${_studentChartPage + 1} of ${(_fetchedWeeklyStudentData.length / _itemsPerPage).ceil()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (_studentChartPage + 1) * _itemsPerPage <
                            _fetchedWeeklyStudentData.length
                        ? () {
                            setState(() {
                              _studentChartPage++;
                            });
                          }
                        : null,
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStaffChartCard() {
    List<Map<String, dynamic>> chartData = _prepareWeeklyStaffChartData();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Staff Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  '${_selectedMonth} ${_selectedYear}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1BB6E8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildLegendItem(const Color(0xFF3498DB), 'Employee Present'),
              _buildLegendItem(const Color(0xFFE74C3C), 'Employee Absent'),
            ],
          ),
          const SizedBox(height: 25),

          // Chart
          chartData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'No staff attendance data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 330,
                  child: _buildStackedBarChart(chartData, 'staff'),
                ),

          // Navigation buttons
          if (_fetchedWeeklyStaffData.length > _itemsPerPage)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _staffChartPage > 0
                        ? () {
                            setState(() {
                              _staffChartPage--;
                            });
                          }
                        : null,
                    tooltip: 'Previous',
                  ),
                  Text(
                    'Page ${_staffChartPage + 1} of ${(_fetchedWeeklyStaffData.length / _itemsPerPage).ceil()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (_staffChartPage + 1) * _itemsPerPage <
                            _fetchedWeeklyStaffData.length
                        ? () {
                            setState(() {
                              _staffChartPage++;
                            });
                          }
                        : null,
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStackedBarChart(
      List<Map<String, dynamic>> data, String chartType) {
    // Calculate max value dynamically based on the data
    double maxValue = 0;
    for (var item in data) {
      double total = 0;
      if (chartType == 'student') {
        total = (item['academyPresent'] ?? 0).toDouble() +
            (item['academyAbsent'] ?? 0).toDouble();
      } else {
        total = (item['present'] ?? 0).toDouble() +
            (item['absent'] ?? 0).toDouble();
      }
      if (total > maxValue) maxValue = total;
    }

    // Round up to nearest 10 for better scale
    maxValue = ((maxValue / 10).ceil() * 10).toDouble();
    if (maxValue < 10) maxValue = 10;

    // Generate Y-axis labels dynamically
    int labelCount = 8;
    List<int> yAxisLabels = [];
    for (int i = 0; i < labelCount; i++) {
      yAxisLabels.add((maxValue * (1 - i / (labelCount - 1))).round());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double chartWidth = constraints.maxWidth - 60;
        double barWidth = (chartWidth / data.length) * 0.6;
        if (barWidth > 50) barWidth = 50;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis
            SizedBox(
              width: 40,
              height: 280,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: yAxisLabels.map((value) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Chart area
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        // Grid lines
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: yAxisLabels.map((value) {
                              return Container(
                                height: 1,
                                color: Colors.grey[200],
                              );
                            }).toList(),
                          ),
                        ),
                        // Bars
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: data.map((item) {
                            return _buildStackedBar(
                              item,
                              chartType,
                              maxValue,
                              barWidth,
                              onTap: (chartType == 'student' ||
                                      chartType == 'staff')
                                  ? () async {
                                      int absentCount = chartType == 'student'
                                          ? (item['academyAbsent'] ?? 0) as int
                                          : (item['absent'] ?? 0) as int;
                                      String rawDate = item['date'] ?? '';
                                      List<String> names = [];
                                      try {
                                        int? orgId = _parentOrgId;
                                        int activityId =
                                            chartType == 'student' ? 4 : 1;
                                        int? parentId = chartType == 'staff'
                                            ? _parentOrgId
                                            : null;
                                        if (orgId != null) {
                                          names = await getDailyAbsenceSummary(
                                              orgId, activityId, rawDate,
                                              parentOrgId: parentId);
                                        }
                                      } catch (e) {
                                        print('Error fetching absentees: $e');
                                      }
                                      _showAbsentStudentsDialog(
                                        chartType == 'student'
                                            ? 'Students'
                                            : 'Employees',
                                        absentCount,
                                        date: rawDate,
                                        studentNames: names,
                                      );
                                    }
                                  : null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // X-axis labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: data.map((item) {
                      return SizedBox(
                        width: barWidth,
                        child: Text(
                          item['day'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStackedBar(Map<String, dynamic> data, String chartType,
      double maxValue, double barWidth,
      {VoidCallback? onTap}) {
    List<_BarSegment> segments = [];
    String dayLabel = data['day'];

    if (chartType == 'student') {
      segments = [
        _BarSegment((data['academyPresent'] ?? 0).toDouble(),
            const Color(0xFF2ECC71), 'Student Present'),
        _BarSegment((data['academyAbsent'] ?? 0).toDouble(),
            const Color(0xFFE74C3C), 'Student Absent'),
      ];
    } else {
      segments = [
        _BarSegment((data['present'] ?? 0).toDouble(), const Color(0xFF3498DB),
            'Employee Present'),
        _BarSegment((data['absent'] ?? 0).toDouble(), const Color(0xFFE74C3C),
            'Employee Absent'),
      ];
    }

    double cumulativeHeight = 0;
    List<Widget> barParts = [];

    for (int i = 0; i < segments.length; i++) {
      _BarSegment segment = segments[i];
      if (segment.value == 0) continue;

      double segmentHeight = (segment.value / maxValue) * 280;

      barParts.add(
        Positioned(
          bottom: cumulativeHeight,
          left: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: '$dayLabel\n${segment.label}: ${segment.value.toInt()}',
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: segmentHeight,
                decoration: BoxDecoration(
                  color: segment.color,
                  borderRadius: i == segments.length - 1
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );

      cumulativeHeight += segmentHeight;
    }

    Widget barWidget = Container(
      width: barWidth,
      height: 280,
      child: Stack(
        children: barParts,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: barWidget,
        ),
      );
    }

    return barWidget;
  }

  // helper that renders a single entry as a horizontal bar with the count at the end
  Widget _buildBarLegendItem(Map<String, dynamic> item, int total) {
    int value = item['value'] as int;
    Color color = item['color'] as Color;
    String label = item['label'] as String;
    double fraction = total > 0 ? value / total : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: square + label
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // bar row
          Row(
            children: [
              const SizedBox(width: 28), // align with label start after square
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3), // lighter background
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  void _handlePieChartHover(
      Offset localPosition, List<Map<String, dynamic>> data, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = size / 2;
    final innerRadius = radius * 0.6;

    // Check if hover is within the donut ring
    if (distance < innerRadius || distance > radius) {
      if (_hoveredPieSegment != null) {
        setState(() {
          _hoveredPieSegment = null;
        });
      }
      return;
    }

    // Calculate the angle of the hover
    double hoverAngle = atan2(dy, dx);
    // Normalize to 0-2π range
    if (hoverAngle < 0) hoverAngle += 2 * pi;
    // Adjust for start angle (-90 degrees = -π/2)
    hoverAngle = (hoverAngle + pi / 2) % (2 * pi);

    // Find which segment is hovered
    int total = data.fold(0, (sum, item) => sum + (item['value'] as int));
    double currentAngle = 0;

    for (var item in data) {
      final value = item['value'] as int;
      final sweepAngle = (value / total) * 2 * pi;

      if (hoverAngle >= currentAngle &&
          hoverAngle < currentAngle + sweepAngle) {
        String label = '${item['label']}: $value students';
        if (_hoveredPieSegment != label) {
          setState(() {
            _hoveredPieSegment = label;
          });
        }
        return;
      }

      currentAngle += sweepAngle;
    }
  }

  void _handlePieChartTap(
      Offset localPosition, List<Map<String, dynamic>> data, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = size / 2;
    final innerRadius = radius * 0.6;

    // Check if tap is within the donut ring
    if (distance < innerRadius || distance > radius) {
      return;
    }

    // Calculate the angle of the tap
    double tapAngle = atan2(dy, dx);
    // Normalize to 0-2π range
    if (tapAngle < 0) tapAngle += 2 * pi;
    // Adjust for start angle (-90 degrees = -π/2)
    tapAngle = (tapAngle + pi / 2) % (2 * pi);

    // Find which segment was tapped
    int total = data.fold(0, (sum, item) => sum + (item['value'] as int));
    double currentAngle = 0;

    for (var item in data) {
      final value = item['value'] as int;
      final sweepAngle = (value / total) * 2 * pi;

      if (tapAngle >= currentAngle && tapAngle < currentAngle + sweepAngle) {
        // This segment was tapped
        _showStudentsByTimeRange(item['label'] as String, value);
        return;
      }

      currentAngle += sweepAngle;
    }
  }

  void _showStudentsByTimeRange(String timeRange, int studentCount) {
    // look up student names returned by backend for this time range
    List<String> names = [];
    for (var entry in _lateAttendanceData) {
      if (entry['label'] == timeRange) {
        if (entry['students'] is List<String>) {
          names = List<String>.from(entry['students']);
        }
        break;
      }
    }
    List<Map<String, String>> students;
    if (names.isNotEmpty) {
      students = names.map((n) => {'name': n, 'id': ''}).toList();
    } else {
      // fallback to empty list
      students = [];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 450),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Students - $timeRange',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$studentCount students in this time range',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Student List
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F9FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE3F2FD),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  student['name']!
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name']!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if ((student['id'] ?? '').isNotEmpty)
                                    Text(
                                      'ID: ${student['id']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
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
        );
      },
    );
  }

  Widget _buildLateAttendanceCard() {
    // use only the real data fetched earlier; if list empty show placeholder
    List<Map<String, dynamic>> lateAttendanceData = _lateAttendanceData;
    if (lateAttendanceData.isEmpty) {
      return Container(
        height: 417.5,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No late attendance data available for ${DateFormat('MMM d, yyyy').format(DateTime.parse(_selectedDate))}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }

    int totalStudents =
        lateAttendanceData.fold(0, (sum, item) => sum + (item['value'] as int));

    return Container(
      height: 417.5,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Late Attendance Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMM d').format(DateTime.parse(_selectedDate)),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 58),

          // Pie Chart and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: GestureDetector(
                      onTapUp: (TapUpDetails details) {
                        _handlePieChartTap(
                            details.localPosition, lateAttendanceData, 220);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onHover: (event) {
                          _handlePieChartHover(
                              event.localPosition, lateAttendanceData, 220);
                        },
                        onExit: (_) {
                          setState(() {
                            _hoveredPieSegment = null;
                          });
                        },
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: _PieChartPainter(lateAttendanceData),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$totalAttendance',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const Text(
                                      'Students',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF7F8C8D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Hover tooltip
                            if (_hoveredPieSegment != null)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C3E50),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _hoveredPieSegment!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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

              const SizedBox(width: 30),

              // Legend: show each range as a horizontal bar with count at end
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lateAttendanceData.map((item) {
                    return _buildBarLegendItem(item, totalStudents);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarSegment {
  final double value;
  final Color color;
  final String label;

  _BarSegment(this.value, this.color, this.label);
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6; // Donut chart

    int total = data.fold(0, (sum, item) => sum + (item['value'] as int));
    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (var item in data) {
      final value = item['value'] as int;
      final color = item['color'] as Color;
      final sweepAngle = (value / total) * 2 * 3.14159;

      // Outer arc
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(
        center.dx + innerRadius * cos(startAngle),
        center.dy + innerRadius * sin(startAngle),
      );
      path.lineTo(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      path.lineTo(
        center.dx + innerRadius * cos(startAngle + sweepAngle),
        center.dy + innerRadius * sin(startAngle + sweepAngle),
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
