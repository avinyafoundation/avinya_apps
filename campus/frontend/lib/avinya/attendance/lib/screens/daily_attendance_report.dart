// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:intl/intl.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  State<DataTableDemo> createState() => _DataTableDemoState();
}

class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [_Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<_Dessert> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}

class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
  final _RestorableDessertSelections _dessertSelections =
      _RestorableDessertSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);
  _DessertDataSource? _dessertsDataSource;

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    _dessertsDataSource ??= _DessertDataSource(context);
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!._sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource!
            ._sort<num>((d) => d.calories, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource!._sort<num>((d) => d.fat, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource!._sort<num>((d) => d.carbs, _sortAscending.value);
        break;
    }
    _dessertsDataSource!.updateSelectedDesserts(_dessertSelections);
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dessertsDataSource ??= _DessertDataSource(context);
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  void _updateSelectedDessertRowListener() {
    _dessertSelections.setDessertSelections(_dessertsDataSource!._desserts);
  }

  void _sort<T>(
    Comparable<T> Function(_Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource!._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = GalleryLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("demoDataTableTitle"),
      ),
      body: Scrollbar(
        child: ListView(
          restorationId: 'data_table_list_view',
          padding: const EdgeInsets.all(16),
          children: [
            PaginatedDataTable(
              header: Text("dataTableHeader"),
              rowsPerPage: _rowsPerPage.value,
              showCheckboxColumn: false,
              onRowsPerPageChanged: (value) {
                setState(() {
                  _rowsPerPage.value = value!;
                });
              },
              initialFirstRowIndex: _rowIndex.value,
              onPageChanged: (rowIndex) {
                setState(() {
                  _rowIndex.value = rowIndex;
                });
              },
              sortColumnIndex: _sortColumnIndex.value,
              sortAscending: _sortAscending.value,
              onSelectAll: _dessertsDataSource!._selectAll,
              columns: [
                DataColumn(
                  label: Text("Student Name"),
                  onSort: (columnIndex, ascending) =>
                      _sort<String>((d) => d.name, columnIndex, ascending),
                ),
                DataColumn(
                  label: Text("Sign In"),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort<num>((d) => d.calories, columnIndex, ascending),
                ),
                DataColumn(
                  label: Text("Sign Out"),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort<num>((d) => d.fat, columnIndex, ascending),
                ),
                DataColumn(
                  label: Text("After School"),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort<num>((d) => d.carbs, columnIndex, ascending),
                ),
              ],
              source: _dessertsDataSource!,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dessert {
  _Dessert(
    this.name,
    this.calories,
    this.fat,
    this.carbs,
  );

  final String name;
  final int calories;
  final double fat;
  final int carbs;
  bool selected = false;
}

class _DessertDataSource extends DataTableSource {
  _DessertDataSource(this.context) {
    // final localizations = GalleryLocalizations.of(context)!;
    _desserts = <_Dessert>[
      _Dessert(
        "dataTableRowFrozenYogurt",
        159,
        6.0,
        24,
      ),
      _Dessert(
        "dataTableRowFrozenYogurt",
        237,
        9.0,
        37,
      ),
      _Dessert(
        "dataTableRowFrozenYogurt",
        262,
        16.0,
        24,
      ),
    ];
  }

  final BuildContext context;
  late List<_Dessert> _desserts;

  void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
    _desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < _desserts.length; i += 1) {
      var dessert = _desserts[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    final format = NumberFormat.decimalPercentPattern(
      locale: GalleryOptions.of(context).locale.toString(),
      decimalDigits: 0,
    );
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: (value) {
        if (dessert.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.calories}')),
        DataCell(Text(dessert.fat.toStringAsFixed(1))),
        DataCell(Text('${dessert.carbs}')),
      ],
    );
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool? checked) {
    for (final dessert in _desserts) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = checked! ? _desserts.length : 0;
    notifyListeners();
  }
}
