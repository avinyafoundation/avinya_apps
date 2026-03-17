import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import '../data/import_student_row.dart';
import '../services/lookup_resolver_service.dart';

class ImportPreviewTable extends StatefulWidget {
  final List<ImportStudentRow> rows;
  final LookupResolverService resolver;
  final VoidCallback onRowChanged;

  const ImportPreviewTable({
    Key? key,
    required this.rows,
    required this.resolver,
    required this.onRowChanged,
  }) : super(key: key);

  @override
  State<ImportPreviewTable> createState() => _ImportPreviewTableState();
}

class _ImportPreviewTableState extends State<ImportPreviewTable> {
  // Shared city/class data — keyed by districtId / orgId (not rowIndex)
  // so 120 rows sharing the same district reuse one cached list
  final Map<int, List<City>> _citiesByDistrict = {};
  final Map<int, List<Organization>> _classesByOrg = {};

  final ScrollController _vCtrl = ScrollController();
  final ScrollController _hCtrl = ScrollController();

  static const double _rowH = 50;
  static const double _headerH = 42;

  static const List<String> _headers = [
    '#',
    'Status',
    'Preferred Name',
    'Full Name',
    'NIC',
    'Date of Birth',
    'Sex',
    'Email',
    'Phone',
    'Street Address',
    'District',
    'City',
    'Organization',
    'Class',
    'Avinya Type',
    'Digital ID',
    'Bank Name',
    'Bank Branch',
    'Account Name',
    'Account Number',
  ];

  static const List<double> _widths = [
    44,
    88,
    130,
    150,
    140,
    118,
    88,
    175,
    118,
    148,
    148,
    148,
    195,
    148,
    195,
    98,
    128,
    128,
    155,
    155,
  ];

  double get _totalWidth => _widths.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _preload();
  }

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  // Deduplicated preload — fetches each unique district/org only once
  Future<void> _preload() async {
    final districtIds = widget.rows
        .where((r) => r.resolvedDistrictId != null)
        .map((r) => r.resolvedDistrictId!)
        .toSet();
    final orgIds = widget.rows
        .where((r) => r.resolvedOrgId != null)
        .map((r) => r.resolvedOrgId!)
        .toSet();

    for (final did in districtIds) {
      final cities = await widget.resolver.getCitiesForDistrict(did);
      if (mounted) setState(() => _citiesByDistrict[did] = cities);
    }
    for (final oid in orgIds) {
      final classes = await widget.resolver.getClassesForOrg(oid);
      if (mounted) setState(() => _classesByOrg[oid] = classes);
    }
  }

  Future<void> _loadCities(int districtId) async {
    if (_citiesByDistrict.containsKey(districtId)) return;
    final cities = await widget.resolver.getCitiesForDistrict(districtId);
    if (mounted) setState(() => _citiesByDistrict[districtId] = cities);
  }

  Future<void> _loadClasses(int orgId) async {
    if (_classesByOrg.containsKey(orgId)) return;
    final classes = await widget.resolver.getClassesForOrg(orgId);
    if (mounted) setState(() => _classesByOrg[orgId] = classes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legend(),
        const SizedBox(height: 6),
        Expanded(
          child: Scrollbar(
            controller: _hCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _hCtrl,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _totalWidth,
                child: Column(children: [
                  // ── Sticky header ──────────────────────────────────────
                  _buildHeader(),
                  const Divider(height: 1, thickness: 1),
                  // ── Virtualised rows — only visible rows are built ─────
                  Expanded(
                    child: Scrollbar(
                      controller: _vCtrl,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _vCtrl,
                        itemCount: widget.rows.length,
                        itemExtent: _rowH,
                        addRepaintBoundaries: true,
                        itemBuilder: (ctx, i) {
                          final row = widget.rows[i];
                          return _ImportRowWidget(
                            key: ValueKey(row.rowIndex),
                            row: row,
                            widths: _widths,
                            rowHeight: _rowH,
                            cities: _citiesByDistrict[
                                    row.resolvedDistrictId ?? -1] ??
                                [],
                            classes:
                                _classesByOrg[row.resolvedOrgId ?? -1] ?? [],
                            resolver: widget.resolver,
                            onChanged: () {
                              setState(() => row.validate());
                              widget.onRowChanged();
                            },
                            onDistrictPicked: (did) async {
                              await _loadCities(did);
                              setState(() {});
                            },
                            onOrgPicked: (oid) async {
                              await _loadClasses(oid);
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: _headerH,
      color: Colors.grey.shade200,
      child: Row(
        children: List.generate(
            _headers.length,
            (i) => SizedBox(
                  width: _widths[i],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(_headers[i],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                )),
      ),
    );
  }

  Widget _legend() {
    return Wrap(spacing: 16, runSpacing: 6, children: [
      _legendDot(Colors.green.shade100, 'Ready'),
      _legendDot(Colors.orange.shade100, 'Needs Review'),
      _legendDot(Colors.red.shade100, 'Error / Unresolved'),
      const Text('Hover over a red cell to see the original Excel value.',
          style: TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-row StatefulWidget
// Each row owns its TextEditingControllers. Flutter reuses the State object
// as rows scroll in/out of view (via ValueKey), so controllers are NEVER
// recreated. This is the key to smooth scrolling with 100+ rows.
// ─────────────────────────────────────────────────────────────────────────────
class _ImportRowWidget extends StatefulWidget {
  final ImportStudentRow row;
  final List<double> widths;
  final double rowHeight;
  final List<City> cities;
  final List<Organization> classes;
  final LookupResolverService resolver;
  final VoidCallback onChanged;
  final Future<void> Function(int districtId) onDistrictPicked;
  final Future<void> Function(int orgId) onOrgPicked;

  const _ImportRowWidget({
    required Key key,
    required this.row,
    required this.widths,
    required this.rowHeight,
    required this.cities,
    required this.classes,
    required this.resolver,
    required this.onChanged,
    required this.onDistrictPicked,
    required this.onOrgPicked,
  }) : super(key: key);

  @override
  State<_ImportRowWidget> createState() => _ImportRowWidgetState();
}

class _ImportRowWidgetState extends State<_ImportRowWidget> {
  late final Map<String, TextEditingController> _ctrl;

  @override
  void initState() {
    super.initState();
    final r = widget.row;
    _ctrl = {
      'preferredName': TextEditingController(text: r.preferredName ?? ''),
      'fullName': TextEditingController(text: r.fullName ?? ''),
      'nicNo': TextEditingController(text: r.nicNo ?? ''),
      'dateOfBirth': TextEditingController(text: r.dateOfBirth ?? ''),
      'email': TextEditingController(text: r.email ?? ''),
      'phone': TextEditingController(text: r.phone ?? ''),
      'streetAddress': TextEditingController(text: r.streetAddress ?? ''),
      'digitalId': TextEditingController(text: r.digitalId ?? ''),
      'bankName': TextEditingController(text: r.bankName ?? ''),
      'bankBranch': TextEditingController(text: r.bankBranch ?? ''),
      'bankAccountName': TextEditingController(text: r.bankAccountName ?? ''),
      'bankAccountNumber':
          TextEditingController(text: r.bankAccountNumber ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  void _notify() {
    setState(() => widget.row.validate());
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final rowColor = row.status == RowStatus.ready
        ? Colors.green.shade50
        : row.status == RowStatus.needsReview
            ? Colors.orange.shade50
            : Colors.red.shade50;

    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(children: [
        _c(0, _idx(row)),
        _c(1, _badge(row)),
        _c(2, _txt('preferredName', (v) => row.preferredName = v)),
        _c(3, _txt('fullName', (v) => row.fullName = v)),
        _c(4, _txt('nicNo', (v) => row.nicNo = v)),
        _c(
            5,
            _txt('dateOfBirth', (v) => row.dateOfBirth = v,
                hint: 'yyyy-MM-dd')),
        _c(6, _sexDrop(row)),
        _c(7, _txt('email', (v) => row.email = v)),
        _c(8, _txt('phone', (v) => row.phone = v)),
        _c(9, _txt('streetAddress', (v) => row.streetAddress = v)),
        _c(10, _districtDrop(row)),
        _c(11, _cityDrop(row)),
        _c(12, _orgDrop(row)),
        _c(13, _classDrop(row)),
        _c(14, _avinyaDrop(row)),
        _c(15, _txt('digitalId', (v) => row.digitalId = v)),
        _c(16, _txt('bankName', (v) => row.bankName = v)),
        _c(17, _txt('bankBranch', (v) => row.bankBranch = v)),
        _c(18, _txt('bankAccountName', (v) => row.bankAccountName = v)),
        _c(19, _txt('bankAccountNumber', (v) => row.bankAccountNumber = v)),
      ]),
    );
  }

  // ── Cell wrapper ───────────────────────────────────────────────────────────
  Widget _c(int colIdx, Widget child) => SizedBox(
        width: widget.widths[colIdx],
        height: widget.rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: child,
        ),
      );

  Widget _idx(ImportStudentRow row) => Center(
      child: Text('${row.rowIndex}',
          style: const TextStyle(color: Colors.grey, fontSize: 12)));

  Widget _badge(ImportStudentRow row) {
    final c = row.status == RowStatus.ready
        ? Colors.green.shade100
        : row.status == RowStatus.needsReview
            ? Colors.orange.shade100
            : Colors.red.shade100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
      child: Text(row.statusLabel,
          style: const TextStyle(fontSize: 10),
          overflow: TextOverflow.ellipsis),
    );
  }

  // ── Text field — uses cached controller, zero allocation on scroll ─────────
  Widget _txt(String key, void Function(String) save, {String? hint}) {
    final err = widget.row.fieldErrors.containsKey(key);
    return Tooltip(
      message: widget.row.fieldErrors[key] ?? '',
      child: TextField(
        controller: _ctrl[key],
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          filled: err,
          fillColor: err ? Colors.red.shade100 : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(color: err ? Colors.red : Colors.grey.shade300)),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        onChanged: (v) {
          save(v.trim());
          _notify();
        },
      ),
    );
  }

  // ── Generic dropdown ───────────────────────────────────────────────────────
  Widget _drop<T>({
    required String fieldKey,
    required T? value,
    required List<T> items,
    required String Function(T) label,
    required void Function(T?) onChanged,
    bool unresolved = false,
    String? rawValue,
  }) {
    final safe = items.contains(value) ? value : null;
    final err = widget.row.fieldErrors.containsKey(fieldKey) || unresolved;
    return Tooltip(
      message: unresolved && rawValue != null
          ? 'Was: "$rawValue" — not found in DB'
          : widget.row.fieldErrors[fieldKey] ?? '',
      child: DropdownButtonFormField<T>(
        value: safe,
        isExpanded: true,
        hint: Text(unresolved ? '⚠ Select...' : 'Select...',
            style: TextStyle(
                fontSize: 11,
                color: unresolved ? Colors.red.shade600 : Colors.grey)),
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: InputDecoration(
          isDense: true,
          filled: err,
          fillColor: err ? Colors.red.shade50 : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(color: err ? Colors.red : Colors.grey.shade300)),
        ),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(label(item),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sexDrop(ImportStudentRow row) => _drop<String>(
        fieldKey: 'sex',
        value: row.sex,
        items: ['Male', 'Female', 'Other'],
        label: (s) => s,
        onChanged: (v) {
          row.sex = v;
          _notify();
        },
      );

  Widget _districtDrop(ImportStudentRow row) => _drop<int>(
        fieldKey: 'district',
        value: row.resolvedDistrictId,
        unresolved: row.resolvedDistrictId == null &&
            (row.districtName?.isNotEmpty ?? false),
        rawValue: row.districtName,
        items: widget.resolver.districts
            .where((d) => d.id != null)
            .map((d) => d.id!)
            .toList(),
        label: (id) =>
            widget.resolver.districts
                .firstWhere((d) => d.id == id, orElse: () => District())
                .name
                ?.name_en ??
            '$id',
        onChanged: (v) async {
          row.resolvedDistrictId = v;
          row.resolvedCityId = null;
          row.cityName = null;
          if (v != null) await widget.onDistrictPicked(v);
          _notify();
        },
      );

  Widget _cityDrop(ImportStudentRow row) {
    final cities = widget.cities;
    if (cities.isEmpty) {
      return Text(
        row.resolvedDistrictId == null ? 'Pick district' : 'Loading...',
        style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic),
      );
    }
    final ids = cities.where((c) => c.id != null).map((c) => c.id!).toList();
    final unresolved = row.resolvedCityId == null &&
        (row.cityName?.isNotEmpty ?? false) &&
        row.resolvedDistrictId != null;
    return _drop<int>(
      fieldKey: 'city',
      value: ids.contains(row.resolvedCityId) ? row.resolvedCityId : null,
      unresolved: unresolved,
      rawValue: row.cityName,
      items: ids,
      label: (id) =>
          cities
              .firstWhere((c) => c.id == id, orElse: () => City())
              .name
              ?.name_en ??
          '$id',
      onChanged: (v) {
        row.resolvedCityId = v;
        row.cityName = cities
            .firstWhere((c) => c.id == v, orElse: () => City())
            .name
            ?.name_en;
        _notify();
      },
    );
  }

  Widget _orgDrop(ImportStudentRow row) => _drop<int>(
        fieldKey: 'organization',
        value: row.resolvedOrgId,
        unresolved: row.resolvedOrgId == null &&
            (row.organizationName?.isNotEmpty ?? false),
        rawValue: row.organizationName,
        items: widget.resolver.validOrganizations
            .where((o) => o.id != null)
            .map((o) => o.id!)
            .toList(),
        label: (id) =>
            widget.resolver.validOrganizations
                .firstWhere((o) => o.id == id, orElse: () => Organization())
                .name
                ?.name_en ??
            '$id',
        onChanged: (v) async {
          row.resolvedOrgId = v;
          row.organizationName = widget.resolver.validOrganizations
              .firstWhere((o) => o.id == v, orElse: () => Organization())
              .name
              ?.name_en;
          row.resolvedClassId = null;
          row.className = null;
          if (v != null) await widget.onOrgPicked(v);
          _notify();
        },
      );

  Widget _classDrop(ImportStudentRow row) {
    final classes = widget.classes;
    if (classes.isEmpty) {
      return Text(row.resolvedOrgId == null ? 'Pick org' : 'No classes',
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic));
    }
    final ids = classes.where((c) => c.id != null).map((c) => c.id!).toList();
    return _drop<int>(
      fieldKey: 'class',
      value: ids.contains(row.resolvedClassId) ? row.resolvedClassId : null,
      items: ids,
      label: (id) =>
          classes
              .firstWhere((c) => c.id == id, orElse: () => Organization())
              .description ??
          '$id',
      onChanged: (v) {
        row.resolvedClassId = v;
        _notify();
      },
    );
  }

  Widget _avinyaDrop(ImportStudentRow row) => _drop<int>(
        fieldKey: 'avinyaType',
        value: row.resolvedAvinyaTypeId,
        unresolved: row.resolvedAvinyaTypeId == null &&
            (row.avinyaTypeName?.isNotEmpty ?? false),
        rawValue: row.avinyaTypeName,
        items: widget.resolver.validAvinyaTypes
            .where((a) => a.id != null)
            .map((a) => a.id!)
            .toList(),
        label: (id) =>
            widget.resolver.validAvinyaTypes
                .firstWhere((a) => a.id == id, orElse: () => AvinyaType())
                .name ??
            '$id',
        onChanged: (v) {
          row.resolvedAvinyaTypeId = v;
          row.avinyaTypeName = widget.resolver.validAvinyaTypes
              .firstWhere((a) => a.id == v, orElse: () => AvinyaType())
              .name;
          _notify();
        },
      );
}
