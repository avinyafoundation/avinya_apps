import 'package:flutter/material.dart';
import '../data/food_item.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/button.dart';

class AddEditFoodScreen extends StatefulWidget {
  final int? id;
  final String? foodName;
  final double? cost;
  final String? mealType;

  const AddEditFoodScreen(
      {super.key, this.id, this.foodName, this.cost, this.mealType});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.foodName != null) {
      _nameController.text = widget.foodName!;
      _costController.text = widget.cost.toString();
    }

    if (widget.mealType != null) {
      _selectedMealType = widget.mealType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foodName != null;

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
                      Expanded(
                        child: PageTitle(
                          title: isEditing ? 'Edit Food Item' : 'Add Food Item',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF172B4D),
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

                  // Meal Type Selection
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
                          'Meal Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: ['Breakfast', 'Lunch'].map((meal) {
                            final isSelected = _selectedMealType == meal;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: meal == 'Breakfast' ? 8 : 0,
                                  left: meal == 'Lunch' ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedMealType = meal;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue[700]
                                          : Colors.grey[50],
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue[700]!
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          meal == 'Breakfast'
                                              ? Icons.free_breakfast
                                              : Icons.lunch_dining,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          meal,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[800],
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Food Item Details
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
                          'Food Item Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Item Name',
                            hintText: _selectedMealType == 'Breakfast'
                                ? 'e.g., Toast, Cereal, Eggs'
                                : 'e.g., Rice, Chicken Curry, Salad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.restaurant_menu,
                                color: Colors.blue[700]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _costController,
                          decoration: InputDecoration(
                            labelText: 'Estimated Cost per Portion (LKR)',
                            hintText: '0.00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.monetization_on_outlined,
                                color: Colors.blue[700]),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                        label: _isSaving
                            ? 'Saving...'
                            : (isEditing ? 'Update' : 'Save'),
                        onPressed: _isSaving ? () {} : _saveItem,
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

  void _saveItem() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food item name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    final mealType = _selectedMealType.toUpperCase();

    try {
      if (widget.foodName != null && widget.id != null) {
        // EDITING - update existing item
        final existingItem = FoodItem(
          id: widget.id!,
          name: name,
          costPerPortion: cost,
          mealType: mealType,
        );
        await FoodItemService.updateFoodItem(existingItem);
      } else {
        // CREATING NEW
        final newItem = FoodItem(
          name: name,
          costPerPortion: cost,
          mealType: mealType,
        );
        await FoodItemService.createFoodItem(newItem);
      }

      final action = widget.foodName != null ? 'updated' : 'added';
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$_selectedMealType food item "$name" $action successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving food item: $e')),
        );
      }
    }
  }
}
