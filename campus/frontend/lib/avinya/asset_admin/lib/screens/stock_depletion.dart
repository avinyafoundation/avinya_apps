import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/stock_depletion.dart';

class StockDepletionScreen extends StatefulWidget {
  const StockDepletionScreen({super.key});

  @override
  State<StockDepletionScreen> createState() => _StockDepletionScreenState();
}

class _StockDepletionScreenState extends State<StockDepletionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        automaticallyImplyLeading: false,
        title: Text("Stock Depletion"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: StockDepletionForm(
            title: 'Stock Depletion',
          ),
        ),
      ),
    );
  }
}
