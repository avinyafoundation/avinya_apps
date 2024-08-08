import 'package:flutter/material.dart';
import 'package:gallery/avinya/asset_admin/lib/widgets/vehicle_fuel_consumption.dart';

class VehicleFuelConsumptionScreen extends StatefulWidget {
  const VehicleFuelConsumptionScreen({super.key});

  @override
  State<VehicleFuelConsumptionScreen> createState() => _VehicleFuelConsumptionScreenState();
}

class _VehicleFuelConsumptionScreenState extends State<VehicleFuelConsumptionScreen> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Vehicle Fuel Consumption"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: VehicleFuelConsumption(),
        ),
      ),
    );
  }
}