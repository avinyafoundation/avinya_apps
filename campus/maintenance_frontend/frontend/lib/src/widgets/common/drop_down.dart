import 'package:flutter/material.dart';
//import 'package:mock_maintenance_web/data/organization.dart';

class DropDown<T> extends StatelessWidget {
  final String? label;
  final double? fontSize;
  final double? sizedBoxHeight;
  final List<T> items;
  final int? selectedValues;
  final bool? enabled;
  final int Function(T) valueField;
  final String Function(T) displayField;
  final Function(int?)? onChanged;
  final String? Function(int?)? validator;

  const DropDown({
    super.key,
    this.label,
    this.fontSize,
    this.sizedBoxHeight,
    required this.items,
    this.selectedValues,
    this.enabled = true,
    required this.valueField,
    required this.displayField,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label!,
        //   style: TextStyle(
        //     fontSize: fontSize ?? 16,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        SizedBox(
          height: sizedBoxHeight ?? 6,
        ),
        DropdownButtonFormField<int>(
          key: key,
          value: selectedValues,
          items: items
              .map((item) => DropdownMenuItem(
                    value: valueField(item),
                    child: Text(displayField(item)),
                  ))
              .toList(),
          onChanged: enabled! ? onChanged : null,
          validator: enabled! ? validator : null,
          decoration: InputDecoration(
            // labelText: organizations.isNotEmpty
            //   ? organizations.first.name?.name_en ?? ''
            //   : '',
            border: const OutlineInputBorder(),
            label: label != null ? Text(label!) : null,
          ),
        )
      ],
    );
  }
}
