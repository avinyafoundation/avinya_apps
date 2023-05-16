import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class ExcelExport extends StatefulWidget {
  final List<ActivityAttendance> fetchedAttendance;
  final List<String?> columnNames;
  final Organization? fetchedOrganization;

  const ExcelExport(
      {Key? key,
      required this.fetchedAttendance,
      required this.columnNames,
      required this.fetchedOrganization})
      : super(key: key);

  @override
  _ExcelExportState createState() => _ExcelExportState();
}

class _ExcelExportState extends State<ExcelExport> {
  Organization? _fetchedOrganization;
  List<ActivityAttendance> _fetchedAttendance = [];
  List<String?> columnNames = [];

  void exportToExcel() {
    _fetchedAttendance = widget.fetchedAttendance;
    columnNames = widget.columnNames;
    _fetchedOrganization = widget.fetchedOrganization;

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty &&
        columnNames.length > 0) {
      for (var rindex = 0;
          rindex < _fetchedOrganization!.people.length;
          rindex++) {
        for (var index = 0;
            index < columnNames.toSet().toList().length;
            index++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: index, rowIndex: rindex))
              .value = "Absent";
        }
      }

      for (var index = 0;
          index < _fetchedOrganization!.people.length;
          index++) {
        var person = _fetchedOrganization!.people[index];

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index))
            .value = person.preferred_name!;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index))
            .value = person.digital_id.toString();

        int absentCount = 0;

        final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        final dateFormatter = DateFormat('yyyy-MM-dd');

        for (var element in columnNames) {
          if (dateRegex.hasMatch(element!)) {
            try {
              dateFormatter.parseStrict(element);
              absentCount++;
            } catch (e) {
              // Handle the exception or continue to the next element
            }
          }
        }

        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnNames.length - 4, rowIndex: index))
            .value = '0';
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnNames.length - 3, rowIndex: index))
            .value = absentCount.toString();
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnNames.length - 2, rowIndex: index))
            .value = '0';
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnNames.length - 1, rowIndex: index))
            .value = '0';

        for (final attendance in _fetchedAttendance) {
          if (attendance.person_id == person.id) {
            int presentCount = 0;
            int newAbsentCount = 0;
            for (final date in columnNames) {
              if (attendance.sign_in_time != null &&
                  attendance.sign_in_time!.split(" ")[0] == date) {
                presentCount++;
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: columnNames.indexOf(date),
                        rowIndex: index))
                    .value = 'Present';
              }
            }

            newAbsentCount = absentCount - presentCount;

            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnNames.length - 4, rowIndex: index))
                .value = presentCount.toString();
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnNames.length - 3, rowIndex: index))
                .value = newAbsentCount.toString();
            int studentPayment = 100 * presentCount;
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnNames.length - 2, rowIndex: index))
                .value = studentPayment.toDouble().toStringAsFixed(2);
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnNames.length - 1, rowIndex: index))
                .value = studentPayment.toDouble().toStringAsFixed(2);
          }
        }
      }
    }

    excel.save(fileName: "StudentPayment.xlsx");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Export to Excel'),
        onPressed: exportToExcel,
      ),
    );
  }
}
