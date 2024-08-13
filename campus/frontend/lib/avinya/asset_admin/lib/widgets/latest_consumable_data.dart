import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/asset_admin/lib/data/stock_repenishment.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';

class LatestConsumableData extends StatefulWidget {
  const LatestConsumableData({super.key});

  @override
  State<LatestConsumableData> createState() => _LatestConsumableDataState();
}

class _LatestConsumableDataState extends State<LatestConsumableData> {
  List<StockReplenishment> _fetchedLatestConsumableData = [];
  bool _isFetching = false;
  DateTime? _selected;

  late DataTableSource _data;

  List<DataColumn> dataTablecolumnNames = [];
  late int parentOrgId;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedLatestConsumableData);
  }

  Future<void> _fetchInitialData() async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization?.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Show loading indicator
      });
      try {
        _fetchedLatestConsumableData = await getStockListforReplenishment(
            parentOrgId, DateFormat('yyyy-MM-dd').format(DateTime.now()));

        setState(() {
          _isFetching = false;
          _data = MyData(_fetchedLatestConsumableData);
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        // You can show an error message or take appropriate actions here
      } finally {
        setState(() {
          _isFetching = false; // Hide loading indicator
        });
      }
    }
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> columnNames = [];

    columnNames.add(DataColumn(
        label: Center(
      child: Text('Product Name',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
    )));

    columnNames.add(DataColumn(
        label: Center(
      child: Text('On Hand(QTY)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
    )));

    columnNames.add(DataColumn(
        label: Center(
      child: Text('Unit',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
    )));

    return columnNames;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Wrap(children: [
        Center(
          child: Text(
            'Latest Consumable Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isFetching)
          Container(
            margin: EdgeInsets.only(top: 180),
            child: SpinKitCircle(
              color: (Colors.yellow[700]),
              size: 50,
            ),
          )
        else if (_fetchedLatestConsumableData.length > 0)
          Container(
            margin: EdgeInsets.only(left: 10.0, top: 20.0),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 1.2,
                child: PaginatedDataTable(
                  showCheckboxColumn: false,
                  source: _data,
                  columns: _buildDataColumns(),
                  columnSpacing: 50,
                  rowsPerPage: 10,
                ),
              ),
            ),
          )
        else
          Container(
            margin: EdgeInsets.all(20),
            child: Text('No latest consumable data found'),
          ),
      ]),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedLatestConsumableData);

  final List<StockReplenishment> _fetchedLatestConsumableData;

  @override
  DataRow? getRow(int index) {
    var consumableItem = _fetchedLatestConsumableData[index];

    List<DataCell> cells = List<DataCell>.filled(3, DataCell.empty);

    cells[0] = DataCell(
        Center(child: Text(consumableItem.consumable!.name.toString())));
    cells[1] =
        DataCell(Center(child: Text(consumableItem.quantity.toString())));
    cells[2] = DataCell(Center(
        child: Text(consumableItem.resource_property!.value.toString())));

    return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          return consumableItem.is_below_threshold == 1
              ? Colors.red[300]
              : null;
        }),
        cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    if (_fetchedLatestConsumableData.length > 0) {
      count = _fetchedLatestConsumableData.length;
    }
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
