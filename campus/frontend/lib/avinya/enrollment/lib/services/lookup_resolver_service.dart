import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import '../data/import_student_row.dart';

/// Pre-loads all reference data once, then resolves human-readable names to DB IDs.
/// Cache is kept alive for the entire import session.
class LookupResolverService {
  List<District> _districts = [];
  List<Organization> _organizations = [];
  List<AvinyaType> _avinyaTypes = [];

  // City cache: districtId -> List<City> (loaded on demand)
  final Map<int, List<City>> _cityCache = {};

  // Class cache: orgId -> List<Organization>
  final Map<int, List<Organization>> _classCache = {};

  bool _isInitialized = false;

  /// Call this once before processing any rows.
  /// Loads districts, organizations, and avinya types into memory.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _districts = await fetchDistricts();
    _organizations = await fetchOrganizations();
    _avinyaTypes = await fetchAvinyaTypes();
    _isInitialized = true;
  }

  /// Returns all districts (for dropdown population in the preview table)
  List<District> get districts => _districts;

  /// Returns all organizations filtered to valid types (same filter as StudentCreate)
  List<Organization> get validOrganizations => _organizations
      .where((org) =>
          org.avinya_type?.id == 105 ||
          org.avinya_type?.id == 86 ||
          org.avinya_type?.id == 108)
      .toList();

  /// Returns filtered avinya types (same filter as StudentCreate)
  List<AvinyaType> get validAvinyaTypes => _avinyaTypes.where((t) {
        const validIds = [
          26,
          37,
          10,
          96,
          93,
          100,
          99,
          103,
          94,
          110,
          111,
          115,
          116,
          120,
          121,
          125,
          126
        ];
        return validIds.contains(t.id);
      }).toList();

  /// Fetch and cache cities for a district
  Future<List<City>> getCitiesForDistrict(int districtId) async {
    if (!_cityCache.containsKey(districtId)) {
      _cityCache[districtId] = await fetchCities(districtId);
    }
    return _cityCache[districtId]!;
  }

  /// Fetch and cache classes for an organization
  Future<List<Organization>> getClassesForOrg(int orgId) async {
    if (!_classCache.containsKey(orgId)) {
      _classCache[orgId] = await fetchClasses(orgId);
    }
    return _classCache[orgId]!;
  }

  /// Resolve a single row: fills all resolvedXxxId fields.
  /// Also fetches cities/classes as needed and caches them.
  Future<void> resolveRow(ImportStudentRow row) async {
    assert(_isInitialized, 'Call initialize() before resolveRow()');

    // --- Resolve District ---
    final district = _findDistrict(row.districtName);
    row.resolvedDistrictId = district?.id;

    // --- Resolve City (depends on district) ---
    if (district != null) {
      final cities = await getCitiesForDistrict(district.id!);
      final city = _findByName(
        row.cityName,
        cities.map((c) => _NameId(c.name?.name_en, c.id)).toList(),
      );
      row.resolvedCityId = city;
    } else {
      row.resolvedCityId = null;
    }

    // --- Resolve Organization ---
    final org = _findByName(
      row.organizationName,
      validOrganizations.map((o) => _NameId(o.name?.name_en, o.id)).toList(),
    );
    row.resolvedOrgId = org;

    // --- Resolve Class (depends on org) ---
    if (org != null) {
      final classList = await getClassesForOrg(org);
      final cls = _findByName(
        row.className,
        classList.map((c) => _NameId(c.description, c.id)).toList(),
      );
      row.resolvedClassId = cls;
    } else {
      row.resolvedClassId = null;
    }

    // --- Resolve Avinya Type ---
    final avinyaType = _findByName(
      row.avinyaTypeName,
      validAvinyaTypes.map((a) => _NameId(a.name, a.id)).toList(),
    );
    row.resolvedAvinyaTypeId = avinyaType;

    // --- Run validation after resolution ---
    row.validate();
  }

  /// Resolve all rows. Returns progress via [onProgress] callback.
  Future<void> resolveAll(
    List<ImportStudentRow> rows, {
    void Function(int current, int total)? onProgress,
  }) async {
    for (int i = 0; i < rows.length; i++) {
      await resolveRow(rows[i]);
      onProgress?.call(i + 1, rows.length);
    }
  }

  // ---- Private helpers ----

  District? _findDistrict(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    try {
      return _districts.firstWhere(
        (d) => _normalize(d.name?.name_en) == _normalize(name),
      );
    } catch (_) {
      return null;
    }
  }

  int? _findByName(String? name, List<_NameId> options) {
    if (name == null || name.trim().isEmpty) return null;
    try {
      return options
          .firstWhere((o) => _normalize(o.name) == _normalize(name))
          .id;
    } catch (_) {
      return null;
    }
  }

  String _normalize(String? s) =>
      (s ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Simple helper to hold name+id pairs for generic lookup
class _NameId {
  final String? name;
  final int? id;
  _NameId(this.name, this.id);
}
