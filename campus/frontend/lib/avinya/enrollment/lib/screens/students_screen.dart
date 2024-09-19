import 'package:flutter/material.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/students.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Students();
  }
}