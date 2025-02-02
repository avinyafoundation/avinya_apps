import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/asset_registration.dart';

class AssetRegistrationScreen extends StatelessWidget {
  const AssetRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Registration'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width * 0.9,
            child: const AssetRegistrationForm(),
          ),
        ),
      ),
    );
  }
}
