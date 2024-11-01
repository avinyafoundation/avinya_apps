import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class MonthlyPaymentReportExcelExport extends StatefulWidget {
  final List<ActivityAttendance> fetchedAttendance;
  final List<String?> columnNames;
  final List<Person> fetchedStudentList;
  final Function() updateExcelState;
  final bool isFetching;
  final List<int> totalSchoolDaysInMonth;
  final double dailyAmount;
  final int numberOfDaysInMonth;
  final int year;
  final String month;
  final List<String?> classes;

  const MonthlyPaymentReportExcelExport({
    Key? key,
    required this.classes,
    required this.fetchedAttendance,
    required this.columnNames,
    required this.fetchedStudentList,
    required this.updateExcelState,
    required this.isFetching,
    required this.totalSchoolDaysInMonth,
    required this.dailyAmount,
    required this.numberOfDaysInMonth,
    required this.year,
    required this.month,
  }) : super(key: key);

  @override
  _ExcelExportState createState() => _ExcelExportState();
}

class _ExcelExportState extends State<MonthlyPaymentReportExcelExport> {
  List<Person> _fetchedStudentList = [];
  List<ActivityAttendance> _fetchedAttendance = [];
  List<String?> columnNames = [];
  List<String?> columnNamesWithoutDates = [];

  void exportToExcel() async {
    await widget.updateExcelState();
    // _fetchedAttendance = widget.fetchedAttendance;
    // _fetchedStudentList = widget.fetchedStudentList;
    // columnNames = widget.columnNames;
    setState(() {
      this._fetchedAttendance = widget.fetchedAttendance;
      this._fetchedStudentList = widget.fetchedStudentList;
      this.columnNames = widget.columnNames;
    });
    if (_fetchedAttendance.length > 0) {
      // Add null check here
      // Process attendance data here
      columnNames.clear();
      List<String?> names = _fetchedAttendance
          .map((attendance) => attendance.sign_in_time?.split(" ")[0])
          .where((name) => name != null) // Filter out null values
          .toSet()
          .toList();
      columnNames.addAll(names);
    } else {
      columnNames.clear();
    }

    if (columnNamesWithoutDates.isEmpty) {
      columnNamesWithoutDates.addAll([
        "Student Name",
        "Bank",
        "Account Number",
        "Attendance",
        "Net Amount"
      ]);
    }

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
    for (var colIndex = 0;
        colIndex < columnNamesWithoutDates.length;
        colIndex++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .value = columnNamesWithoutDates[colIndex];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
          .cellStyle = subHeaderStyle;
    }
    sheet.setColWidth(0, 50);
    sheet.setColWidth(1, 25);
    sheet.setColWidth(2, 26);
    sheet.setColWidth(3, 20);
    sheet.setColWidth(4, 25);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        "Avinya Foundation Student Payment Report For Year ${widget.year} For Month ${widget.month}";
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = organizationHeaderStyle;

    if (_fetchedStudentList.isNotEmpty && columnNames.length > 0) {
      int i = 0;
      int next_class_start_index = 0;
      int first_class_student_length = 0;

      for (var class_index = 0;
          class_index < widget.classes.length;
          class_index++) {
        String? className = widget.classes[class_index];

        List<Person> personListByClass = _fetchedStudentList
            .where((person) => person.organization!.description == className)
            .toList();

        if (personListByClass.length == 0) {
          continue;
        }

        if (i == 0) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: next_class_start_index + 2))
              .value = "${className.toString()}";
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: next_class_start_index + 2))
              .cellStyle = organizationHeaderStyle;
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: next_class_start_index + 2))
              .value = "";

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: next_class_start_index + 2))
              .value = "${widget.dailyAmount} per day";

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: next_class_start_index + 2))
              .cellStyle = organizationHeaderStyle;

          next_class_start_index = 3;
          i++;
        } else {

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: next_class_start_index))
              .value = "${className.toString()}";
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: next_class_start_index))
              .cellStyle = organizationHeaderStyle;

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: next_class_start_index))
              .value = "";

          next_class_start_index++;
        }

        for (var index = 0; index < personListByClass.length; index++) {
          var person = personListByClass[index];
          print("person name:${person.full_name}");
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: index + next_class_start_index))
              .value = person.full_name?.toString() ?? '';

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: index + next_class_start_index))
              .value = person.bank_name?.toString() ?? '';

          sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 2, rowIndex: index + next_class_start_index))
                  .value =
              person.bank_account_number?.toString() ??
                  ''; // update bank branch name

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

              double studentPayment = widget.dailyAmount * presentCount;
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 3, rowIndex: index + next_class_start_index))
                  .value = '${presentCount}/${widget.totalSchoolDaysInMonth}';
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 4, rowIndex: index + next_class_start_index))
                  .value = studentPayment.toDouble().toStringAsFixed(2);
            }
          }
        }

        next_class_start_index =
            next_class_start_index + personListByClass.length;
      }
    }

    excel.save(fileName: "StudentPayment_For_${widget.month}.xlsx");
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isFetching,
      child: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.file_download),
        onPressed: () {
          exportToExcel();
        },
      ),
    );
  }
}
