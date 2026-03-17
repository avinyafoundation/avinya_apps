/// Represents one row parsed from the Excel sheet.
/// Holds both raw string values (from Excel) and resolved IDs (from DB lookups).
/// Also tracks per-field validation errors and overall row status.

enum RowStatus { ready, needsReview, error }

class ImportStudentRow {
  // --- Raw values from Excel ---
  String? preferredName;
  String? fullName;
  String? nicNo;
  String? dateOfBirth; // Expected format: yyyy-MM-dd
  String? sex;
  String? email;
  String? phone;
  String? streetAddress;
  String? districtName;
  String? cityName;
  String? organizationName;
  String? className;
  String? avinyaTypeName;
  String? digitalId;
  String? bankName;
  String? bankBranch;
  String? bankAccountName;
  String? bankAccountNumber;

  // --- Resolved IDs (filled by LookupResolverService) ---
  int? resolvedDistrictId;
  int? resolvedCityId;
  int? resolvedOrgId;
  int? resolvedClassId;
  int? resolvedAvinyaTypeId;

  // --- Per-field validation errors (null = no error) ---
  Map<String, String?> fieldErrors = {};

  // --- Row-level status ---
  RowStatus status = RowStatus.needsReview;

  // --- Import result (set after import attempt) ---
  String? importStatus; // 'success', 'skipped', 'failed'
  String? importMessage;

  // --- Original Excel row index (for error reporting) ---
  int rowIndex;

  ImportStudentRow({required this.rowIndex});

  /// Validate all fields and update [fieldErrors] and [status].
  /// Call this after any field edit or after initial resolution.
  void validate() {
    fieldErrors.clear();

    // Required text fields
    if (preferredName == null || preferredName!.trim().isEmpty) {
      fieldErrors['preferredName'] = 'Preferred name is required';
    }
    if (fullName == null || fullName!.trim().isEmpty) {
      fieldErrors['fullName'] = 'Full name is required';
    }

    // NIC validation
    if (nicNo == null || nicNo!.trim().isEmpty) {
      fieldErrors['nicNo'] = 'NIC is required';
    } else {
      final oldNIC = RegExp(r'^\d{9}[vVxX]$');
      final newNIC = RegExp(r'^\d{12}$');
      if (!oldNIC.hasMatch(nicNo!) && !newNIC.hasMatch(nicNo!)) {
        fieldErrors['nicNo'] = 'Invalid NIC format';
      }
    }

    // Date of birth
    if (dateOfBirth == null || dateOfBirth!.trim().isEmpty) {
      fieldErrors['dateOfBirth'] = 'Date of birth is required';
    } else {
      try {
        DateTime.parse(dateOfBirth!);
      } catch (_) {
        fieldErrors['dateOfBirth'] = 'Use yyyy-MM-dd format';
      }
    }

    // Sex
    if (sex == null || sex!.trim().isEmpty) {
      fieldErrors['sex'] = 'Sex is required';
    } else if (!['male', 'female', 'other'].contains(sex!.toLowerCase())) {
      fieldErrors['sex'] = 'Must be Male, Female, or Other';
    }

    // Phone
    if (phone == null || phone!.trim().isEmpty) {
      fieldErrors['phone'] = 'Phone is required';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone!) || phone!.length < 10) {
      fieldErrors['phone'] = 'At least 10 digits required';
    }

    // Email (optional but validated if present)
    if (email != null && email!.isNotEmpty) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!)) {
        fieldErrors['email'] = 'Invalid email format';
      }
    }

    // Resolved ID checks
    if (resolvedDistrictId == null) {
      fieldErrors['district'] = districtName?.isEmpty ?? true
          ? 'District is required'
          : 'District "${districtName}" not found in DB';
    }
    if (resolvedCityId == null) {
      fieldErrors['city'] = cityName?.isEmpty ?? true
          ? 'City is required'
          : 'City "${cityName}" not found for selected district';
    }
    if (resolvedOrgId == null) {
      fieldErrors['organization'] = organizationName?.isEmpty ?? true
          ? 'Organization is required'
          : 'Organization "${organizationName}" not found';
    }
    if (resolvedAvinyaTypeId == null) {
      fieldErrors['avinyaType'] = avinyaTypeName?.isEmpty ?? true
          ? 'Avinya Type is required'
          : 'Avinya Type "${avinyaTypeName}" not found';
    }

    // Update status
    if (fieldErrors.isEmpty) {
      status = RowStatus.ready;
    } else {
      // If any critical field is missing entirely, mark as error
      final criticalErrors = ['preferredName', 'fullName', 'nicNo']
          .any((k) => fieldErrors.containsKey(k));
      status = criticalErrors ? RowStatus.error : RowStatus.needsReview;
    }
  }

  /// Returns true if this row is ready to be imported
  bool get isReady => status == RowStatus.ready;

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case RowStatus.ready:
        return '✅ Ready';
      case RowStatus.needsReview:
        return '🟡 Needs Review';
      case RowStatus.error:
        return '🔴 Error';
    }
  }
}
