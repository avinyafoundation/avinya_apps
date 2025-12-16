// import 'package:flutter/material.dart';

// class MultiSelectList<T> extends StatelessWidget {

//   final String label;
//   final double labelTextSize;
//   final List<T> items;
//   final List<int> selectedItems;
//   final Function(int) onSelect;
//   final Function(int) onUnselect;

//   final int Function(T) valueField;
//   final String Function(T) displayField;

//   const MultiSelectList({
//     super.key,
//     required this.label,
//     required this.labelTextSize,
//     required this.items,
//     required this.selectedItems,
//     required this.onSelect,
//     required this.onUnselect,
//     required this.valueField,
//     required this.displayField,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: labelTextSize,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           height: 150,
//           child: ListView(
//             children: items.map((item){
//               final id = valueField(item);
//               bool isSelected = selectedItems.contains(id);
//               return CheckboxListTile(
//                 title: Text(displayField(item)),
//                 value: isSelected,
//                 onChanged: (bool? value) {
//                   if (value == true) {
//                     onSelect(id);
//                   } else {
//                     onUnselect(id);
//                   }
//                 },
//               );
//             }).toList(),
//           ),
//         )
//       ],
//     );
//   }
// }






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
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(widget.label,
        //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        

        // ▼ DROPDOWN HEADER ▼
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        ? "${widget.label}"
                        : widget.items
                            .where((item) =>
                                widget.selectedItems.contains(
                                    widget.valueField(item)))
                            .map((item) => widget.displayField(item))
                            .join(", "),
                    style: TextStyle(
                        color: widget.selectedItems.isEmpty
                            ? Colors.black
                            : Colors.black,
                            fontSize: 16),
                  ),
                ),
                Icon(_isExpanded
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        // ▼ EXPANDED CHECKBOX LIST ▼
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              children: widget.items.map((item) {
                final id = widget.valueField(item);
                bool isSelected = widget.selectedItems.contains(id);

                return CheckboxListTile(
                  title: Text(widget.displayField(item)),
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
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
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}
