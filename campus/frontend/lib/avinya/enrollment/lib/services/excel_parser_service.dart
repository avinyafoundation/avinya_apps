import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';
import '../data/import_student_row.dart';

/// Parses an .xlsx file into a list of [ImportStudentRow].
/// Uses a manual XML parsing fallback if the excel package fails on Web.
class ExcelParserService {
  // Accepts exact names AND common variations (spaces, different wording)
  static const Map<String, String> _columnMap = {
    // preferred_name
    'preferred_name': 'preferredName',
    'preferred name': 'preferredName',
    'preferredname': 'preferredName',
    'nick name': 'preferredName',
    'nickname': 'preferredName',
    // full_name
    'full_name': 'fullName',
    'full name': 'fullName',
    'fullname': 'fullName',
    'name': 'fullName',
    // nic_no
    'nic_no': 'nicNo',
    'nic no': 'nicNo',
    'nic': 'nicNo',
    'nic number': 'nicNo',
    'national id': 'nicNo',
    // date_of_birth
    'date_of_birth': 'dateOfBirth',
    'date of birth': 'dateOfBirth',
    'dob': 'dateOfBirth',
    'birth date': 'dateOfBirth',
    'birthdate': 'dateOfBirth',
    // sex
    'sex': 'sex',
    'gender': 'sex',
    // email
    'email': 'email',
    'email address': 'email',
    // phone
    'phone': 'phone',
    'mobile': 'phone',
    'phone number': 'phone',
    'mobile number': 'phone',
    'contact number': 'phone',
    // street_address
    'street_address': 'streetAddress',
    'street address': 'streetAddress',
    'address': 'streetAddress',
    // district
    'district': 'districtName',
    'district name': 'districtName',
    // city
    'city': 'cityName',
    'city name': 'cityName',
    'town': 'cityName',
    // organization
    'organization': 'organizationName',
    'organisation': 'organizationName',
    'org': 'organizationName',
    // class
    'class': 'className',
    'class name': 'className',
    'batch': 'className',
    // avinya_type
    'avinya_type': 'avinyaTypeName',
    'avinya type': 'avinyaTypeName',
    'programme': 'avinyaTypeName',
    'program': 'avinyaTypeName',
    'course': 'avinyaTypeName',
    // digital_id
    'digital_id': 'digitalId',
    'digital id': 'digitalId',
    'digital id number': 'digitalId',
    // bank_name
    'bank_name': 'bankName',
    'bank name': 'bankName',
    'bank': 'bankName',
    // bank_branch
    'bank_branch': 'bankBranch',
    'bank branch': 'bankBranch',
    'branch': 'bankBranch',
    // bank_account_name
    'bank_account_name': 'bankAccountName',
    'bank account name': 'bankAccountName',
    'account name': 'bankAccountName',
    // bank_account_number
    'bank_account_number': 'bankAccountNumber',
    'bank account number': 'bankAccountNumber',
    'account number': 'bankAccountNumber',
    'account no': 'bankAccountNumber',
  };

  static List<ImportStudentRow> parse(Uint8List fileBytes) {
    print('[ExcelParser] Starting. Bytes: ${fileBytes.length}');

    // Try excel package first
    try {
      final excel = Excel.decodeBytes(fileBytes);
      print(
          '[ExcelParser] excel package decoded OK. Sheets: ${excel.tables.keys.toList()}');
      return _parseViaExcelPackage(excel);
    } catch (e1) {
      print('[ExcelParser] excel package failed: $e1');
    }

    // Fallback: parse xlsx XML manually using archive package
    print('[ExcelParser] Trying manual XML parse...');
    try {
      return _parseManually(fileBytes);
    } catch (e2) {
      print('[ExcelParser] Manual parse also failed: $e2');
      throw FormatException(
        'Could not parse Excel file.\n'
        'Error: $e2\n\n'
        'Please try:\n'
        '• Open your file in Excel\n'
        '• File → Save As → Excel Workbook (.xlsx)\n'
        '• Upload the newly saved file',
      );
    }
  }

  // ── Method 1: via excel package ──────────────────────────────────────────
  static List<ImportStudentRow> _parseViaExcelPackage(Excel excel) {
    if (excel.tables.isEmpty) throw FormatException('No sheets found.');

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;
    if (sheet.rows.isEmpty) throw FormatException('Sheet is empty.');

    print('[ExcelParser] Sheet: "$sheetName", rows: ${sheet.rows.length}');

    final Map<int, String> colToField = {};
    for (int col = 0; col < sheet.rows[0].length; col++) {
      final v = _readCell(sheet.rows[0][col])?.toLowerCase().trim();
      if (v != null && _columnMap.containsKey(v)) {
        colToField[col] = _columnMap[v]!;
        print('[ExcelParser] Header[$col] = "$v"');
      }
    }

    if (colToField.isEmpty) throw FormatException('No matching headers found.');

    final rows = <ImportStudentRow>[];
    for (int i = 1; i < sheet.rows.length; i++) {
      final excelRow = sheet.rows[i];
      if (excelRow.every((c) => _readCell(c) == null)) continue;
      final row = ImportStudentRow(rowIndex: i + 1);
      for (int col = 0; col < excelRow.length; col++) {
        final field = colToField[col];
        if (field != null) _assign(row, field, _readCell(excelRow[col]));
      }
      rows.add(row);
    }

    if (rows.isEmpty) throw FormatException('No data rows found.');
    print('[ExcelParser] Parsed ${rows.length} rows via excel package.');
    return rows;
  }

  // ── Method 2: manual XML parse ───────────────────────────────────────────
  // xlsx is a ZIP file containing XML files. We extract them with the
  // archive package and parse the XML directly — bypasses excel package bugs.
  static List<ImportStudentRow> _parseManually(Uint8List fileBytes) {
    // Decode zip
    final archive = ZipDecoder().decodeBytes(fileBytes);
    print(
        '[ExcelParser] ZIP entries: ${archive.files.map((f) => f.name).toList()}');

    // Get shared strings (text lookup table)
    final sharedStrings = <String>[];
    final ssFile = archive.findFile('xl/sharedStrings.xml');
    if (ssFile != null) {
      final xml = XmlDocument.parse(utf8.decode(ssFile.content as List<int>));
      for (final si in xml.findAllElements('si')) {
        // Concatenate all <t> text nodes within <si>
        final text = si.findAllElements('t').map((t) => t.innerText).join();
        sharedStrings.add(text);
      }
      print('[ExcelParser] Shared strings: ${sharedStrings.length}');
    }

    // Find first sheet
    final sheetFile = archive.findFile('xl/worksheets/sheet1.xml');
    if (sheetFile == null)
      throw FormatException('sheet1.xml not found in xlsx.');

    final xml = XmlDocument.parse(utf8.decode(sheetFile.content as List<int>));
    final rows = xml.findAllElements('row').toList();
    print('[ExcelParser] XML rows found: ${rows.length}');

    if (rows.isEmpty) throw FormatException('No rows in sheet.');

    // Parse header row
    final Map<int, String> colToField = {};
    final headerCells = rows[0].findElements('c').toList();
    for (final cell in headerCells) {
      final colIndex = _cellColIndex(cell.getAttribute('r') ?? '');
      final value = _xmlCellValue(cell, sharedStrings)?.toLowerCase().trim();
      if (value != null && _columnMap.containsKey(value)) {
        colToField[colIndex] = _columnMap[value]!;
        print('[ExcelParser] Header[$colIndex] = "$value"');
      }
    }

    if (colToField.isEmpty) {
      final allHeaders = headerCells
          .map((c) => _xmlCellValue(c, sharedStrings))
          .where((v) => v != null)
          .toList();
      throw FormatException(
        'No matching headers found.\n'
        'Found: ${allHeaders.join(", ")}\n'
        'Expected: preferred_name, full_name, nic_no ...',
      );
    }

    // Parse data rows
    final result = <ImportStudentRow>[];
    for (int i = 1; i < rows.length; i++) {
      final cells = rows[i].findElements('c').toList();
      if (cells.isEmpty) continue;

      final importRow = ImportStudentRow(rowIndex: i + 1);
      bool hasData = false;

      for (final cell in cells) {
        final colIndex = _cellColIndex(cell.getAttribute('r') ?? '');
        final field = colToField[colIndex];
        if (field == null) continue;
        final value = _xmlCellValue(cell, sharedStrings);
        if (value != null) hasData = true;
        _assign(importRow, field, value);
      }

      if (hasData) {
        result.add(importRow);
        print(
            '[ExcelParser] Row ${i + 1}: ${importRow.fullName ?? "(no name)"}');
      }
    }

    if (result.isEmpty) throw FormatException('No data rows found.');
    print('[ExcelParser] Parsed ${result.length} rows via manual XML.');
    return result;
  }

  // Convert cell reference like "A1", "B3", "AA5" to 0-based column index
  static int _cellColIndex(String ref) {
    final letters = ref.replaceAll(RegExp(r'[0-9]'), '');
    int index = 0;
    for (int i = 0; i < letters.length; i++) {
      index = index * 26 + (letters.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }
    return index - 1;
  }

  // Read value from an XML <c> cell element
  static String? _xmlCellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t');

    // ── inlineStr: <c t="inlineStr"><is><t>value</t></is></c> ──
    // Must check FIRST — these cells have no <v> element at all
    if (type == 'inlineStr') {
      final isEl = cell.findElements('is').firstOrNull;
      if (isEl == null) return null;
      // Concatenate all <t> children (handles rich text with multiple <t> nodes)
      final text =
          isEl.findAllElements('t').map((t) => t.innerText).join().trim();
      return text.isEmpty ? null : text;
    }

    // ── All other types need the <v> element ──
    final vElement = cell.findElements('v').firstOrNull;
    if (vElement == null) return null;
    final raw = vElement.innerText.trim();
    if (raw.isEmpty) return null;

    // 's' = shared string index
    if (type == 's') {
      final idx = int.tryParse(raw);
      if (idx != null && idx < sharedStrings.length) {
        final s = sharedStrings[idx].trim();
        return s.isEmpty ? null : s;
      }
      return null;
    }

    // 'b' = boolean
    if (type == 'b') return raw == '1' ? 'true' : 'false';

    // Number (default) — strip trailing .0 for whole numbers
    if (raw.endsWith('.0')) return raw.substring(0, raw.length - 2);

    return raw;
  }

  // ── Read cell via excel package (for Method 1) ───────────────────────────
  static String? _readCell(Data? cell) {
    if (cell == null) return null;
    try {
      final v = cell.value;
      if (v == null) return null;
      String raw = v.toString().trim();
      if (raw.isEmpty || raw == 'null') return null;
      // Strip CellValue wrapper e.g. "TextCellValue(Kamal)" → "Kamal"
      final match =
          RegExp(r'^[A-Za-z]+CellValue\((.+)\)$', dotAll: true).firstMatch(raw);
      if (match != null) raw = match.group(1)?.trim() ?? raw;
      if (raw.isEmpty || raw == 'null') return null;
      if (RegExp(r'^\d+\.0$').hasMatch(raw))
        raw = raw.substring(0, raw.length - 2);
      return raw.isEmpty ? null : raw;
    } catch (e) {
      return null;
    }
  }

  // ── Assign to ImportStudentRow field ─────────────────────────────────────
  static void _assign(ImportStudentRow row, String field, String? raw) {
    switch (field) {
      case 'preferredName':
        row.preferredName = raw;
        break;
      case 'fullName':
        row.fullName = raw;
        break;
      case 'nicNo':
        row.nicNo = raw;
        break;
      case 'dateOfBirth':
        row.dateOfBirth = _parseDate(raw);
        break;
      case 'sex':
        row.sex = _capitalize(raw);
        break;
      case 'email':
        row.email = raw;
        break;
      case 'phone':
        row.phone = raw?.replaceAll(RegExp(r'\D'), '');
        break;
      case 'streetAddress':
        row.streetAddress = raw;
        break;
      case 'districtName':
        row.districtName = raw;
        break;
      case 'cityName':
        row.cityName = raw;
        break;
      case 'organizationName':
        row.organizationName = raw;
        break;
      case 'className':
        row.className = raw;
        break;
      case 'avinyaTypeName':
        row.avinyaTypeName = raw;
        break;
      case 'digitalId':
        row.digitalId = raw;
        break;
      case 'bankName':
        row.bankName = raw;
        break;
      case 'bankBranch':
        row.bankBranch = raw;
        break;
      case 'bankAccountName':
        row.bankAccountName = raw;
        break;
      case 'bankAccountNumber':
        row.bankAccountNumber = raw;
        break;
    }
  }

  static String? _parseDate(String? raw) {
    if (raw == null) return null;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
    try {
      return _fmt(DateTime.parse(raw));
    } catch (_) {}
    final parts = raw.split('/');
    if (parts.length == 3) {
      try {
        return _fmt(DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])));
      } catch (_) {}
    }
    // Handle Excel date serial number
    final serial = double.tryParse(raw);
    if (serial != null && serial > 1000) {
      try {
        final date = DateTime(1899, 12, 30).add(Duration(days: serial.toInt()));
        return _fmt(date);
      } catch (_) {}
    }
    return raw;
  }

  static String _fmt(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static String? _capitalize(String? v) {
    if (v == null || v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1).toLowerCase();
  }
}
