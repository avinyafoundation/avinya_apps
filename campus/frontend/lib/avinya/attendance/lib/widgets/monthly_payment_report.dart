import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:attendance/widgets/week_picker.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_calender.dart';
import 'package:gallery/avinya/attendance/lib/widgets/monthly_payment_report_excel_export.dart';
import 'package:gallery/avinya/attendance/lib/widgets/common/drop_down.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:month_year_picker/month_year_picker.dart';

class MonthlyPaymentReport extends StatefulWidget {
  const MonthlyPaymentReport({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MonthlyPaymentReport> createState() => _MonthlyPaymentReportState();
}

class _MonthlyPaymentReportState extends State<MonthlyPaymentReport> {
  List<ActivityAttendance> _fetchedAttendance = [];
  List<ActivityAttendance> _fetchedExcelReportData = [];
  List<Person> _fetchedStudentList = [];
  Organization? _fetchedOrganization;
  bool _isFetching = true;
  bool _isFetchingClassPaymentData = false;
  int organization_id = 0;
  double? MonthlyPayment = 0.00;
  DateTime? _selectedDay;
  DateTime? _selected = DateTime.now();
  late DateTime firstDateOfMonth;
  late DateTime lastDateOfMonth;

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  late DataTableSource _data;
  List<String?> columnNames = [];
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;

  late String formattedStartDate;
  late String formattedEndDate;
  var today = DateTime.now();

  List<Organization> _batchData = [];
  Organization? _selectedOrganizationValue;
  BatchPaymentPlan? _batchPaymentPlan;
  List<Organization> _fetchedOrganizations = [];
  late Future<List<Organization>> _fetchBatchData;

  late int _totalDaysInMonth;
  late int _totalSchoolDaysInMonth = 0;
  late String _monthFullName = "";
  late double _dailyAmount = 0.0;
  List<String> monthDateList = [];

  List<String?> classes = [];
  Set<String> fetchedLeaveDates = {};

  void selectedYearAndMonth(int year, int month) async {
    setState(() {
      _year = year;
      _month = month;
    });
  }

  @override
  void initState() {
    super.initState();
    _year = _selected?.year ?? _year;
    _month = _selected?.month ?? _month;
    firstDateOfMonth = DateTime(today.year, today.month, 1);
    lastDateOfMonth =
        DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1));
    organization_id =
        campusAppsPortalInstance.getUserPerson().organization!.id!;
    _fetchBatchData = _loadBatchData();

    activityId = campusAppsPortalInstance.activityIds['homeroom']!;
  }

  Future<List<Organization>> _loadBatchData() async {
    // _batchData = await fetchActiveOrganizationsByAvinyaType();
    _batchData = await fetchOrganizationsByAvinyaTypeAndStatus(null, 1);
    _selectedOrganizationValue = _batchData.isNotEmpty ? _batchData.last : null;
    if (_selectedOrganizationValue != null) {
      _loadInitialData();
    }
    return _batchData;
  }

  void _loadInitialData() async {
    if (_selectedOrganizationValue != null) {
      int orgId = _selectedOrganizationValue!.id!;
      _fetchedOrganization = await fetchOrganization(orgId);
      _batchPaymentPlan = await fetchBatchPaymentPlanByOrgId(organization_id,
          orgId, DateFormat('yyyy-MM-dd').format(firstDateOfMonth));
      MonthlyPayment = _batchPaymentPlan!.monthly_payment_amount ?? 0.0;
      _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      classes = _fetchedOrganizations.map((org) => org.description).toList();
      _fetchLeaveDates(_year, _month);
      _fetchedExcelReportData = await getActivityAttendanceReportByBatch(
          _selectedOrganizationValue!.id!,
          activityId,
          DateFormat('yyyy-MM-dd').format(firstDateOfMonth),
          DateFormat('yyyy-MM-dd').format(lastDateOfMonth));
      _fetchedStudentList =
          await fetchStudentListByBatchId(_selectedOrganizationValue!.id!);
      setState(() {
        _selectedOrganizationValue;
        _fetchedOrganizations = _fetchedOrganizations;
        this._fetchedExcelReportData = _fetchedExcelReportData;
        this._fetchedStudentList = _fetchedStudentList;
        this._isFetching = false;
      });
    }
  }

  Future<void> _fetchLeaveDates(int year, int month) async {
    try {
      // Fetch leave dates and payment details for the month
      List<LeaveDate> leaveDates = await getLeaveDatesForMonth(
          year, month, organization_id, _selectedOrganizationValue!.id!);

      fetchedLeaveDates = leaveDates
          .map((leaveDate) => leaveDate.date.toIso8601String().split("T")[0])
          .toSet();

      _totalDaysInMonth = DateTime(_year, _month + 1, 0).day;
      _totalSchoolDaysInMonth = _totalDaysInMonth - fetchedLeaveDates.length;
      _monthFullName = DateFormat.MMMM().format(DateTime(0, _month));

      setState(() {
        if (leaveDates.isNotEmpty) {
          _dailyAmount = leaveDates.first.dailyAmount;
        } else {
          _dailyAmount = 0.00;
        }
        _data = MyData(
            _fetchedAttendance,
            _fetchedOrganization,
            updateSelected,
            _dailyAmount,
            monthDateList,
            fetchedLeaveDates,
            _totalSchoolDaysInMonth,
            (int rowIndex) => _showStudentMonthDetails(context, rowIndex));
      });
    } catch (e) {
      print("Error fetching leave dates: $e");
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _data = MyData(
        _fetchedAttendance,
        _fetchedOrganization,
        updateSelected,
        _dailyAmount,
        monthDateList,
        fetchedLeaveDates,
        _totalSchoolDaysInMonth,
        (int rowIndex) => _showStudentMonthDetails(context, rowIndex));
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  void _showStudentMonthDetails(BuildContext context, int index) {
    if (_fetchedOrganization == null) return;
    if (index < 0 || index >= (_fetchedOrganization?.people.length ?? 0))
      return;

    final person = _fetchedOrganization!.people[index];
    final DateTime monthDate = _selected ?? DateTime.now();

    // 1. Prepare Data Sets for lookup
    final Set<String> leaveSet = fetchedLeaveDates;
    final Set<String> presentSet = {};

    for (final date in monthDateList) {
      if (leaveSet.contains(date)) continue; // skip closed days
      final hasAttendance = _fetchedAttendance.any((a) =>
          a.person_id == person.id &&
          a.sign_in_time != null &&
          a.sign_in_time!.split(' ')[0] == date);
      if (hasAttendance) presentSet.add(date);
    }

    // demo data: hardcoded absence reasons
    final Map<String, Map<String, String?>> demoAbsentReasons = {
      DateFormat('yyyy-MM-dd')
          .format(DateTime(monthDate.year, monthDate.month, 3)): {
        'reason': 'Illness',
        'notes': null,
      },
      DateFormat('yyyy-MM-dd')
          .format(DateTime(monthDate.year, monthDate.month, 6)): {
        'reason': 'Family emergency',
        'notes': 'Parent informed — family event', // example optional note
      },
      DateFormat('yyyy-MM-dd')
          .format(DateTime(monthDate.year, monthDate.month, 13)): {
        'reason': 'Medical appointment',
        'notes': null,
      },
    };

    // 2. Calendar Metadata
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final int offset = firstDay.weekday - 1; //Monday start

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${person.preferred_name ?? 'Student'} — ${DateFormat.yMMMM().format(monthDate)}',
                  style: const TextStyle(
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
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                color: const Color(0xFF6C757D),
                splashRadius: 16,
              ),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary Row
                Row(
                  children: [
                    _buildStat(
                        'Present',
                        '${presentSet.length} / $_totalSchoolDaysInMonth',
                        const Color(0xFF27AE60)),
                    _buildStat(
                        'Absent',
                        '${_totalSchoolDaysInMonth - presentSet.length} / $_totalSchoolDaysInMonth',
                        const Color(0xFFE74C3C)),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekday Headers
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map((d) => Expanded(
                          child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 12)))))
                      .toList(),
                ),
                const Divider(),

                // Calendar Grid
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: daysInMonth + offset,
                    itemBuilder: (context, gridIndex) {
                      if (gridIndex < offset) return const SizedBox.shrink();

                      final int day = gridIndex - offset + 1;
                      final String dateStr = DateFormat('yyyy-MM-dd').format(
                          DateTime(monthDate.year, monthDate.month, day));

                      Color bgColor = Colors.transparent;
                      Color textColor = const Color(0xFF2C3E50);
                      String label = "";

                      // PRIORITY 1: Academy Closed
                      if (leaveSet.contains(dateStr)) {
                        bgColor = const Color(0xFFF8F9FA); // Very light gray
                        textColor = const Color(0xFF6C757D); // Medium gray
                        label = "Closed";
                      }
                      // PRIORITY 2: Student Present
                      else if (presentSet.contains(dateStr)) {
                        bgColor = const Color(0xFFE8F8F5); // Light Green
                        textColor = const Color(0xFF27AE60); // Dark Green
                      }
                      // PRIORITY 3: Student Absent
                      else {
                        bgColor = const Color(0xFFFFEBEE); // Light Red
                        textColor = const Color(0xFFE74C3C); // Dark Red
                      }

                      final Map<String, String?>? demoEntry =
                          (!leaveSet.contains(dateStr) &&
                                  !presentSet.contains(dateStr))
                              ? demoAbsentReasons[dateStr]
                              : null;
                      final String? demoReason = demoEntry?['reason'];
                      final String? demoNotes = demoEntry?['notes'];

                      final bool isAbsent = !leaveSet.contains(dateStr) &&
                          !presentSet.contains(dateStr);

                      final Widget dayCell = Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            if (label.isNotEmpty)
                              Text(label,
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: textColor,
                                      fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );

                      // If the day is absent, show a hover tooltip only (no add/edit from this screen).
                      if (isAbsent) {
                        return demoReason != null
                            ? Tooltip(
                                message:
                                    demoNotes != null && demoNotes!.isNotEmpty
                                        ? '$demoReason\n\nNotes: ${demoNotes}'
                                        : demoReason!,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C3E50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(color: Colors.white),
                                waitDuration: const Duration(milliseconds: 200),
                                child: dayCell,
                              )
                            : dayCell;
                      }

                      return dayCell;
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

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;

    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
      locale: localeObj,
    );

    if (selected != null) {
      int year = selected.year;
      int month = selected.month;

      // Calculate the start and end dates of the selected month
      final _rangeStart = DateTime(year, month, 1); // First day of the month
      final _rangeEnd = DateTime(year, month + 1, 0); // Last day of the month

      monthDateList = getDatesOfMonth(year, month);

      // Pass the calculated dates to updateDateRange
      updateDateRange(_rangeStart, _rangeEnd);
      setState(() {
        final startDate = _rangeStart ?? _selectedDay;
        final endDate = _rangeEnd ?? _selectedDay;
        final formatter = DateFormat('MMM d, yyyy');
        final formattedStartDate = formatter.format(startDate!);
        final formattedEndDate = formatter.format(endDate!);
        this.formattedStartDate = formattedStartDate;
        this.formattedEndDate = formattedEndDate;
        if (this._selectedValue != null) {
          refreshState(this._selectedValue);
        }
        _selected = selected;
      });
      selectedYearAndMonth(selected.year, selected.month);
    }
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    _fetchLeaveDates(_rangeStart.year, _rangeStart.month);

    if (_selectedOrganizationValue != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        _batchPaymentPlan = await fetchBatchPaymentPlanByOrgId(
            organization_id,
            _selectedOrganizationValue!.id!,
            DateFormat('yyyy-MM-dd').format(_rangeStart));

        MonthlyPayment = _batchPaymentPlan!.monthly_payment_amount ?? 0.0;

        _fetchedExcelReportData = await getActivityAttendanceReportByBatch(
            _selectedOrganizationValue!.id!,
            activityId,
            DateFormat('yyyy-MM-dd').format(_rangeStart),
            DateFormat('yyyy-MM-dd').format(_rangeEnd));
        final fetchedStudentList =
            await fetchStudentListByBatchId(_selectedOrganizationValue!.id!);
        setState(() {
          this._fetchedStudentList = fetchedStudentList;
          this._fetchedExcelReportData = _fetchedExcelReportData;
          _fetchedAttendance;
          MonthlyPayment;
          _batchPaymentPlan;
          _isFetching = false;
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  void refreshState(Organization? newValue) async {
    setState(() {
      _isFetchingClassPaymentData = true;
    });

    _selectedValue = newValue!;

    _fetchedOrganization = await fetchOrganization(newValue.id!);

    _fetchedAttendance = await getClassActivityAttendanceReportForPayment(
        _fetchedOrganization!.id!,
        activityId,
        DateFormat('yyyy-MM-dd')
            .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
        DateFormat('yyyy-MM-dd')
            .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));

    if (_fetchedAttendance.length == 0)
      _fetchedAttendance = new List.filled(_fetchedOrganization!.people.length,
          new ActivityAttendance(person_id: -1));
    else {
      for (int i = 0; i < _fetchedOrganization!.people.length; i++) {
        if (_fetchedAttendance.indexWhere((attendance) =>
                attendance.person_id == _fetchedOrganization!.people[i].id) ==
            -1) {
          _fetchedAttendance.add(new ActivityAttendance(person_id: -1));
        }
      }
    }

    setState(() {
      _fetchedOrganization;
      _fetchedAttendance;
      this._isFetchingClassPaymentData = false;
      _data = MyData(
          _fetchedAttendance,
          _fetchedOrganization,
          updateSelected,
          _dailyAmount,
          monthDateList,
          fetchedLeaveDates,
          _totalSchoolDaysInMonth,
          (int rowIndex) => _showStudentMonthDetails(context, rowIndex));
    });
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> ColumnNames = [];

    ColumnNames.add(DataColumn(
        label: Expanded(
      child: Center(
        child: Text('Name',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50))),
      ),
    )));
    ColumnNames.add(DataColumn(
        label: Expanded(
      child: Center(
        child: Text('NIC',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50))),
      ),
    )));
    ColumnNames.add(DataColumn(
        label: Expanded(
      child: Center(
        child: Text('Present Count',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50))),
      ),
    )));
    ColumnNames.add(DataColumn(
        label: Expanded(
      child: Center(
        child: Text('Absent Count',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50))),
      ),
    )));
    if (campusAppsPortalInstance.isFoundation ||
        campusAppsPortalInstance.isOperations ||
        campusAppsPortalInstance.isFinance) {
      ColumnNames.add(DataColumn(
          label: Expanded(
        child: Center(
          child: Text('Student Payment Rs.',
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50))),
        ),
      )));
    }

    return ColumnNames;
  }

  List<String> getDatesOfMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // last day of month

    List<String> dates = [];

    for (DateTime date = startDate;
        !date.isAfter(endDate);
        date = date.add(const Duration(days: 1))) {
      dates.add(date.toIso8601String().split('T')[0]); // yyyy-MM-dd
    }

    return dates;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child:
          campusAppsPortalPersonMetaDataInstance.getGroups().contains('Student')
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      "Please go to 'Mark Attendance' Page",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters Section
                    _buildFiltersCard(isMobile),
                    const SizedBox(height: 20),

                    // Data Table Section
                    _buildDataTableCard(isMobile),
                  ],
                ),
    );
  }

  Widget _buildFiltersCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 15 : 20),
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
          // Filter Controls (responsive: row on wide screens, stacked on mobile)
          LayoutBuilder(builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 900 && !isMobile;

            // Helper: interactive filter widgets (used in both layouts)
            final interactiveFilters = [
              if (_fetchedOrganizations.isNotEmpty)
                SizedBox(
                  width: isMobile ? double.infinity : 200,
                  child: DropDown<Organization>(
                    label: 'Select Class',
                    items: _fetchedOrganizations,
                    selectedValues: _selectedValue?.id,
                    valueField: (org) => org.id!,
                    displayField: (org) => org.description ?? '',
                    onChanged: (value) async {
                      if (value == null) return;
                      final newValue = _fetchedOrganizations
                          .firstWhere((org) => org.id == value);
                      _selectedValue = newValue;

                      setState(() {
                        _isFetchingClassPaymentData = true;
                      });
                      _fetchedOrganization =
                          await fetchOrganization(newValue.id!);

                      final _rangeStart = DateTime(_year, _month, 1);
                      final _rangeEnd = DateTime(_year, _month + 1, 0);

                      monthDateList = getDatesOfMonth(_year, _month);

                      _fetchedAttendance =
                          await getClassActivityAttendanceReportForPayment(
                              _fetchedOrganization!.id!,
                              activityId,
                              DateFormat('yyyy-MM-dd').format(_rangeStart),
                              DateFormat('yyyy-MM-dd').format(_rangeEnd));

                      if (_fetchedAttendance.isEmpty) {
                        _fetchedAttendance = List.filled(
                            _fetchedOrganization!.people.length,
                            ActivityAttendance(person_id: -1));
                      } else {
                        for (int i = 0;
                            i < _fetchedOrganization!.people.length;
                            i++) {
                          if (_fetchedAttendance.indexWhere((attendance) =>
                                  attendance.person_id ==
                                  _fetchedOrganization!.people[i].id) ==
                              -1) {
                            _fetchedAttendance
                                .add(ActivityAttendance(person_id: -1));
                          }
                        }
                      }
                      setState(() {
                        _data = MyData(
                            _fetchedAttendance,
                            _fetchedOrganization,
                            updateSelected,
                            _dailyAmount,
                            monthDateList,
                            fetchedLeaveDates,
                            _totalSchoolDaysInMonth,
                            (int rowIndex) =>
                                _showStudentMonthDetails(context, rowIndex));
                        _isFetchingClassPaymentData = false;
                      });
                    },
                  ),
                ),

              // Year & Month Picker
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: InkWell(
                  onTap: () => _onPressed(context: context, locale: 'en'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: const Color(0xFF1BB6E8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selected != null
                            ? DateFormat.yMMMM().format(_selected!).toString()
                            : 'Select Month & Year',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (campusAppsPortalInstance.isOperations ||
                  campusAppsPortalInstance.isFinance)
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveDatePicker(
                              organizationId: organization_id ?? 0,
                              batchId: _selectedOrganizationValue?.id ?? 0,
                              year: _selected?.year ?? _year,
                              month: _selected?.month ?? _month,
                              selectedDay: _selectedDay ?? DateTime.now(),
                              monthlyPaymentAmount: MonthlyPayment ?? 0.0),
                        )).then((value) {
                      setState(() {
                        _isFetchingClassPaymentData = true;
                      });
                      _fetchLeaveDates(_year, _month);
                      setState(() {
                        _isFetchingClassPaymentData = false;
                      });
                    });
                  },
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: const Text('Update Leave Dates'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BB6E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

              // Export Button
              if (campusAppsPortalInstance.isFoundation ||
                  campusAppsPortalInstance.isOperations ||
                  campusAppsPortalInstance.isFinance)
                (_isFetching
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        child: SpinKitCircle(
                          color: const Color(0xFF1BB6E8),
                          size: 30,
                        ),
                      )
                    : MonthlyPaymentReportExcelExport(
                        classes: classes,
                        fetchedAttendance: _fetchedExcelReportData,
                        columnNames: columnNames,
                        fetchedStudentList: _fetchedStudentList,
                        isFetching: _isFetching,
                        totalSchoolDaysInMonth: _totalSchoolDaysInMonth,
                        dailyAmount: _dailyAmount,
                        year: _year,
                        month: _monthFullName,
                        batch: _selectedOrganizationValue?.name?.name_en ?? '',
                      )),
            ];

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: interactive filters (wrap inside Expanded)
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: interactiveFilters,
                    ),
                  ),

                  // Right: summary cards (centered vertically)
                  if (campusAppsPortalInstance.isFoundation ||
                      campusAppsPortalInstance.isOperations ||
                      campusAppsPortalInstance.isFinance)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryCard(
                          icon: Icons.school,
                          iconColor: const Color(0xFFE74C3C),
                          title: 'Total School Days',
                          value: '$_totalSchoolDaysInMonth',
                          valueColor: const Color(0xFFE74C3C),
                          isMobile: false,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          icon: Icons.account_balance_wallet,
                          iconColor: const Color(0xFF27AE60),
                          title: 'Monthly Payment Amount',
                          value:
                              'Rs. ${MonthlyPayment?.toStringAsFixed(2) ?? '0.00'}',
                          valueColor: const Color(0xFF27AE60),
                          isMobile: false,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          icon: Icons.payments,
                          iconColor: const Color(0xFF3498DB),
                          title: 'Daily Payment Amount',
                          value: 'Rs. ${_dailyAmount.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF3498DB),
                          isMobile: false,
                        ),
                      ],
                    ),
                ],
              );
            }

            // Mobile / narrow layout: interactive filters first, summary cards stacked below
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: interactiveFilters,
                ),
                const SizedBox(height: 20),
                if (campusAppsPortalInstance.isFoundation ||
                    campusAppsPortalInstance.isOperations ||
                    campusAppsPortalInstance.isFinance)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSummaryCard(
                        icon: Icons.school,
                        iconColor: const Color(0xFFE74C3C),
                        title: 'Total School Days',
                        value: '$_totalSchoolDaysInMonth',
                        valueColor: const Color(0xFFE74C3C),
                        isMobile: true,
                      ),
                      _buildSummaryCard(
                        icon: Icons.account_balance_wallet,
                        iconColor: const Color(0xFF27AE60),
                        title: 'Monthly Payment Amount',
                        value:
                            'Rs. ${MonthlyPayment?.toStringAsFixed(2) ?? '0.00'}',
                        valueColor: const Color(0xFF27AE60),
                        isMobile: true,
                      ),
                      _buildSummaryCard(
                        icon: Icons.payments,
                        iconColor: const Color(0xFF3498DB),
                        title: 'Daily Payment Amount',
                        value: 'Rs. ${_dailyAmount.toStringAsFixed(2)}',
                        valueColor: const Color(0xFF3498DB),
                        isMobile: true,
                      ),
                    ],
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 15 : 20),
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
          // Card Header
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFECF0F1)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: const Color(0xFF1BB6E8),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  (campusAppsPortalInstance.isFoundation ||
                          campusAppsPortalInstance.isOperations ||
                          campusAppsPortalInstance.isFinance)
                      ? 'Payment Details'
                      : 'Attendance Details',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                if (_selectedValue != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedValue!.description ?? '',
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
          const SizedBox(height: 20),

          // Data Table Content
          if (_isFetchingClassPaymentData)
            Container(
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              child: SpinKitCircle(
                color: const Color(0xFF1BB6E8),
                size: 50,
              ),
            )
          else if (_fetchedAttendance.length > 2)
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dataTableTheme: DataTableThemeData(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                    headingTextStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color(0xFFF5F7FA);
                      }
                      return null;
                    }),
                    dataTextStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tableColumnSpacing = isMobile ? 30.0 : 80.0;
                    final int effectiveRows = (_data.rowCount > 0)
                        ? math.min(22, _data.rowCount)
                        : 1; // avoid zero
                    return ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: _buildDataColumns(),
                        columnSpacing: tableColumnSpacing,
                        horizontalMargin: isMobile ? 15 : 24,
                        rowsPerPage: effectiveRows,
                        showFirstLastButtons: true,
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No attendance data found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please select a class to view payment details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(
      this._fetchedAttendance,
      this._fetchedOrganization,
      this.updateSelected,
      this.DailyPayment,
      this.monthDateList,
      this.monthLeaveDates,
      this.totalSchoolDaysInMonth,
      this.onRowTap);

  final List<ActivityAttendance> _fetchedAttendance;
  final Organization? _fetchedOrganization;
  final Function(int, bool, List<bool>) updateSelected;
  final double? DailyPayment;
  final List<String> monthDateList;
  final Set<String> monthLeaveDates;
  final int totalSchoolDaysInMonth;
  final void Function(int rowIndex) onRowTap;

  @override
  DataRow? getRow(int index) {
    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty) {
      var person = _fetchedOrganization!.people[index];

      // determine whether payment column is shown (must match header logic)
      bool showPayment = campusAppsPortalInstance.isFoundation ||
          campusAppsPortalInstance.isOperations ||
          campusAppsPortalInstance.isFinance;
      int cellCount = showPayment ? 5 : 4;

      List<DataCell> cells = List<DataCell>.filled(cellCount, DataCell.empty);
      cells[0] = DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(person.preferred_name!)));
      cells[1] = DataCell(Center(child: Text(person.nic_no.toString())));

      int presentCount = 0;
      for (final attendance in _fetchedAttendance) {
        if (attendance.person_id == person.id) {
          if (monthLeaveDates
              .contains(attendance.sign_in_time!.split(" ")[0])) {
            continue;
          }
          if (attendance.sign_in_time != null) {
            presentCount++;
          }
        }
      }
      cells[2] = DataCell(Container(
          alignment: Alignment.center,
          child: Text(
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              presentCount.toString())));
      cells[3] = DataCell(Container(
          alignment: Alignment.center,
          child: Text(
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              (totalSchoolDaysInMonth - presentCount).toString())));
      if (showPayment) {
        double studentPayment = (DailyPayment ?? 0.0) * presentCount;
        cells[4] = DataCell(Container(
            alignment: Alignment.center,
            child: Text(
                style: TextStyle(
                  color: const Color(0xFF27AE60),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                studentPayment.toDouble().toStringAsFixed(2))));
      }
      int numItems = _fetchedOrganization!.people.length;
      List<bool> selected = List<bool>.generate(numItems, (int index) => false);
      return DataRow(
        cells: cells,
        onSelectChanged: (value) {
          updateSelected(index, value!, selected);
          try {
            onRowTap(index);
          } catch (_) {}
        },
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.blue.withOpacity(0.05);
          }
          if (index.isEven) {
            return Colors.grey.withOpacity(0.05);
          }
          return null;
        }),
      );
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    if (_fetchedOrganization != null) {
      return _fetchedOrganization?.people.length ?? 0;
    }
    return 0;
  }

  @override
  int get selectedRowCount => 0;
}
