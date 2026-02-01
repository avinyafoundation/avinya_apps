import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends FormField<List<int>> {
  MultiSelectDropdown({
    super.key,
    required String label,
    required List<T> items,
    required List<int> selectedItems,
    required int Function(T) valueField,
    required String Function(T) displayField,
    required Function(int) onSelect,
    required Function(int) onUnselect,
    FormFieldValidator<List<int>>? validator,
  }) : super(
          initialValue: selectedItems,
          validator: validator,
          builder: (FormFieldState<List<int>> state) {
            return _MultiSelectDropdownBody<T>(
              label: label,
              items: items,
              selectedItems: selectedItems,
              valueField: valueField,
              displayField: displayField,
              errorText: state.errorText,
              onSelect: (id) {
                onSelect(id);
                state.didChange(selectedItems); // notify Form
              },
              onUnselect: (id) {
                onUnselect(id);
                state.didChange(selectedItems); // notify Form
              },
            );
          },
        );
}

/// ----------------------------------------------------------------
/// INTERNAL STATEFUL UI
/// ----------------------------------------------------------------
class _MultiSelectDropdownBody<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final List<int> selectedItems;
  final int Function(T) valueField;
  final String Function(T) displayField;
  final Function(int) onSelect;
  final Function(int) onUnselect;
  final String? errorText;

  const _MultiSelectDropdownBody({
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.valueField,
    required this.displayField,
    required this.onSelect,
    required this.onUnselect,
    this.errorText,
  });

  @override
  State<_MultiSelectDropdownBody<T>> createState() =>
      _MultiSelectDropdownBodyState<T>();
}

class _MultiSelectDropdownBodyState<T>
    extends State<_MultiSelectDropdownBody<T>> {
  bool _isExpanded = false;
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return widget
          .displayField(item)
          .toLowerCase()
          .contains(_searchText.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ▼ HEADER
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedItems.isEmpty
                        ? widget.label
                        : widget.items
                            .where((item) => widget.selectedItems
                                .contains(widget.valueField(item)))
                            .map(widget.displayField)
                            .join(", "),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),

        // ERROR MESSAGE
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),

        // ▼ EXPANDED PANEL
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // SEARCH
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchText = value);
                  },
                ),
                const SizedBox(height: 8),

                // CHECKBOX LIST
                SizedBox(
                  height: 180,
                  child: filteredItems.isEmpty
                      ? const Center(child: Text("No results found"))
                      : ListView(
                          children: filteredItems.map((item) {
                            final id = widget.valueField(item);
                            final isSelected =
                                widget.selectedItems.contains(id);

                            return CheckboxListTile(
                              dense: true,
                              title: Text(widget.displayField(item)),
                              value: isSelected,
                              onChanged: (checked) {
                                if (checked == true) {
                                  widget.onSelect(id);
                                } else {
                                  widget.onUnselect(id);
                                }
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
