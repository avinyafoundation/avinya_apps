import 'package:flutter/material.dart';
import '../widgets/add_location_form.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddLocationForm(),
    );
  }
}
