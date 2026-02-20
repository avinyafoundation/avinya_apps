import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────

class _DashTheme {
  static const Color primary = Color(0xFF05a9f4);
  static const Color bg = Color(0xFFF5F7FB);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1F2A44);
  static const Color textLight = Color(0xFF7B8AA5);

  static const List<Color> pieColors = [
    Color(0xFF05a9f4),
    Color(0xFFf44336),
    Color(0xFF4caf50),
    Color(0xFFff9800),
    Color(0xFF9c27b0),
    Color(0xFF00bcd4),
    Color(0xFFe91e63),
    Color(0xFF3f51b5),
  ];
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class EnrollmentDashboard extends StatefulWidget {
  const EnrollmentDashboard({super.key});

  @override
  State<EnrollmentDashboard> createState() => _EnrollmentDashboardState();
}

class _EnrollmentDashboardState extends State<EnrollmentDashboard> {
  // Batch state — mirrors the Students screen pattern
  List<Organization> _batchList = [];
  bool _isLoadingBatches = true;
  Organization? _selectedBatch;

  // Dashboard data
  StudentCount? _studentCount;
  AgeDistribution? _ageDistribution;
  DistrictDistribution? _districtDistribution;
  bool _isLoadingData = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  // ── Load batches exactly like Students screen ────────────────────────────
  // Future<void> _loadBatches() async {
  //   setState(() => _isLoadingBatches = true);
  //   try {
  //     final batches = await fetchOrganizationsByAvinyaTypeAndStatus(null, null);
  //     setState(() {
  //       _batchList = batches;
  //       _isLoadingBatches = false;
  //     });
  //   } catch (e) {
  //     setState(() => _isLoadingBatches = false);
  //   }
  // }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);
    try {
      final batches = await fetchOrganizationsByAvinyaTypeAndStatus(null, null);

      Organization? defaultBatch;
      try {
        defaultBatch = batches.firstWhere(
          (b) => (b.name?.name_en ?? '')
              .toLowerCase()
              .contains('empower - 2026a - bandaragama'),
        );
      } catch (_) {
        defaultBatch = null;
      }

      setState(() {
        _batchList = batches;
        _isLoadingBatches = false;
        if (defaultBatch != null) {
          _selectedBatch = defaultBatch;
        }
      });

      // Auto-load dashboard data for the default batch
      if (defaultBatch?.id != null) {
        _loadDashboardData(defaultBatch!.id!);
      }
    } catch (e) {
      setState(() => _isLoadingBatches = false);
    }
  }

  // ── Load dashboard data when batch changes ───────────────────────────────
  Future<void> _loadDashboardData(int organizationId) async {
    setState(() {
      _isLoadingData = true;
      _error = null;
    });
    try {
      final StudentCount studentCount = await fetchStudentCount(organizationId);
      final AgeDistribution ageDistribution =
          await fetchAgeDistribution(organizationId);
      final DistrictDistribution districtDistribution =
          await fetchDistrictDistribution(organizationId);

      setState(() {
        _studentCount = studentCount;
        _ageDistribution = ageDistribution;
        _districtDistribution = districtDistribution;
        _isLoadingData = false;
      });
    } catch (e) {
      print('DEBUG dashboard error: $e');
      setState(() {
        _error = e.toString();
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashTheme.bg,
      body: Column(
        children: [
          //_buildTopBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_selectedBatch?.id != null) {
                  await _loadDashboardData(_selectedBatch!.id!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBatchSelector(),
                    const SizedBox(height: 24),
                    if (_selectedBatch == null)
                      _buildEmptyState()
                    else if (_isLoadingData)
                      _buildLoadingState()
                    else if (_error != null)
                      _buildErrorState()
                    else ...[
                      _buildStatCards(),
                      const SizedBox(height: 24),
                      _buildChartsRow(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: _DashTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Text(
        'Avinya Academy – Student Enrollment Portal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Batch Selector ───────────────────────────────────────────────────────
  Widget _buildBatchSelector() {
    return Row(
      children: [
        const Text(
          'Select Batch:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _DashTheme.textDark,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _DashTheme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDD)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: _isLoadingBatches
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _DashTheme.primary),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Organization>(
                    value: _selectedBatch,
                    hint: const Text(
                      'Choose a batch…',
                      style:
                          TextStyle(color: _DashTheme.textLight, fontSize: 14),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _DashTheme.textLight),
                    style: const TextStyle(
                        color: _DashTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    items: _batchList.map((b) {
                      return DropdownMenuItem<Organization>(
                        value: b,
                        child: Text(b.name?.name_en ?? ''),
                      );
                    }).toList(),
                    onChanged: (Organization? newBatch) {
                      if (newBatch == null) return;
                      setState(() => _selectedBatch = newBatch);
                      if (newBatch.id != null) {
                        _loadDashboardData(newBatch.id!);
                      }
                    },
                  ),
                ),
        ),
        if (_selectedBatch != null) ...[
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded,
                color: _DashTheme.primary, size: 20),
            onPressed: () {
              if (_selectedBatch?.id != null) {
                _loadDashboardData(_selectedBatch!.id!);
              }
            },
          ),
        ],
      ],
    );
  }

  // ── Stat Cards ───────────────────────────────────────────────────────────
  Widget _buildStatCards() {
    final sc = _studentCount;
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxis =
          constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
      return GridView.count(
        crossAxisCount: crossAxis,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.2,
        children: [
          _StatCard(
              label: 'Total Students',
              value: sc?.currentStudentCount ?? 0,
              icon: Icons.people_rounded,
              color: _DashTheme.primary),
          _StatCard(
              label: 'Male Students',
              value: sc?.maleStudentCount ?? 0,
              icon: Icons.male_rounded,
              color: const Color(0xFF2196F3)),
          _StatCard(
              label: 'Female Students',
              value: sc?.femaleStudentCount ?? 0,
              icon: Icons.female_rounded,
              color: const Color(0xFFE91E63)),
          _StatCard(
              label: 'Dropouts',
              value: sc?.dropoutStudentCount ?? 0,
              icon: Icons.person_remove_rounded,
              color: const Color(0xFFF44336)),
        ],
      );
    });
  }

  // ── Charts Row ───────────────────────────────────────────────────────────
  Widget _buildChartsRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxis = constraints.maxWidth > 1100
          ? 4
          : (constraints.maxWidth > 700 ? 2 : 1);
      return GridView.count(
        crossAxisCount: crossAxis,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
        children: [
          _buildGenderChart(),
          _buildAgeChart(),
          _buildDistrictChart(),
          _buildDropoutChart(),
        ],
      );
    });
  }

  // Gender Pie
  Widget _buildGenderChart() {
    final sc = _studentCount;
    final male = (sc?.maleStudentCount ?? 0).toDouble();
    final female = (sc?.femaleStudentCount ?? 0).toDouble();
    return _ChartCard(
      title: 'Gender Distribution',
      badge: 'Pie',
      child: _PieChartWidget(
        sections: [
          PieChartSectionData(
              value: male,
              title: male > 0 ? 'Male\n${male.toInt()}' : '',
              color: const Color(0xFF2196F3),
              radius: 80,
              titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          PieChartSectionData(
              value: female,
              title: female > 0 ? 'Female\n${female.toInt()}' : '',
              color: const Color(0xFFE91E63),
              radius: 80,
              titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
        legendItems: const [
          _LegendItem(color: Color(0xFF2196F3), label: 'Male'),
          _LegendItem(color: Color(0xFFE91E63), label: 'Female'),
        ],
      ),
    );
  }

  // Age Pie
  Widget _buildAgeChart() {
    final groups = _ageDistribution?.ageGroups ?? [];
    final sections = groups.asMap().entries.map((e) {
      final color = _DashTheme.pieColors[e.key % _DashTheme.pieColors.length];
      return PieChartSectionData(
        value: e.value.count.toDouble(),
        title: e.value.count > 0 ? e.value.count.toString() : '',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();

    final legendItems = groups.asMap().entries.map((e) {
      final color = _DashTheme.pieColors[e.key % _DashTheme.pieColors.length];
      return _LegendItem(color: color, label: e.value.ageGroup);
    }).toList();

    return _ChartCard(
      title: 'Age Distribution',
      badge: 'Pie',
      child: _PieChartWidget(sections: sections, legendItems: legendItems),
    );
  }

  // District Pie
  Widget _buildDistrictChart() {
    final districts = _districtDistribution?.districts ?? [];
    final sections = districts.asMap().entries.map((e) {
      final color = _DashTheme.pieColors[e.key % _DashTheme.pieColors.length];
      return PieChartSectionData(
        value: e.value.count.toDouble(),
        title: e.value.count > 0 ? e.value.count.toString() : '',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();

    final legendItems = districts.asMap().entries.map((e) {
      final color = _DashTheme.pieColors[e.key % _DashTheme.pieColors.length];
      return _LegendItem(color: color, label: e.value.districtName);
    }).toList();

    return _ChartCard(
      title: 'District Distribution',
      badge: 'Pie',
      child: _PieChartWidget(sections: sections, legendItems: legendItems),
    );
  }

  // Dropout Doughnut
  Widget _buildDropoutChart() {
    final sc = _studentCount;
    final total = (sc?.currentStudentCount ?? 0).toDouble();
    final dropouts = (sc?.dropoutStudentCount ?? 0).toDouble();
    final active = (total - dropouts).clamp(0.0, double.infinity);

    return _ChartCard(
      title: 'Total vs Dropouts',
      badge: 'Doughnut',
      child: _PieChartWidget(
        centerText: total > 0
            ? '${((active / total) * 100).toStringAsFixed(0)}%\nActive'
            : '',
        sections: [
          PieChartSectionData(
              value: active,
              title: active > 0 ? active.toInt().toString() : '',
              color: const Color(0xFF4CAF50),
              radius: 65,
              titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          PieChartSectionData(
              value: dropouts,
              title: dropouts > 0 ? dropouts.toInt().toString() : '',
              color: const Color(0xFFF44336),
              radius: 65,
              titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
        legendItems: const [
          _LegendItem(color: Color(0xFF4CAF50), label: 'Active'),
          _LegendItem(color: Color(0xFFF44336), label: 'Dropouts'),
        ],
      ),
    );
  }

  // ── States ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: const [
          Icon(Icons.bar_chart_rounded, size: 64, color: Color(0xFFCDD5E0)),
          SizedBox(height: 16),
          Text('Select a batch to view dashboard',
              style: TextStyle(
                  color: _DashTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: _DashTheme.primary),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Failed to load dashboard data. Please try again.',
                style: TextStyle(color: Color(0xFFC62828))),
          ),
          TextButton(
            onPressed: () {
              if (_selectedBatch?.id != null) {
                _loadDashboardData(_selectedBatch!.id!);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashTheme.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: _DashTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: TextStyle(
                      color: color,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chart Card ───────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String badge;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.badge,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _DashTheme.textDark)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _DashTheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─── Pie Chart Widget ─────────────────────────────────────────────────────────

class _PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final List<_LegendItem> legendItems;
  final String? centerText;

  const _PieChartWidget({
    required this.sections,
    required this.legendItems,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = sections.isEmpty || sections.every((s) => s.value == 0);

    return Column(
      children: [
        Expanded(
          child: isEmpty
              ? const Center(
                  child: Text('No data',
                      style:
                          TextStyle(color: _DashTheme.textLight, fontSize: 13)))
              : PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: centerText != null ? 40 : 0,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
        ),
        if (centerText != null && !isEmpty)
          // Center text overlay handled by fl_chart natively via centerSpaceRadius
          const SizedBox(),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: legendItems,
        ),
      ],
    );
  }
}

// ─── Legend Item ──────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: _DashTheme.textLight,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
