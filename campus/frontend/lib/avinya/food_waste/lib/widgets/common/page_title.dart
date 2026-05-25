import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final Color? color;

  const PageTitle({
    super.key, 
    required this.title, 
    required this.fontSize, 
    required this.fontWeight,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}