import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/stock_replenishment.dart';

class StockReplenishmentScreen extends StatefulWidget {
  const StockReplenishmentScreen({super.key});

  @override
  State<StockReplenishmentScreen> createState() =>
      _StockReplenishmentScreenState();
}

class _StockReplenishmentScreenState extends State<StockReplenishmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Stock Replenishment"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: StockReplenishmentForm(
            title: 'Stock Replenishment',
          ),
        ),
      ),
    );
  }
}
