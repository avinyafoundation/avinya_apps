import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final List<int> selectedItems;
  final int Function(T) valueField;
  final String Function(T) displayField;
  final Function(int) onSelect;
  final Function(int) onUnselect;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.valueField,
    required this.displayField,
    required this.onSelect,
    required this.onUnselect,
  });

  @override
  State<MultiSelectDropdown<T>> createState() =>
      _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T>
    extends State<MultiSelectDropdown<T>> {
  bool _isExpanded = false;
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    // 🔍 Filter items based on search
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

        // ▼ DROPDOWN HEADER ▼
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(_isExpanded
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        // ▼ EXPANDED AREA ▼
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 🔍 SEARCH FIELD
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchText = value);
                  },
                ),
                const SizedBox(height: 8),

                // 📜 SCROLLABLE CHECKBOX LIST
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
                              title:
                                  Text(widget.displayField(item)),
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
        ),
      ],
    );
  }
}