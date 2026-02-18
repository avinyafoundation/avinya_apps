import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import 'package:gallery/avinya/enrollment/lib/screens/student_create_screen.dart';
import 'package:gallery/avinya/enrollment/lib/screens/student_update_screen.dart';
import 'person_data_excel_report.dart';

// ─── Enums & Constants ────────────────────────────────────────────────────────

enum AvinyaTypeId {
  Future_Enrollees,
  Empower,
  IT,
  CS,
  Empower_And_NVQ_Level3,
  WorkStudy_City_And_Guilds,
  WorkStudy_Maths_And_IT,
  FullTime_Work_Placement
}

const avinyaTypeId = {
  AvinyaTypeId.Future_Enrollees: 103,
  AvinyaTypeId.Empower: 37,
  AvinyaTypeId.IT: 10,
  AvinyaTypeId.CS: 96,
  AvinyaTypeId.Empower_And_NVQ_Level3: 110,
  AvinyaTypeId.WorkStudy_City_And_Guilds: 115,
  AvinyaTypeId.WorkStudy_Maths_And_IT: 120,
  AvinyaTypeId.FullTime_Work_Placement: 125,
};

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  static const Color primary = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryDark = Color(0xFF0081CB);
  static const Color primarySurface = Color.fromARGB(255, 255, 255, 255);
  static const Color surface = Color.fromARGB(255, 255, 255, 255);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondary = Color.fromARGB(255, 0, 0, 0);
  static const Color border = Color.fromARGB(255, 0, 0, 0);
  static const Color tableHeader = Color.fromARGB(255, 3, 3, 3);
  static const Color tableRowAlt = Color.fromARGB(255, 210, 210, 210);

  // Grid line color used across the table
  static const Color gridLine = Color(0xFFDDDDDD);
}

// ─── Column definitions ───────────────────────────────────────────────────────

const List<String> _colLabels = [
  '#',
  'Name',
  'NIC Number',
  'Date of Birth',
  'Digital ID',
  'Gender',
  'Organisation',
];
const List<double> _colWidths = [
  50,
  150,
  145,
  130,
  350,
  100,
  220,
];

// ─── Students Widget ──────────────────────────────────────────────────────────

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  List<Person> _students = [];
  List<Organization> _batchList = [];
  bool _isLoadingBatches = true;
  Organization? _selectedBatch;

  List<AvinyaTypeId> _programmeOptions = [
    AvinyaTypeId.Empower,
    AvinyaTypeId.IT,
    AvinyaTypeId.CS,
  ];
  AvinyaTypeId _selectedProgramme = AvinyaTypeId.Empower;

  List<dynamic> _classList = [];
  bool _isLoadingClasses = false;
  dynamic _selectedClass;

  bool _isFetching = false;
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 0;
  static const int _rowsPerPage = 20;
  int _totalCount = 0;

  List<String?> columnNames = [];

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);
    try {
      final batches = await fetchOrganizationsByAvinyaTypeAndStatus(null, null);
      setState(() {
        _batchList = batches;
        _isLoadingBatches = false;
      });
    } catch (_) {
      setState(() => _isLoadingBatches = false);
    }
  }

  List<AvinyaTypeId> _computeProgrammeOptions(Organization? batch) {
    if (batch != null &&
        batch.organization_metadata != null &&
        batch.organization_metadata.isNotEmpty) {
      if (batch.organization_metadata[1].value.toString() == '2024-07-26') {
        return [
          AvinyaTypeId.Future_Enrollees,
          AvinyaTypeId.Empower,
          AvinyaTypeId.IT,
          AvinyaTypeId.CS,
        ];
      }
      return [
        AvinyaTypeId.Future_Enrollees,
        AvinyaTypeId.Empower,
        AvinyaTypeId.Empower_And_NVQ_Level3,
        AvinyaTypeId.WorkStudy_City_And_Guilds,
        AvinyaTypeId.WorkStudy_Maths_And_IT,
        AvinyaTypeId.FullTime_Work_Placement,
      ];
    }
    return [
      AvinyaTypeId.Future_Enrollees,
      AvinyaTypeId.Empower,
      AvinyaTypeId.Empower_And_NVQ_Level3,
      AvinyaTypeId.WorkStudy_City_And_Guilds,
      AvinyaTypeId.WorkStudy_Maths_And_IT,
      AvinyaTypeId.FullTime_Work_Placement,
    ];
  }

  Future<void> _loadClasses(int batchId) async {
    setState(() {
      _isLoadingClasses = true;
      _classList = [];
      _selectedClass = null;
    });
    try {
      final classes = await fetchClasses(batchId);
      setState(() {
        _classList = classes;
        _isLoadingClasses = false;
      });
    } catch (_) {
      setState(() => _isLoadingClasses = false);
    }
  }

  Future<void> _fetchPage(int page) async {
    setState(() {
      _isFetching = true;
      _currentPage = page;
    });
    try {
      final orgId =
          (avinyaTypeId[_selectedProgramme] == 103 || _selectedBatch == null)
              ? -1
              : _selectedBatch!.id!;

      final results = await fetchPersons(
        orgId,
        avinyaTypeId[_selectedProgramme]!,
        limit: _rowsPerPage,
        offset: page * _rowsPerPage,
        classId: _selectedClass?.id as int?,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      setState(() {
        _students = results;
        if (results.length == _rowsPerPage) {
          _totalCount = (page + 2) * _rowsPerPage;
        } else {
          _totalCount = page * _rowsPerPage + results.length;
        }
        _isFetching = false;
      });
    } catch (_) {
      setState(() {
        _students = [];
        _isFetching = false;
      });
    }
  }

  void _search() => _fetchPage(0);

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedBatch = null;
      _selectedClass = null;
      _classList = [];
      _programmeOptions = [
        AvinyaTypeId.Empower,
        AvinyaTypeId.IT,
        AvinyaTypeId.CS,
      ];
      _selectedProgramme = AvinyaTypeId.Empower;
      _students = [];
      _currentPage = 0;
      _totalCount = 0;
    });
  }

  bool get _hasNextPage => _students.length == _rowsPerPage;
  bool get _hasPrevPage => _currentPage > 0;

  void _showStudentDetail(Person student) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _StudentDetailDialog(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterCard(),
                  const SizedBox(height: 14),
                  _buildActionRow(),
                  const SizedBox(height: 18),
                  _buildTableCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.filter_alt_rounded,
                color: AppTheme.primary, size: 17),
            const SizedBox(width: 7),
            const Text('Filters',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: _buildDropdown<Organization>(
                  label: 'Select Batch',
                  icon: Icons.calendar_today_rounded,
                  value: _selectedBatch,
                  isLoading: _isLoadingBatches,
                  items: _batchList
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.name?.name_en ?? '',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (b) async {
                    if (b == null) return;
                    final opts = _computeProgrammeOptions(b);
                    setState(() {
                      _selectedBatch = b;
                      _programmeOptions = opts;
                      if (!opts.contains(_selectedProgramme)) {
                        _selectedProgramme = opts.first;
                      }
                    });
                    if (b.id != null) await _loadClasses(b.id!);
                  },
                ),
              ),
              SizedBox(
                width: 230,
                child: _buildDropdown<AvinyaTypeId>(
                  label: 'Select Programme',
                  icon: Icons.book_rounded,
                  value: _programmeOptions.contains(_selectedProgramme)
                      ? _selectedProgramme
                      : _programmeOptions.first,
                  isLoading: false,
                  items: _programmeOptions
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.name
                                  .toString()
                                  .replaceAll('AvinyaTypeId.', '')
                                  .replaceAll('_', ' '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedProgramme = v);
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: _buildDropdown<dynamic>(
                  label: 'Select Class',
                  icon: Icons.class_rounded,
                  value: _selectedClass,
                  isLoading: _isLoadingClasses,
                  items: _classList
                      .map((c) => DropdownMenuItem<dynamic>(
                            value: c,
                            child: Text(
                                c.description?.toString() ?? 'Class ${c.id}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v),
                ),
              ),
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Name or NIC',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search by name or NIC…',
                          hintStyle: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textSecondary, size: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppTheme.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppTheme.border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppTheme.primary, width: 1.8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          filled: true,
                          fillColor: AppTheme.surface,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                  ],
                ),
              ),
              _ActionBtn(
                label: 'Search',
                icon: Icons.search_rounded,
                loading: _isFetching,
                onPressed: _search,
              ),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required bool isLoading,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              isLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary),
                    )
                  : Icon(icon, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    hint: const Text('—',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary, size: 18),
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    items: items,
                    onChanged: isLoading ? null : onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _ActionBtn(
          label: 'Create New',
          icon: Icons.add_rounded,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const StudentCreateScreen(id: null)),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: PersonDataExcelReport(
              fetchedPersonData: _students,
              columnNames: columnNames,
              updateExcelState: () {},
              isFetching: _isFetching,
              selectedAvinyaTypeId: _selectedProgramme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildScrollableTable(),
            _buildPaginationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTable() {
    if (_isFetching) {
      return const SizedBox(
        height: 200,
        child: Center(child: SpinKitCircle(color: AppTheme.primary, size: 48)),
      );
    }

    if (_students.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.people_outline_rounded,
                  color: AppTheme.border, size: 48),
              SizedBox(height: 10),
              Text('No student records found',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              SizedBox(height: 4),
              Text('Select filters and press Search',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Container(
              color: AppTheme.tableHeader,
              child: Row(
                children: List.generate(_colLabels.length, (i) {
                  final isLast = i == _colLabels.length - 1;
                  return Container(
                    width: _colWidths[i],
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        // vertical divider between header cells (white, subtle)
                        right: isLast
                            ? BorderSide.none
                            : const BorderSide(color: Colors.white30, width: 1),
                      ),
                    ),
                    child: Text(
                      _colLabels[i],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  );
                }),
              ),
            ),

            // ── Data rows ──
            ...List.generate(_students.length, (i) {
              final rowNumber = _currentPage * _rowsPerPage + i + 1;
              return _StudentRow(
                index: rowNumber,
                student: _students[i],
                isAlt: i.isOdd,
                onTap: () => _showStudentDetail(_students[i]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    final from = _students.isEmpty ? 0 : _currentPage * _rowsPerPage + 1;
    final to = _currentPage * _rowsPerPage + _students.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _students.isEmpty
                ? 'No records'
                : 'Showing $from–$to'
                    '${_totalCount > 0 ? ' of $_totalCount' : ''}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Row(
            children: [
              _PageBtn(
                icon: Icons.chevron_left_rounded,
                enabled: _hasPrevPage && !_isFetching,
                onTap: () => _fetchPage(_currentPage - 1),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'Page ${_currentPage + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              _PageBtn(
                icon: Icons.chevron_right_rounded,
                enabled: _hasNextPage && !_isFetching,
                onTap: () => _fetchPage(_currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Student Row ──────────────────────────────────────────────────────────────

class _StudentRow extends StatefulWidget {
  final int index;
  final Person student;
  final bool isAlt;
  final VoidCallback onTap;

  const _StudentRow({
    required this.index,
    required this.student,
    required this.isAlt,
    required this.onTap,
  });

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // final Color rowBg = _hovered
    //     ? AppTheme.primarySurface
    //     : widget.isAlt
    //         ? AppTheme.tableRowAlt
    //         : Colors.white;

    // AFTER
    final Color rowBg = _hovered
        ? AppTheme.tableRowAlt 
        : Colors.white; 

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          // ── Horizontal line: bottom border on every row ──
          decoration: BoxDecoration(
            color: rowBg,
            border: const Border(
              bottom: BorderSide(color: AppTheme.gridLine, width: 1),
            ),
          ),
          child: Row(
            children: [
              // # index
              _cell(
                width: _colWidths[0],
                child: Text(
                  '${widget.index}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),

              // Name
              _cell(
                width: _colWidths[1],
                child: Text(
                  widget.student.preferred_name ?? 'N/A',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              _textCell(_colWidths[2], widget.student.nic_no?.toString()),
              _textCell(
                  _colWidths[3], widget.student.date_of_birth?.toString()),
              _textCell(_colWidths[4], widget.student.digital_id?.toString()),

              // Gender badge
              _cell(
                width: _colWidths[5],
                child: _GenderBadge(gender: widget.student.sex),
              ),

              // Organisation — last column, no right border
              _textCell(
                _colWidths[6],
                widget.student.organization?.avinya_type?.name,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generic cell with a right vertical border (omitted on the last column).
  Widget _cell({
    required double width,
    required Widget child,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      // ── Vertical line: right border on every cell except the last ──
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: AppTheme.gridLine, width: 1),
        ),
      ),
      child: child,
    );
  }

  /// Convenience wrapper for plain-text cells.
  Widget _textCell(double width, String? text, {bool isLast = false}) {
    return _cell(
      width: width,
      isLast: isLast,
      child: Text(
        text ?? 'N/A',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─── Gender Badge ─────────────────────────────────────────────────────────────

class _GenderBadge extends StatelessWidget {
  final String? gender;
  const _GenderBadge({this.gender});

  @override
  Widget build(BuildContext context) {
    final g = gender?.toLowerCase() ?? '';
    final isMale = g == 'male' || g == 'm';
    final isFemale = g == 'female' || g == 'f';
    final Color bg, fg;
    final IconData ico;
    if (isMale) {
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF1565C0);
      ico = Icons.male_rounded;
    } else if (isFemale) {
      bg = const Color(0xFFFCE4EC);
      fg = const Color(0xFFC62828);
      ico = Icons.female_rounded;
    } else {
      bg = AppTheme.surface;
      fg = AppTheme.textSecondary;
      ico = Icons.person_rounded;
    }

    // Remove the outer fixed SizedBox — let the badge size itself naturally
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ico, color: fg, size: 13),
            const SizedBox(width: 3),
            Text(
              gender ?? 'N/A',
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Student Detail Dialog ────────────────────────────────────────────────────

class _StudentDetailDialog extends StatelessWidget {
  final Person student;
  const _StudentDetailDialog({required this.student});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x28000000), blurRadius: 30, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 12, 18),
              decoration: const BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Text(
                      (student.preferred_name?.isNotEmpty == true
                              ? student.preferred_name![0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.preferred_name ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.organization?.avinya_type?.name ??
                              'No Programme',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _DetailRow(Icons.badge_rounded, 'NIC Number',
                      student.nic_no?.toString()),
                  _DetailRow(Icons.cake_rounded, 'Date of Birth',
                      student.date_of_birth?.toString()),
                  _DetailRow(Icons.fingerprint_rounded, 'Digital ID',
                      student.digital_id?.toString()),
                  _DetailRow(Icons.person_rounded, 'Gender', student.sex),
                  _DetailRow(Icons.business_rounded, 'Organisation',
                      student.organization?.avinya_type?.name),
                  if (student.id != null)
                    _DetailRow(
                        Icons.tag_rounded, 'Student ID', student.id.toString()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: student.id != null
                          ? () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StudentUpdateScreen(id: student.id!),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.edit_rounded, size: 15),
                      label: const Text('Edit Student',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Icon(icon, color: AppTheme.primary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value ?? 'N/A',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool loading;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 16),
        label: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent[400],
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Pagination Button ────────────────────────────────────────────────────────

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PageBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primarySurface : AppTheme.surface,
          border: Border.all(
              color: enabled
                  ? AppTheme.primary
                  : AppTheme.border.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            color: enabled
                ? AppTheme.primary
                : AppTheme.textSecondary.withOpacity(0.35),
            size: 20),
      ),
    );
  }
}







// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// //import 'package:enrollment/data/organization.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:gallery/avinya/enrollment/lib/data/person.dart';
// import 'package:gallery/avinya/enrollment/lib/screens/student_create_screen.dart';
// import 'package:gallery/avinya/enrollment/lib/screens/student_update_screen.dart';
// import 'person_data_excel_report.dart';

// enum AvinyaTypeId {
//   Future_Enrollees,
//   Empower,
//   IT,
//   CS,
//   Empower_And_NVQ_Level3,
//   WorkStudy_City_And_Guilds,
//   WorkStudy_Maths_And_IT,
//   FullTime_Work_Placement
// }

// const avinyaTypeId = {
//   AvinyaTypeId.Future_Enrollees: 103,
//   AvinyaTypeId.Empower: 37,
//   AvinyaTypeId.IT: 10,
//   AvinyaTypeId.CS: 96,
//   AvinyaTypeId.Empower_And_NVQ_Level3: 110,
//   AvinyaTypeId.WorkStudy_City_And_Guilds: 115,
//   AvinyaTypeId.WorkStudy_Maths_And_IT: 120,
//   AvinyaTypeId.FullTime_Work_Placement: 125
// };

// class Students extends StatefulWidget {
//   const Students({super.key});

//   @override
//   State<Students> createState() {
//     return _StudentsState();
//   }
// }

// class _StudentsState extends State<Students> {
//   List<Person> _fetchedPersonData = [];
//   List<Person> _fetchedExcelReportData = [];
//   late Future<List<Organization>> _fetchBatchData;
//   bool _isFetching = false;
//   Organization? _selectedValue;
//   AvinyaTypeId _selectedAvinyaTypeId = AvinyaTypeId.Empower;
//   List<AvinyaTypeId> filteredAvinyaTypeIdValues = [
//     AvinyaTypeId.Empower,
//     AvinyaTypeId.IT,
//     AvinyaTypeId.CS,
//   ];

//   List<String?> columnNames = [];

//   late DataTableSource _data;

//   List<Person> filteredStudents = [];

//   //calendar specific variables

//   @override
//   void initState() {
//     super.initState();
//     _fetchBatchData = _loadBatchData();
//     // filteredStudents = _fetchedPersonData;
//   }

//   Future<List<Organization>> _loadBatchData() async {
//     return await fetchOrganizationsByAvinyaTypeAndStatus(null,null);
//   }

//   Future<List<AvinyaTypeId>> fetchAvinyaTypes(dynamic newValue) async {
//     List<AvinyaTypeId> filteredAvinyaTypeIdValues;

//     // Check if newValue is not null and contains valid metadata
//     if (newValue != null &&
//         newValue.organization_metadata != null &&
//         newValue.organization_metadata.isNotEmpty) {
//       // Parse the metadata value to a DateTime and perform date range checks
//       DateTime metadataDate =
//           DateTime.parse(newValue.organization_metadata[1].value.toString());

//       if (newValue.organization_metadata[1].value.toString() == '2024-07-26') {
//         filteredAvinyaTypeIdValues = [
//           AvinyaTypeId.Future_Enrollees,
//           AvinyaTypeId.Empower,
//           AvinyaTypeId.IT,
//           AvinyaTypeId.CS,
//         ];
//       } else {
//         filteredAvinyaTypeIdValues = [
//           AvinyaTypeId.Future_Enrollees,
//           AvinyaTypeId.Empower,
//           AvinyaTypeId.Empower_And_NVQ_Level3,
//           AvinyaTypeId.WorkStudy_City_And_Guilds,
//           AvinyaTypeId.WorkStudy_Maths_And_IT,
//           AvinyaTypeId.FullTime_Work_Placement
//         ];
//       }
//     } else {
//       // Default value if newValue is null or invalid
//       filteredAvinyaTypeIdValues = [
//         AvinyaTypeId.Future_Enrollees,
//         AvinyaTypeId.Empower,
//         AvinyaTypeId.Empower_And_NVQ_Level3,
//         AvinyaTypeId.WorkStudy_City_And_Guilds,
//         AvinyaTypeId.WorkStudy_Maths_And_IT,
//         AvinyaTypeId.FullTime_Work_Placement
//       ];
//     }

//     return filteredAvinyaTypeIdValues;
//   }

//   void updateExcelState() {
//     PersonDataExcelReport(
//         fetchedPersonData: _fetchedPersonData,
//         columnNames: columnNames,
//         updateExcelState: updateExcelState,
//         isFetching: _isFetching,
//         selectedAvinyaTypeId: _selectedAvinyaTypeId);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _data = MyData(_fetchedPersonData, updateSelected, context);
//   }

//   void updateSelected(int index, bool value, List<bool> selected) {
//     setState(() {
//       selected[index] = value;
//     });
//   }

//   List<DataColumn> _buildDataColumns() {
//     List<DataColumn> ColumnNames = [];

//     ColumnNames.add(DataColumn(
//         label: Text('Name',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
//     ColumnNames.add(DataColumn(
//         label: Text('NIC Number',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
//     ColumnNames.add(DataColumn(
//         label: Text('Birth Date',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
//     ColumnNames.add(DataColumn(
//         label: Text('Digital ID',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
//     ColumnNames.add(DataColumn(
//         label: Text('Gender',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
//     ColumnNames.add(DataColumn(
//         label: Text('Organization',
//             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

//     return ColumnNames;
//   }

//   void searchStudents(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredStudents = _fetchedPersonData;
//       } else {
//         final lowerCaseQuery = query.toLowerCase();

//         filteredStudents = _fetchedPersonData.where((student) {
//           print('Searching for: $query');
//           print('Present count: ${student.preferred_name}');
//           print('NIC number: ${student.nic_no}');

//           // Ensure preferred_name is not null and trimmed
//           final presentCountString =
//               student.preferred_name?.trim().toLowerCase() ?? '';
//           final attendancePercentageString = student.nic_no?.toString() ?? '';

//           // Check for matching query
//           return presentCountString.contains(lowerCaseQuery) ||
//               attendancePercentageString.contains(lowerCaseQuery);
//         }).toList();
//       }

//       _data = MyData(filteredStudents, updateSelected, context);
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Wrap(
//             children: <Widget>[
//               Padding(
//                 padding: EdgeInsets.only(top: 20, left: 5),
//                 child: Wrap(
//                   crossAxisAlignment: WrapCrossAlignment.center,
//                   children: [
//                     Text('Select a Batch :'),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: FutureBuilder<List<Organization>>(
//                         future: _fetchBatchData,
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Container(
//                               margin: EdgeInsets.only(top: 10),
//                               child: SpinKitCircle(
//                                 color: (Color.fromARGB(255, 74, 161, 70)),
//                                 size: 70,
//                               ),
//                             );
//                           } else if (snapshot.hasError) {
//                             return const Center(
//                               child: Text('Something went wrong...'),
//                             );
//                           } else if (!snapshot.hasData) {
//                             return const Center(
//                               child: Text('No batch found'),
//                             );
//                           }
//                           final batchData = snapshot.data!;
//                           return DropdownButton<Organization>(
//                               value: _selectedValue,
//                               items: batchData.map((Organization batch) {
//                                 return DropdownMenuItem(
//                                     value: batch,
//                                     child: Text(batch.name!.name_en ?? ''));
//                               }).toList(),
//                               onChanged: (Organization? newValue) async {
//                                 if (newValue == null) {
//                                   return;
//                                 }

//                                 // if (newValue.organization_metadata.isEmpty) {
//                                 //   return;
//                                 // }

//                                 // if (DateTime.parse(newValue
//                                 //         .organization_metadata[1].value
//                                 //         .toString())
//                                 //     .isBefore(DateTime.parse('2024-03-01'))) {
//                                 //   filteredAvinyaTypeIdValues = [
//                                 //     AvinyaTypeId.Empower,

//                                 //   ];
//                                 // } else {
//                                 //   filteredAvinyaTypeIdValues = [
//                                 //     AvinyaTypeId.Empower,
//                                 //     AvinyaTypeId.IT,
//                                 //     AvinyaTypeId.CS,
//                                 //   ];
//                                 // }

//                                 setState(() {
//                                   this._isFetching = true;
//                                   filteredAvinyaTypeIdValues;
//                                 });

//                                 if (filteredAvinyaTypeIdValues
//                                     .contains(_selectedAvinyaTypeId)) {
//                                   _fetchedPersonData = await fetchPersons(
//                                       newValue.id!,
//                                       avinyaTypeId[_selectedAvinyaTypeId]!);
//                                 } else {
//                                   _selectedAvinyaTypeId =
//                                       filteredAvinyaTypeIdValues.first;

//                                   _fetchedPersonData = await fetchPersons(
//                                       newValue.id!,
//                                       avinyaTypeId[_selectedAvinyaTypeId]!);
//                                 }

//                                 setState(() {
//                                   _selectedValue = newValue;
//                                   this._isFetching = false;
//                                   _selectedAvinyaTypeId;
//                                   _data = MyData(_fetchedPersonData,
//                                       updateSelected, context);
//                                   filteredStudents = _fetchedPersonData;
//                                 });
//                               });
//                         },
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text('Select a Programme :'),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: FutureBuilder<List<AvinyaTypeId>>(
//                         future: fetchAvinyaTypes(_selectedValue),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Container(
//                               margin: EdgeInsets.only(top: 10),
//                               child: SpinKitCircle(
//                                 color: Colors.deepPurpleAccent,
//                                 size: 70,
//                               ),
//                             );
//                           } else if (snapshot.hasError) {
//                             return const Center(
//                               child: Text('Something went wrong...'),
//                             );
//                           } else if (!snapshot.hasData) {
//                             return const Center(
//                               child: Text('No Avinya Type found'),
//                             );
//                           }

//                           final avinyaTypeData = snapshot.data!;
//                           return DropdownButton<AvinyaTypeId>(
//                             value: _selectedAvinyaTypeId,
//                             items: avinyaTypeData.map((typeId) {
//                               return DropdownMenuItem<AvinyaTypeId>(
//                                 value: typeId,
//                                 child: Text(
//                                   typeId.name.toString(),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (AvinyaTypeId? value) async {
//                               if (value == null) {
//                                 return;
//                               }

//                               setState(() {
//                                 _selectedAvinyaTypeId = value;
//                                 _isFetching = true;
//                               });

//                               if (avinyaTypeId[value] == 103 ||
//                                   _selectedValue == null) {
//                                 _fetchedPersonData = await fetchPersons(
//                                     -1, avinyaTypeId[value]!);
//                               } else {
//                                 _fetchedPersonData = await fetchPersons(
//                                     _selectedValue!.id!, avinyaTypeId[value]!);
//                               }

//                               setState(() {
//                                 _isFetching = false;
//                                 _data = MyData(_fetchedPersonData,
//                                     updateSelected, context);
//                                 filteredStudents = _fetchedPersonData;
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: SizedBox(
//                             width: 250,
//                             child: TextField(
//                               decoration: InputDecoration(
//                                 labelText: 'Search by Name or NIC',
//                                 border: OutlineInputBorder(),
//                                 prefixIcon: Icon(Icons.search),
//                               ),
//                               onChanged: (query) {
//                                 searchStudents(query);
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     FittedBox(
//                       alignment: Alignment.topLeft,
//                       fit: BoxFit.scaleDown,
//                       child: Container(
//                         alignment: Alignment.bottomRight,
//                         margin: const EdgeInsets.only(right: 20.0),
//                         width: 100.0,
//                         height: 30.0,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => StudentCreateScreen(
//                                   id: null, // Since it's for creating a new student, no ID is passed
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             'Create New',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0, vertical: 5.0),
//                             textStyle: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     FittedBox(
//                       alignment: Alignment.topLeft,
//                       fit: BoxFit.scaleDown,
//                       child: Container(
//                           alignment: Alignment.centerLeft,
//                           margin: EdgeInsets.only(right: 10.0),
//                           width: 140.0,
//                           height: 50.0,
//                           child: PersonDataExcelReport(
//                               fetchedPersonData: filteredStudents,
//                               columnNames: columnNames,
//                               updateExcelState: updateExcelState,
//                               isFetching: _isFetching,
//                               selectedAvinyaTypeId: _selectedAvinyaTypeId)),
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Wrap(children: [
//                 if (_isFetching)
//                   Container(
//                     margin: EdgeInsets.only(top: 180),
//                     child: SpinKitCircle(
//                       color: (Color.fromARGB(255, 74, 161,
//                           70)), // Customize the color of the indicator
//                       size: 50, // Customize the size of the indicator
//                     ),
//                   )
//                 else if (_fetchedPersonData.length > 0)
//                   ScrollConfiguration(
//                     behavior:
//                         ScrollConfiguration.of(context).copyWith(dragDevices: {
//                       PointerDeviceKind.touch,
//                       PointerDeviceKind.mouse,
//                     }),
//                     child: PaginatedDataTable(
//                       showCheckboxColumn: false,
//                       source: _data,
//                       columns: _buildDataColumns(),
//                       // header: const Center(child: Text('Daily Attendance')),
//                       columnSpacing: 100,
//                       horizontalMargin: 60,
//                       rowsPerPage: 20,
//                     ),
//                   )
//                 else
//                   Container(
//                     margin: EdgeInsets.all(20),
//                     child: Text('No Students Records found'),
//                   ),
//               ]),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyData extends DataTableSource {
//   final BuildContext context;
//   MyData(this._fetchedPersonData, this.updateSelected, this.context);

//   final List<Person> _fetchedPersonData;
//   final Function(int, bool, List<bool>) updateSelected;

//   @override
//   DataRow? getRow(int index) {
//     if (index == 0) {
//       List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);
//       return DataRow(
//         cells: cells,
//       );
//     }

//     if (_fetchedPersonData.length > 0 && index <= _fetchedPersonData.length) {
//       List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);

//       cells[0] = DataCell(Center(
//           child: Text(_fetchedPersonData[index - 1].preferred_name ?? "N/A")));

//       cells[1] = DataCell(Center(
//           child:
//               Text(_fetchedPersonData[index - 1].nic_no?.toString() ?? "N/A")));

//       cells[2] = DataCell(Center(
//           child: Text(_fetchedPersonData[index - 1].date_of_birth?.toString() ??
//               "N/A")));

//       cells[3] = DataCell(Center(
//           child: Text(
//               _fetchedPersonData[index - 1].digital_id?.toString() ?? "N/A")));

//       cells[4] = DataCell(
//           Center(child: Text(_fetchedPersonData[index - 1].sex ?? "N/A")));

//       cells[5] = DataCell(Center(
//         child: Text(
//           _fetchedPersonData[index - 1].organization?.avinya_type?.name ??
//               "N/A",
//         ),
//       ));

//       // return DataRow(cells: cells);
//       return DataRow(
//         cells: cells,
//         onSelectChanged: (selected) {
//           if (selected != null && selected) {
//             // Navigate to the new screen with the id
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => StudentUpdateScreen(
//                   id: _fetchedPersonData[index - 1].id!, // Pass the ID
//                 ),
//               ),
//             );
//           }
//         },
//       );
//     }

//     return null; // Return null for invalid index values
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount {
//     int count = 0;
//     count = _fetchedPersonData.length + 1;
//     return count;
//   }

//   @override
//   int get selectedRowCount => 0;
// }
