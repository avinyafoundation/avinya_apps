import 'package:flutter/material.dart';

class ColourfulDropdown extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final Color Function(String) getColorForValue;

  const ColourfulDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getColorForValue,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: Container(),
      focusColor: Colors.transparent,
      items: items,
      onChanged: onChanged,
      style: TextStyle(
        color: getColorForValue(value),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
