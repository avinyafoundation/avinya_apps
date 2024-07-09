import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:asset_admin/widgets/week_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui';

class ConsumableWeeklyReport extends StatefulWidget {
  const ConsumableWeeklyReport({super.key});

  @override
  State<ConsumableWeeklyReport> createState() => _ConsumableWeeklyReportState();
}

class _ConsumableWeeklyReportState extends State<ConsumableWeeklyReport> {
  List<StockReplenishment> _fetchedConsumableWeeklySummaryData = [];
  bool _isFetching = false;
  DateTime? _selected;

  late DataTableSource _data;

  List<DataColumn> dataTablecolumnNames = [];
  var activityId = 0;
  late int parentOrgId;

  late String formattedStartDate;
  late String formattedEndDate;
  var today = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    parentOrgId = campusAppsPortalInstance.getUserPerson().organization!.id!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedConsumableWeeklySummaryData, updateSelected);
    // DateRangePicker(updateDateRange, formattedStartDate);
  }


  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  void updateDateRange(_rangeStart, _rangeEnd) async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;

    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        _fetchedConsumableWeeklySummaryData =
            await getConsumableWeeklyReport(
                parentOrgId,
                DateFormat('yyyy-MM-dd').format(_rangeStart),
                DateFormat('yyyy-MM-dd').format(_rangeEnd));

        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedConsumableWeeklySummaryData = _fetchedConsumableWeeklySummaryData;
          _isFetching = false;
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> columnNames = [];

    columnNames.add(DataColumn(
        label: Text('Date',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    columnNames.add(DataColumn(
        label: Text('Product Name',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    
    columnNames.add(DataColumn(
        label: Text('Opening Stock(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    
    columnNames.add(DataColumn(
        label: Text('Replenishment(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    columnNames.add(DataColumn(
        label: Text('Balance(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    columnNames.add(DataColumn(
        label: Text('Consumption(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    columnNames.add(DataColumn(
        label: Text('Closing Stock(QTY)',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    columnNames.add(DataColumn(
        label: Text('Unit',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    return columnNames;
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Row(
                  children: [
                    Text(
                      'Select a Week :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                          TextStyle(fontSize: 20),
                        ),
                        elevation: MaterialStateProperty.all(20),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.greenAccent),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      onPressed: _isFetching
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => WeekPicker(
                                        updateDateRange, formattedStartDate)),
                              ),
                      child: Container(
                        height: 50, // Adjust the height as needed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isFetching)
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SpinKitFadingCircle(
                                  color: Colors
                                      .black, // Customize the color of the indicator
                                  size:
                                      20, // Customize the size of the indicator
                                ),
                              ),
                            if (!_isFetching)
                              Icon(Icons.calendar_today, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              '${this.formattedStartDate} - ${this.formattedEndDate}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Wrap(children: [
                if (_isFetching)
                  Container(
                    margin: EdgeInsets.only(top: 180),
                    child: SpinKitCircle(
                      color: (Colors
                          .yellow[700]), // Customize the color of the indicator
                      size: 50, // Customize the size of the indicator
                    ),
                  )
                else if (_fetchedConsumableWeeklySummaryData.length > 0)
                  Container(
                    margin: EdgeInsets.only(left: 10.0, top: 20.0),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: _buildDataColumns(),
                        // header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 50,
                        horizontalMargin: 60,
                        rowsPerPage: 10,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text('No consumable weekly  summary data found'),
                  ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedConsumableWeeklySummaryData, this.updateSelected);

  final List<StockReplenishment> _fetchedConsumableWeeklySummaryData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    
    if (_fetchedConsumableWeeklySummaryData.isEmpty) {
      return null;
    }

    //Group the data by date
    Map<DateTime,List<StockReplenishment>> groupedData = {};

    for(var item in _fetchedConsumableWeeklySummaryData){
      final date = item.updated;
      if(!groupedData.containsKey(date)){
        groupedData[DateTime.parse(date!)] = [];
      }
      groupedData[date]!.add(item);
    }

    // Flatten the grouped data into a list with display flags
    List<_GroupedItem> displayData = [];
    groupedData.forEach((date,items) { 
      for(int i=0;i<items.length;i++){
        displayData.add(_GroupedItem(date,items[i],i==0));
      }
    });

    if (index >= displayData.length) {
      return null;
    }

    final groupedItem  = displayData[index];
    final consumableItem = groupedItem.stockReplenishment;

    List<DataCell> cells = List<DataCell>.filled(8, DataCell.empty);

    // Display date only once for the first item of the group
    cells[0] = DataCell(Text(groupedItem.showDate ? groupedItem.date.toString() : ''));
    cells[1] = DataCell(Center(child: Text(groupedItem.showDate ? groupedItem.date.toString() : '')));
    cells[2] = DataCell(Center(child: Text(groupedItem.showDate ? groupedItem.date.toString() : '')));
    cells[3] = DataCell(Center(child: Text(groupedItem.showDate ? groupedItem.date.toString() : '')));
    cells[4] = DataCell(Text(groupedItem.showDate ? groupedItem.date.toString() : ''));
    cells[5] = DataCell(Text(groupedItem.showDate ? groupedItem.date.toString() : ''));
    cells[6] = DataCell(Text(groupedItem.showDate ? groupedItem.date.toString() : ''));
    cells[7] = DataCell(Text(groupedItem.showDate ? groupedItem.date.toString() : ''));

    return null;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    if (_fetchedConsumableWeeklySummaryData.length > 0) {
      count = _fetchedConsumableWeeklySummaryData.length;
    }
    return count;
  }

  @override
  int get selectedRowCount => 0;
}

class _GroupedItem {
  final DateTime date;
  final StockReplenishment stockReplenishment;
  final bool showDate;

  _GroupedItem(this.date, this.stockReplenishment, this.showDate);
}
