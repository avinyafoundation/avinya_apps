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
  List<String?> columnNamesWithoutDates = [];

  static String generateTransactionCode(DateTime date) {
    // Create a DateTime object for the first day of the given year
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);

    // Calculate the difference in days between the given date and the first day of the year
    int diffDays = date.difference(firstDayOfYear).inDays;

    // Calculate the week number by dividing the difference in days by 7 and adding 1
    int weekNumber = (diffDays / 7).ceil() + 1;

    String formattedDate = DateFormat('yy').format(date);

    // Generate the transaction code
    final transactionCode = '0${formattedDate}-Salaries-W$weekNumber';

    return transactionCode;
  }

  DateTime getNextWeekMonday(DateTime date) {
    // Calculate the number of days to the next Monday
    int daysUntilNextMonday = DateTime.monday - date.weekday;

    // Adjust the days if the next Monday is in the following week
    if (daysUntilNextMonday <= 0) {
      daysUntilNextMonday += 7;
    }

    // Add the days to the given date to get the next week's Monday
    DateTime nextWeekMonday = date.add(Duration(days: daysUntilNextMonday));

    return nextWeekMonday;
  }

  void exportToExcel() {
    _fetchedAttendance = widget.fetchedAttendance;
    columnNames = widget.columnNames;
    _fetchedOrganization = widget.fetchedOrganization;

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final dateFormatter = DateFormat('yyyy-MM-dd');
    List<String?> dateColumns =
        columnNames.where((name) => dateRegex.hasMatch(name!)).toList();

    String? fromDate = dateColumns.isNotEmpty ? dateColumns.first : '';
    String? toDate = dateColumns.isNotEmpty ? dateColumns.last : '';

    columnNamesWithoutDates.addAll([
      "Referance No",
      "Staff Account Name",
      "Bank Name",
      "Branch Name",
      "Staff Credit Account No",
      "Transaction Code",
      "Amount",
      "YYYY",
      "MM",
      "DD"
    ]);

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Styling for organization header
    final organizationHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: '#807f7d',
      horizontalAlign: HorizontalAlign.Center,
    );

    // Styling for row cells
    final rowCellsStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );

    // Adding organization header
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(
          columnIndex: columnNamesWithoutDates.length - 1, rowIndex: 0),
    );

    // Adding subheaders
    final subHeaderStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: '#a3a3a2',
      textWrapping: TextWrapping.WrapText,
    );

    // Adding column headers
    for (var columnIndex = 0;
        columnIndex < columnNamesWithoutDates.length;
        columnIndex++) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1))
          .value = columnNamesWithoutDates[columnIndex];
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1))
          .cellStyle = subHeaderStyle;
    }
    sheet.setColWidth(0, 10);
    sheet.setColWidth(1, 25);
    sheet.setColWidth(2, 22);
    sheet.setColWidth(3, 20);
    sheet.setColWidth(4, 25);
    sheet.setColWidth(5, 26);
    sheet.setColWidth(6, 25);
    sheet.setColWidth(7, 25);
    sheet.setColWidth(8, 25);
    sheet.setColWidth(9, 25);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        "Avinya Foundation Student Payment Report From ${fromDate} to ${toDate}";
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = organizationHeaderStyle;

    if (_fetchedOrganization != null &&
        _fetchedOrganization!.people.isNotEmpty &&
        columnNames.length > 0) {
      for (var index = 0;
          index < _fetchedOrganization!.people.length;
          index++) {
        var person = _fetchedOrganization!.people[index];

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index + 2))
            .value = index + 1;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: index + 2))
            .cellStyle = rowCellsStyle;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: index + 2))
            .value = person.bank_account_name?.toString() ?? '';

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: index + 2))
            .value = person.bank_name?.toString() ?? '';

        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 3, rowIndex: index + 2))
                .value =
            person.bank_name?.toString() ?? ''; // update bank branch name

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: index + 2))
            .value = person.bank_account_number?.toString() ?? '';

        var generatedTransactionCode =
            generateTransactionCode(DateTime.parse(toDate!));
        var generatedNextWeekMonday =
            getNextWeekMonday(DateTime.parse(toDate!));

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: index + 2))
            .value = generatedTransactionCode;
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: index + 2))
            .cellStyle = rowCellsStyle;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: index + 2))
            .value = DateFormat('yyyy').format(generatedNextWeekMonday);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: index + 2))
            .cellStyle = rowCellsStyle;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: index + 2))
            .value = DateFormat('MM').format(generatedNextWeekMonday);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: index + 2))
            .cellStyle = rowCellsStyle;

        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: index + 2))
            .value = DateFormat('dd').format(generatedNextWeekMonday);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: index + 2))
            .cellStyle = rowCellsStyle;

        int presentCount = 0;
        for (final attendance in _fetchedAttendance) {
          if (attendance.person_id == person.id) {
            // int newAbsentCount = 0;
            for (final date in columnNames) {
              if (attendance.sign_in_time != null &&
                  attendance.sign_in_time!.split(" ")[0] == date) {
                presentCount++;
              }
            }

            int studentPayment = 100 * presentCount;
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 6, rowIndex: index + 2))
                .value = studentPayment.toDouble().toStringAsFixed(2);
          }
        }
      }
    }

    excel.save(fileName: "StudentPayment_${fromDate}_to_${toDate}.xlsx");
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
