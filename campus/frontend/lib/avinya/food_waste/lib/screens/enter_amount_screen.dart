import 'package:flutter/material.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/button.dart';

class EnterAmountScreen extends StatefulWidget {
  final String foodItem;
  final int? foodId;
  final double? costPerPortion;
  final int? initialPortions;

  const EnterAmountScreen({
    super.key,
    required this.foodItem,
    this.foodId,
    this.costPerPortion,
    this.initialPortions,
  });

  @override
  State<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends State<EnterAmountScreen> {
  final _portionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPortions != null) {
      _portionsController.text = widget.initialPortions.toString();
    }
    _portionsController.addListener(_onPortionsChanged);
  }

  @override
  void dispose() {
    _portionsController.removeListener(_onPortionsChanged);
    _portionsController.dispose();
    super.dispose();
  }

  void _onPortionsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final costPerPortion = widget.costPerPortion ?? 50.0;
    final portions = double.tryParse(_portionsController.text) ?? 0;
    final estimatedCost = portions * costPerPortion;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Back button and title row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: PageTitle(
                          title: 'Food Waste Amount',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172B4D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Food Item Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.foodItem,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cost per portion: LKR ${costPerPortion.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Portions Input Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waste Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the number of portions that were wasted',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _portionsController,
                          decoration: InputDecoration(
                            labelText: 'Portions Remaining',
                            hintText: 'e.g., 10',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon:
                                Icon(Icons.numbers, color: Colors.blue[700]),
                            helperText:
                                'Enter the number of people this leftover could feed',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cost Estimation Card
                  if (_portionsController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.monetization_on_outlined,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Waste Cost',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'LKR ${estimatedCost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        buttonColor: Colors.grey[100],
                        textColor: Colors.grey[800],
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      Button(
                        label: 'Add to Log',
                        onPressed: _addToLog,
                        buttonColor: const Color.fromARGB(255, 2, 127, 6),
                        textColor: Colors.white,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addToLog() {
    if (_portionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter portions')),
      );
      return;
    }

    final portions = int.tryParse(_portionsController.text) ?? 0;
    final costPerPortion = widget.costPerPortion ?? 50.0;
    final estimatedCost = portions * costPerPortion;

    // Create the result data to return
    final result = {
      'foodName': widget.foodItem,
      'foodId': widget.foodId,
      'portions': portions,
      'estimatedCost': estimatedCost,
    };

    Navigator.pop(context, result);
  }
}
