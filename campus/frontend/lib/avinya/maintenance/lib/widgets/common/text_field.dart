import 'package:flutter/material.dart';

class TextFieldForm extends StatelessWidget {

  final String? label;
  final TextEditingController controller;
  final String? hintText;
  final double? width;
  final double? height;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;

  const TextFieldForm({
    super.key,
    this.label,
    required this.controller,
    this.hintText,
    this.width,
    this.height,
    this.maxLines,
    this.textAlignVertical,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label!,
        //   style: const TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        const SizedBox(height: 8),
        SizedBox(
          width: width?? double.infinity,
          height: height,
          child: TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            textAlignVertical: textAlignVertical,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}