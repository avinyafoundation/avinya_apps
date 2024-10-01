import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import 'package:intl/intl.dart';

class PersonDataExcelReport extends StatefulWidget {
  final List<Person> fetchedPersonData;
  final List<String?> columnNames;
  final Function() updateExcelState;
  final bool isFetching;
  final String formattedStartDate;
  final String formattedEndDate;

  const PersonDataExcelReport(
      {Key? key,
      required this.fetchedPersonData,
      required this.columnNames,
      required this.updateExcelState,
      required this.isFetching,
      required this.formattedStartDate,
      required this.formattedEndDate})
      : super(key: key);

  @override
  _PersonDataExcelReportState createState() => _PersonDataExcelReportState();
}

class _PersonDataExcelReportState extends State<PersonDataExcelReport> {
  List<Person> _fetchedPersonData = [];
  List<String?> columnNames = [];
  List<String?> columnNamesWithoutDates = [];

  void exportToExcel() async {
    await widget.updateExcelState();

    setState(() {
      this._fetchedPersonData = widget.fetchedPersonData;
      this.columnNames = widget.columnNames;
    });

    if (_fetchedPersonData.length > 0) {
      if (columnNamesWithoutDates.isEmpty) {
        columnNamesWithoutDates.addAll([
          "Preferred Name",
          "NIC Number",
          "Mobile Number",
          "Digital ID",
          "Date of Birth",
          "Class"
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
            .cell(
                CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
            .value = columnNamesWithoutDates[colIndex];
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 1))
            .cellStyle = subHeaderStyle;
      }
      sheet.setColWidth(0, 10);
      sheet.setColWidth(1, 25);
      sheet.setColWidth(2, 26);
      sheet.setColWidth(3, 20);
      sheet.setColWidth(4, 25);
      sheet.setColWidth(5, 26);

      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .value =
          "Avinya Foundation Student Enrollment Records for ${widget.formattedEndDate}";
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle = organizationHeaderStyle;

      if (_fetchedPersonData.isNotEmpty) {
        for (var index = 0; index < _fetchedPersonData.length; index++) {
          var personData = _fetchedPersonData[index];
          var org = personData.organization?.avinya_type?.name;

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: index + 2))
              .value = personData.preferred_name?.toString() ?? '';

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: index + 2))
              .value = personData.nic_no?.toString() ?? '';

          sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 2, rowIndex: index + 2))
                  .value =
              (personData.phone?.toString() ?? '') +
                  " "; // update bank branch name

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 3, rowIndex: index + 2))
              .value = personData.digital_id?.toString() ?? '';

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: index + 2))
              .value = (personData.date_of_birth?.toString() ?? '') + " ";

          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 5, rowIndex: index + 2))
              .value = personData.organization?.description?.toString() ?? '';
        }
      }

      excel.save(
          fileName:
              "Student Enrollment Records for ${widget.formattedEndDate}.xlsx");
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isFetching,
      child: ElevatedButton.icon(
        icon: Icon(Icons.download),
        label: Text('Excel Export'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          exportToExcel();
        },
      ),
    );
  }
}
