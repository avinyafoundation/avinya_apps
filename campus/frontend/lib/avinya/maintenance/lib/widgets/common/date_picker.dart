import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final String? selectedDateString;
  final Function(String) onDateSelected;
  final bool enabled; // 👈 NEW

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDateString,
    required this.onDateSelected,
    this.enabled = true, // 👈 default enabled
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedDateString);
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDateString != widget.selectedDateString) {
      _controller.text = widget.selectedDateString ?? '';
    }
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return; // 👈 SAFETY GUARD

    DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      _controller.text = formatted;
      widget.onDateSelected(formatted);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _pickDate : null, // 👈 DISABLE TAP
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller,
          enabled: widget.enabled, // 👈 VISUAL DISABLE
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(
              Icons.calendar_month,
              color: widget.enabled ? null : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
