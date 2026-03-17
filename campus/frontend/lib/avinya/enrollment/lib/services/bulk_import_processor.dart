import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import '../data/import_student_row.dart';

// This service processes the bulk import of students from a CSV file.

/// Result of a single row import attempt
class ImportRowResult {
  final int rowIndex;
  final String? nic;
  final String? name;
  final String status; // 'success' | 'skipped' | 'failed'
  final String? message;

  ImportRowResult({
    required this.rowIndex,
    this.nic,
    this.name,
    required this.status,
    this.message,
  });
}

/// Processes the import of ready rows, one by one.
/// Skips rows with duplicate NIC. Never stops on error.
class BulkImportProcessor {
  /// Import all [rows] that have status == RowStatus.ready.
  ///
  /// [context] - needed for createPerson()
  /// [onProgress] - called after each row attempt (current, total, lastResult)
  Future<List<ImportRowResult>> process(
    BuildContext context,
    List<ImportStudentRow> rows, {
    void Function(int current, int total, ImportRowResult lastResult)?
        onProgress,
  }) async {
    final readyRows = rows.where((r) => r.isReady).toList();
    final List<ImportRowResult> results = [];

    for (int i = 0; i < readyRows.length; i++) {
      final row = readyRows[i];
      ImportRowResult result;

      try {
        final person = _mapToPerson(row);
        final created = await createPerson(context, person);

        if (created.id != null) {
          row.importStatus = 'success';
          result = ImportRowResult(
            rowIndex: row.rowIndex,
            nic: row.nicNo,
            name: row.fullName,
            status: 'success',
          );
        } else {
          row.importStatus = 'failed';
          row.importMessage = 'No ID returned from server';
          result = ImportRowResult(
            rowIndex: row.rowIndex,
            nic: row.nicNo,
            name: row.fullName,
            status: 'failed',
            message: 'No ID returned from server',
          );
        }
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '');

        // Duplicate NIC — skip gracefully
        if (msg.toLowerCase().contains('already exists')) {
          row.importStatus = 'skipped';
          row.importMessage = msg;
          result = ImportRowResult(
            rowIndex: row.rowIndex,
            nic: row.nicNo,
            name: row.fullName,
            status: 'skipped',
            message: msg,
          );
        } else {
          // Any other error — log as failed, continue
          row.importStatus = 'failed';
          row.importMessage = msg;
          result = ImportRowResult(
            rowIndex: row.rowIndex,
            nic: row.nicNo,
            name: row.fullName,
            status: 'failed',
            message: msg,
          );
        }
      }

      results.add(result);
      onProgress?.call(i + 1, readyRows.length, result);
    }

    return results;
  }

  /// Maps an [ImportStudentRow] to a [Person] object ready for the API
  Person _mapToPerson(ImportStudentRow row) {
    final person = Person();

    person.preferred_name = row.preferredName;
    person.full_name = row.fullName;
    person.nic_no = row.nicNo;
    person.date_of_birth = row.dateOfBirth;
    person.sex = row.sex;
    person.email = row.email;
    person.phone = int.tryParse(row.phone ?? '');
    person.digital_id = row.digitalId;
    person.bank_name = row.bankName;
    person.bank_branch = row.bankBranch;
    person.bank_account_name = row.bankAccountName;
    person.bank_account_number = row.bankAccountNumber;
    person.parent_organization_id = row.resolvedOrgId;
    person.organization_id = row.resolvedClassId;
    person.avinya_type_id = row.resolvedAvinyaTypeId;

    // Mailing address
    if (row.streetAddress != null ||
        row.resolvedCityId != null ||
        row.resolvedDistrictId != null) {
      person.mailing_address = Address(
        street_address: row.streetAddress,
        city_id: row.resolvedCityId,
        district_id: row.resolvedDistrictId,
      );
      if (row.resolvedCityId != null) {
        person.mailing_address!.city = City(id: row.resolvedCityId);
      }
    }

    return person;
  }
}
