import 'package:flutter/material.dart';
import 'scaffold_body.dart';

class SMSScaffold extends StatelessWidget {
  
  const SMSScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SMSScaffoldBody(),
    );
  }
}
