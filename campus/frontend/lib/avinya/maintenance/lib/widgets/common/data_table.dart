import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Color? headingRowColor;
  final Color? dataRowColor;
  final Color? borderColor;
  final bool showCheckboxColumn;
  final double borderRadius;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headingRowColor,
    this.dataRowColor,
    this.borderColor,
    this.showCheckboxColumn = true,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: DataTable(
          showCheckboxColumn: showCheckboxColumn,
          headingRowColor: headingRowColor != null
              ? MaterialStateProperty.all(headingRowColor)
              : null,
          dataRowColor: dataRowColor != null
              ? MaterialStateProperty.all(dataRowColor)
              : null,
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
