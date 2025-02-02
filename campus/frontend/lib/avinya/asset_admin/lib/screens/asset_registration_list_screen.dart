import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/registered_asset_list.dart'; // Import the correct file

class AssetRegistrationListScreen extends StatelessWidget {
  const AssetRegistrationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Registration'),
        centerTitle: true,
      ),
      body: const MainAssetScreen(), // Use MainAssetScreen directly
    );
  }
}
