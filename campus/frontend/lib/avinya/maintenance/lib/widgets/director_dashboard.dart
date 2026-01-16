import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/activity_instance.dart';
import '../data/monthly_report.dart';
import '../widgets/tasks_dialog.dart';
import '../widgets/cost_breakdown_dialog.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/chart_card.dart';
import '../widgets/common/page_title.dart';
import '../data/monthly_cost.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class DirectorDashboardScreen extends StatefulWidget {
  const DirectorDashboardScreen({super.key});

  @override
  State<DirectorDashboardScreen> createState() =>
      _DirectorDashboardScreenState();
}

class _DirectorDashboardScreenState extends State<DirectorDashboardScreen> {
  // --- STATE ---
  String? selectedAcademy = "Bandaragama";
  int? selectedOrganizationId = 2;
  int? selectedMonthIndex = DateTime.now().month - 1;
  String? selectedMonth = DateFormat.MMMM().format(DateTime.now());
  String? selectedYear = DateFormat.y().format(DateTime.now());
  bool _isLoading = true;

  // --- THEME CONSTANTS ---
  final Color _primaryText = const Color(0xFF172B4D);
  final Color _secondaryText = const Color(0xFF6B778C);
  final Color _bgLight = const Color(0xFFF4F5F7);
  final double _cardRadius = 12.0;

  List<MonthlyCost> _monthlyCosts = [];
  List<ActivityInstance> _overdueTasks = [];
  MonthlyReport? _summaryReport;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final months = [
      "December",
      "November",
      "October",
      "September",
      "August",
      "July",
      "June",
      "May",
      "April",
      "March",
      "February",
      "January"
    ];
    final monthIndex = months.indexOf(selectedMonth ?? '');
    final month = monthIndex >= 0 ? 12 - monthIndex : DateTime.now().month;

    try {
      final year = int.tryParse(selectedYear ?? '') ?? DateTime.now().year;

      _overdueTasks =
          await fetchOverdueActivityInstance(selectedOrganizationId ?? 2);

      _monthlyCosts = await getMonthlyCostSummary(
        organizationId: 2,
        year: year,
      );

      _summaryReport = await getMonthlyReport(
        organizationId: 2,
        year: year,
        month: month,
      );
    } catch (e) {
      print('Error loading data: $e');
      _overdueTasks = [];
      _monthlyCosts = [];
      _summaryReport = MonthlyReport(
        totalTasks: 0,
        completedTasks: 0,
        inProgressTasks: 0,
        pendingTasks: 0,
        totalCost: 0.0,
        totalUpcomingTasks: 0,
        nextMonthlyEstimatedCost: 0.0,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dataNotReady = _isLoading || _summaryReport == null;
    return Scaffold(
      backgroundColor: _bgLight,
      body: dataNotReady
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryText),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Determine screen size buckets
                bool isDesktop = constraints.maxWidth > 1200;
                bool isTablet =
                    constraints.maxWidth <= 1200 && constraints.maxWidth > 800;
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
                          _buildResponsiveHeader(isMobile),
                          const SizedBox(height: 15),

                          // --- 2. SUMMARY STATS ---
                          _buildSummaryGrid(isDesktop, isTablet, isMobile),
                          const SizedBox(height: 15),

                          // --- 3. CHARTS & TABLES ---
                          _buildChartsSection(isDesktop, isTablet, isMobile),
                          const SizedBox(height: 15),

                          // --- 4. UPCOMING SECTION ---
                          PageTitle(
                            title: "Upcoming Scheduled Maintenance",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _primaryText,
                          ),
                          const SizedBox(height: 15),
                          _buildUpcomingSection(isMobile),

                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildResponsiveHeader(bool isMobile) {
    // If mobile, stack vertically. If desktop, row with space between.
    final academies = ["Bandaragama"];

    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    int currentYear = DateTime.now().year;
    List<String> years = [];
    for (int y = currentYear; y >= 2024; y--) {
      years.add(y.toString());
    }

    List<Widget> filters = [
      SizedBox(
        width: 200,
        child: DropDown<String>(
          label: "Academy:",
          items: academies,
          selectedValues: academies.indexOf(selectedAcademy ?? "") >= 0
              ? academies.indexOf(selectedAcademy!)
              : null,
          valueField: (item) => academies.indexOf(item),
          displayField: (item) => item,
          onChanged: (index) => setState(
              () => selectedAcademy = index != null ? academies[index] : null),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 180,
        child: DropDown<String>(
          label: "Month:",
          items: months,
          selectedValues: months.indexOf(selectedMonth ?? "") >= 0
              ? months.indexOf(selectedMonth!)
              : null,
          valueField: (item) => months.indexOf(item),
          displayField: (item) => item,
          onChanged: (index) {
            setState(
                () => selectedMonth = index != null ? months[index] : null);
                selectedMonthIndex = index;
            _loadData();
          },
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 150,
        child: DropDown<String>(
          label: "Year:",
          items: years,
          selectedValues: years.indexOf(selectedYear ?? "") >= 0
              ? years.indexOf(selectedYear!)
              : 0,
          valueField: (item) => years.indexOf(item),
          displayField: (item) => item,
          onChanged: (index) {
            setState(() => selectedYear = index != null ? years[index] : null);
            _loadData();
          },
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(
              title: "Maintenance Report",
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _primaryText),
          const SizedBox(height: 4),
          Text("Directors View",
              style: TextStyle(fontSize: 16, color: _secondaryText)),
          const SizedBox(height: 20),
          Wrap(runSpacing: 10, spacing: 10, children: filters),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(
                  title: "Maintenance Report — Directors View",
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _primaryText),
              Text("Summary of monthly maintenance costs and task status",
                  style: TextStyle(fontSize: 14, color: _secondaryText)),
            ],
          ),
          Row(children: filters),
        ],
      );
    }
  }

  Widget _buildSummaryGrid(bool isDesktop, bool isTablet, bool isMobile) {
    // Determine how many columns based on screen width
    int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 1);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // 1. Total Tasks
        StatCard(
          title: "Total Tasks",
          value: "${_summaryReport?.totalTasks ?? 0}",
          subtitle: "Created in month",
          accentColor: Colors.transparent,
          width: _calcCardWidth(context, crossAxisCount),
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showTasksDialog("Total Tasks", "all"),
        ),

        // 2. Completed
        StatCard(
          title: "Completed",
          value: "${_summaryReport?.completedTasks ?? 0}",
          subtitle: "Tasks finished",
          accentColor: Colors.transparent,
          width: _calcCardWidth(context, crossAxisCount),
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showTasksDialog("Completed Tasks", "completed"),
        ),

        // 3. Ongoing
        StatCard(
          title: "Ongoing",
          value: "${_summaryReport?.inProgressTasks ?? 0}",
          subtitle: "In progress",
          accentColor: Colors.transparent,
          width: _calcCardWidth(context, crossAxisCount),
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showTasksDialog("Ongoing Tasks", "ongoing"),
        ),

        // 4. Pending
        StatCard(
          title: "Pending",
          value: "${_summaryReport?.pendingTasks ?? 0}",
          subtitle: "Not started",
          accentColor: Colors.transparent,
          width: _calcCardWidth(context, crossAxisCount),
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showTasksDialog("Pending Tasks", "pending"),
        ),

        // 5. Total Cost (Formatted)
        StatCard(
          title: "Total Cost",
          value: "LKR ${_formatCost(_summaryReport?.totalCost ?? 0)}",
          subtitle: "Completed tasks",
          accentColor: Colors.transparent,
          width: _calcCardWidth(context, crossAxisCount),
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showCostBreakdownDialog(),
        ),
      ],
    );
  }

  // Helper to make numbers look nice (e.g., 125000.0 -> "125k")
  String _formatCost(double cost) {
    if (cost >= 1000) {
      return "${(cost / 1000).toStringAsFixed(1)}k";
    }
    return cost.toStringAsFixed(0);
  }

  double _calcCardWidth(BuildContext context, int columns) {
    // Helper to calculate width for Wrap items to behave like a Grid
    double totalWidth = MediaQuery.of(context).size.width;
    if (totalWidth > 1400) totalWidth = 1400; // Cap at max constraint
    double padding = 48 + ((columns - 1) * 16); // Outer padding + gaps
    return (totalWidth - padding) / columns;
  }

  Widget _buildChartsSection(bool isDesktop, bool isTablet, bool isMobile) {
    // HEIGHTS
    double chartHeight = 260;

    if (isDesktop) {
      // 3 Columns: Pie | Line | Table
      return SizedBox(
        height: chartHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: _buildPieChartCard()),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: _buildLineChartCard()),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: _buildOverdueCard()),
          ],
        ),
      );
    } else if (isTablet) {
      // 2 Rows: [Pie | Line] \n [Table]
      return Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: _buildPieChartCard()),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _buildLineChartCard()),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: chartHeight, child: _buildOverdueCard()),
        ],
      );
    } else {
      // Mobile: Stack everything
      return Column(
        children: [
          SizedBox(height: 350, child: _buildPieChartCard()),
          const SizedBox(height: 20),
          SizedBox(height: 350, child: _buildLineChartCard()),
          const SizedBox(height: 20),
          SizedBox(height: 500, child: _buildOverdueCard()),
        ],
      );
    }
  }

  Widget _buildUpcomingSection(bool isMobile) {
    List<Widget> cards = [
      Expanded(
        flex: isMobile ? 0 : 1,
        child: StatCard(
          title: "Total Upcoming Tasks",
          value: "${_summaryReport?.totalUpcomingTasks ?? 0}",
          icon: Icons.calendar_month,
          accentColor: Colors.indigo,
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showUpcomingTasksDialog(),
        ),
      ),
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 15 : 0),
      Expanded(
        flex: isMobile ? 0 : 1,
        child: StatCard(
          title: "Est. Cost (Next Month)",
          value: "LKR ${_summaryReport?.nextMonthlyEstimatedCost ?? 0}",
          icon: Icons.attach_money,
          accentColor: Colors.teal,
          cardRadius: _cardRadius,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          onTap: () => _showEstimatedCostDialog(),
        ),
      ),
    ];

    if (isMobile) {
      return Column(children: cards);
    } else {
      return Row(children: cards);
    }
  }

  // ---------------------------------------------------------------------------
  // INDIVIDUAL COMPONENT BUILDERS (Styled for Consistency)
  // ---------------------------------------------------------------------------

  // Dialog to show tasks
  void _showTasksDialog(String title, String filter) async {
    // Fetch data based on filter
    List<ActivityInstance> rawData;

    switch (filter) {
      case 'completed':
        rawData = await getMonthlyTasksByStatus(
            organizationId: selectedOrganizationId!,
            year: int.parse(selectedYear!),
            month: selectedMonthIndex! + 1,
            overallTaskStatus: 'Completed');
        break;
      case 'ongoing':
        rawData = await getMonthlyTasksByStatus(
            organizationId: selectedOrganizationId!,
            year: int.parse(selectedYear!),
            month: selectedMonthIndex! + 1,
            overallTaskStatus: 'InProgress');
        break;
      case 'pending':
        rawData = await getMonthlyTasksByStatus(
            organizationId: selectedOrganizationId!,
            year: int.parse(selectedYear!),
            month: selectedMonthIndex! + 1,
            overallTaskStatus: 'Pending');
        break;
      case 'all':
      default:
        rawData = await getMonthlyTasksByStatus(
            organizationId: selectedOrganizationId!,
            year: int.parse(selectedYear!),
            month: selectedMonthIndex! + 1);
        break;
    }

    List<Map<String, dynamic>> formattedTasks = rawData.map((instance) {
      // Helper to join multiple names
      String assignedNames = (instance.activityParticipants ?? [])
          .map((p) => p.person?.preferred_name ?? "-")
          .join(", ");

      if (assignedNames.isEmpty) assignedNames = "Unassigned";

      // Helper to format date
      String dueDate =
          instance.end_time != null ? instance.end_time!.split(" ")[0] : "-";

      return {
        "task": instance.maintenanceTask?.title ?? "Unknown Task",
        "assigned": assignedNames,
        "due": dueDate,
        "status": instance.overallTaskStatus ?? "Pending",
      };
    }).toList();

    // Show the Dialog with the data
    showDialog(
      context: context,
      builder: (context) => TasksDialog(
        title: title,
        tasks: formattedTasks,
        primaryText: _primaryText,
        secondaryText: _secondaryText,
      ),
    );
  }

  void _showCostBreakdownDialog() {
    showDialog(
      context: context,
      builder: (context) => CostBreakdownDialog(
        primaryText: _primaryText,
        secondaryText: _secondaryText,
        costItems: const [
          {"name": "Library AC Repair", "cost": "LKR 1,200"},
          {"name": "Generator Servicing", "cost": "LKR 800"},
          {"name": "Paint Room", "cost": "LKR 1,600"},
        ],
        totalCost: "LKR 3,600",
      ),
    );
  }

  void _showUpcomingTasksDialog() {
    // Mock upcoming tasks data
    List<Map<String, dynamic>> upcomingTasks = [
      {
        "task": "AC Maintenance - Lab",
        "assigned": "Kamal",
        "due": "Dec 20",
        "status": "pending"
      },
      {
        "task": "Roof Repair - Main Building",
        "assigned": "Sunil",
        "due": "Dec 22",
        "status": "pending"
      },
      {
        "task": "Electrical Inspection",
        "assigned": "Nimal",
        "due": "Dec 25",
        "status": "pending"
      },
      {
        "task": "Garden Landscaping",
        "assigned": "Saman",
        "due": "Dec 28",
        "status": "pending"
      },
      {
        "task": "Water Tank Cleaning",
        "assigned": "Janaka",
        "due": "Jan 02",
        "status": "pending"
      },
    ];

    showDialog(
      context: context,
      builder: (context) => TasksDialog(
        title: "Upcoming Scheduled Tasks",
        tasks: upcomingTasks,
        primaryText: _primaryText,
        secondaryText: _secondaryText,
      ),
    );
  }

  void _showEstimatedCostDialog() {
    showDialog(
      context: context,
      builder: (context) => CostBreakdownDialog(
        primaryText: _primaryText,
        secondaryText: _secondaryText,
        costItems: const [
          {"name": "AC Maintenance - Lab", "cost": "LKR 35,000"},
          {"name": "Roof Repair - Main Building", "cost": "LKR 45,000"},
          {"name": "Electrical Inspection", "cost": "LKR 20,000"},
          {"name": "Garden Landscaping", "cost": "LKR 30,000"},
          {"name": "Water Tank Cleaning", "cost": "LKR 20,000"},
        ],
        totalCost: "LKR 150,000",
      ),
    );
  }

  // --- 2. PIE CHART ---
  Widget _buildPieChartCard() {
    int completed = _summaryReport?.completedTasks ?? 0;
    int ongoing = _summaryReport?.inProgressTasks ?? 0;
    int pending = _summaryReport?.pendingTasks ?? 0;

    int total = completed + ongoing + pending;

    double completedPercent = total == 0 ? 0 : (completed / total) * 100;
    double ongoingPercent = total == 0 ? 0 : (ongoing / total) * 100;
    double pendingPercent = total == 0 ? 0 : (pending / total) * 100;

    return ChartCard(
      cardRadius: _cardRadius,
      child: Column(
        children: [
          Text("Task Status",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _primaryText)),
          const SizedBox(height: 12),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  // COMPLETED
                  PieChartSectionData(
                    color: Colors.green,
                    value: completedPercent,
                    title: '${completedPercent.toStringAsFixed(0)}%',
                    radius: 35,
                    showTitle: completedPercent > 5,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                  // ONGOING
                  PieChartSectionData(
                    color: Colors.orange,
                    value: ongoingPercent,
                    title: '${ongoingPercent.toStringAsFixed(0)}%',
                    radius: 32,
                    showTitle: ongoingPercent > 5,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                  // PENDING
                  PieChartSectionData(
                    color: Colors.redAccent,
                    value: pendingPercent,
                    title: '${pendingPercent.toStringAsFixed(0)}%',
                    radius: 32,
                    showTitle: pendingPercent > 5,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildLegendItem(Colors.green, "Completed ($completed)"),
              _buildLegendItem(Colors.orange, "Ongoing ($ongoing)"),
              _buildLegendItem(Colors.redAccent, "Pending ($pending)"),
            ],
          )
        ],
      ),
    );
  }

  // --- 3. LINE CHART ---
  Widget _buildLineChartCard() {
    double maxVal = 0;
    for (var item in _monthlyCosts) {
      // Check both actual and estimated to find the highest peak
      maxVal = max(maxVal, item.actualCost ?? 0);
      maxVal = max(maxVal, item.estimatedCost ?? 0);
    }

    // Add 20% buffer so the line doesn't touch the top edge
    // If list is empty/zero, default to 5000
    double calculatedMaxY = maxVal == 0 ? 5000 : maxVal * 1.2;

    // Calculate a nice interval (e.g., 5 grid lines)
    double calculatedInterval = calculatedMaxY / 5;

    return ChartCard(
      cardRadius: _cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Yearly Cost Trend",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryText)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                      selectedYear ?? DateFormat.y().format(DateTime.now()),
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10))),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, "Actual Cost"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.orange, "Estimated Cost"),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: calculatedInterval,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec'
                            ];
                            if (value >= 0 && value < 12)
                              return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(months[value.toInt()],
                                      style: TextStyle(
                                          fontSize: 9, color: _secondaryText)));
                            return const SizedBox();
                          })),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: calculatedInterval,
                          getTitlesWidget: (value, meta) {
                            return Text("${value ~/ 1000}k",
                                style: TextStyle(
                                    fontSize: 9, color: _secondaryText));
                          })),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: calculatedMaxY,
                lineBarsData: [
                  // Actual Cost Line
                  LineChartBarData(
                    spots: _monthlyCosts.map((data) {
                      // X = Month index (0 for Jan, 1 for Feb...), Y = Cost
                      return FlSpot(
                          (data.month! - 1).toDouble(), data.actualCost!);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                        show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                  // Estimated Cost Line
                  LineChartBarData(
                    spots: _monthlyCosts.map((data) {
                      return FlSpot(
                          (data.month! - 1).toDouble(), data.estimatedCost!);
                    }).toList(),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dashArray: [5, 5],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.orange,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. OVERDUE CARD ---
  Widget _buildOverdueCard() {
    return ChartCard(
      cardRadius: _cardRadius,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with Alert style
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(_cardRadius)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade700, size: 18),
                const SizedBox(width: 8),
                Text("Overdue Tasks",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                        fontSize: 13)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("${_overdueTasks.length}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700)),
                )
              ],
            ),
          ),
          // Scrollable Table
          _overdueTasks.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text("No overdue tasks found",
                        style: TextStyle(color: _secondaryText, fontSize: 12)),
                  ),
                )
              : Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(_cardRadius)),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowHeight: 36,
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 48,
                          columnSpacing: 24,
                          horizontalMargin: 16,
                          headingTextStyle: TextStyle(
                              color: _secondaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                          columns: const [
                            DataColumn(label: Text("Task")),
                            DataColumn(label: Text("Assigned")),
                            DataColumn(label: Text("Due")),
                            DataColumn(label: Text("Days")),
                          ],
                          rows: _overdueTasks.map((instance) {
                            // Combine all participant names into one string
                            String assignedNames =
                                (instance.activityParticipants ?? [])
                                    .map((p) => p.person?.preferred_name ?? "-")
                                    .join(", ");

                            if (assignedNames.isEmpty) assignedNames = "-";

                            return DataRow(cells: [
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(instance.maintenanceTask?.title ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _primaryText,
                                          fontSize: 11)),
                                ],
                              )),
                              DataCell(Text(assignedNames,
                                  style: TextStyle(
                                      fontSize: 10, color: _secondaryText))),
                              DataCell(Text(instance.end_time ?? '',
                                  style: TextStyle(
                                      fontSize: 10, color: _secondaryText))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text("${instance.overdueDays}d",
                                      style: TextStyle(
                                          color: Colors.red.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _secondaryText)),
      ],
    );
  }
}
