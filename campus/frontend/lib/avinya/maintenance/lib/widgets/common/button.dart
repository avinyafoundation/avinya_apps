import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final String label;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final double? fontSize;

  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: double.infinity,
      height: height ?? 50,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }
}