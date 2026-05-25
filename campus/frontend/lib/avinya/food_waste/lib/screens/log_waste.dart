import 'package:flutter/material.dart';
import '../routing.dart';
import '../data/food_waste.dart';
import '../data/food_item.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/button.dart';
import 'select_food_screen.dart';

class LogWasteScreen extends StatefulWidget {
  final Map<String, dynamic>? logData;
  final VoidCallback? onSave;

  const LogWasteScreen({super.key, this.logData, this.onSave});

  @override
  State<LogWasteScreen> createState() => _LogWasteScreenState();
}

class _LogWasteScreenState extends State<LogWasteScreen> {
  DateTime _selectedDate = DateTime.now();
  String _mealType = 'Breakfast';
  final _peopleController = TextEditingController();
  final _notesController = TextEditingController();

  // List to track added waste items for today
  List<Map<String, dynamic>> _addedWasteItems = [];
  bool _isLoadingMealServings = true;
  int? _editingMealServingId; // Track if we're editing

  @override
  void initState() {
    super.initState();
    // Load meal servings after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.logData != null) {
        _loadExistingMealServing();
      } else {
        _loadTodaysMealServings();
      }
    });
  }

  Future<void> _loadExistingMealServing() async {
    try {
      // Parse existing meal serving data
      final serving = MealServing.fromJson(widget.logData!);

      setState(() {
        _editingMealServingId = serving.id;
        _selectedDate = DateTime.parse(serving.date);
        _mealType = serving.mealType.toLowerCase() == 'breakfast'
            ? 'Breakfast'
            : 'Lunch';
        _peopleController.text = serving.servedCount.toString();
        _notesController.text = serving.notes ?? '';

        // Load existing food waste items
        _addedWasteItems = serving.foodWastes
            .map((waste) => {
                  'foodWasteId': waste.id,
                  'foodId': waste.foodId,
                  'foodName': waste.foodItem.name,
                  'portions': waste.portions,
                  'estimatedCost':
                      waste.portions * waste.foodItem.costPerPortion,
                  'mealServingId': serving.id,
                })
            .toList();

        _isLoadingMealServings = false;
      });
    } catch (e) {
      setState(() => _isLoadingMealServings = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meal serving: $e')),
        );
      }
    }
  }

  int? _existingMealServingId;

  Future<void> _loadTodaysMealServings() async {
    print('Loading todays meal servings for date: $_selectedDate');
    try {
      // Format date as yyyy-MM-dd
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      print('Formatted date string: $dateStr');

      // Use the service instead of provider
      print('Calling MealServingService.fetchMealServings...');
      final mealServings = await MealServingService.fetchMealServings(
        organizationId: 2,
        offset: 0,
        limit: 100,
        fromDate: dateStr,
        toDate: dateStr,
      );
      print('Received ${mealServings.length} meal servings');

      setState(() {
        _addedWasteItems.clear();
        _existingMealServingId = null;

        // Filter meal servings by current meal type
        final filteredServings = mealServings
            .where((serving) =>
                serving.mealType.toLowerCase() == _mealType.toLowerCase())
            .toList();
        print(
            'Filtered to ${filteredServings.length} servings for meal type: $_mealType');

        // Convert meal servings to the format expected by the UI
        for (final serving in filteredServings) {
          _existingMealServingId = serving.id;

          for (final waste in serving.foodWastes) {
            _addedWasteItems.add({
              'foodName': waste.foodItem.name,
              'foodId': waste.foodItem.id,
              'portions': waste.portions,
              'estimatedCost': waste.portions * waste.foodItem.costPerPortion,
              'mealType': serving.mealType,
              'servedCount': serving.servedCount,
              'mealServingId': serving.id,
              'foodWasteId': waste.id,
            });
          }

          // Set the meal serving's details
          _peopleController.text = serving.servedCount.toString();
          _notesController.text = serving.notes ?? '';
        }

        // Clear fields if no data found for this meal type
        if (filteredServings.isEmpty) {
          _peopleController.clear();
          _notesController.clear();
        }

        _isLoadingMealServings = false;
        print('Loading completed successfully');
      });
    } catch (e) {
      print('Error in _loadTodaysMealServings: $e');
      setState(() {
        _isLoadingMealServings = false;
      });
      // Show error but don't block the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load existing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingMealServingId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoadingMealServings
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
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
                        Row(
                          children: [
                            if (isEditing) ...[
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
                            ],
                            Expanded(
                              child: PageTitle(
                                title:
                                    isEditing ? 'Edit Waste Log' : 'Food Waste',
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

                        // Date Selection Card
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
                              // Date Row
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _selectDate,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.blue[700],
                                                size: 20),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Date',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Meal Type Section
                              const Text('Meal Type',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF172B4D))),
                              const SizedBox(height: 12),
                              Row(
                                children: ['Breakfast', 'Lunch'].map((meal) {
                                  final isSelected = _mealType == meal;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: meal == 'Breakfast' ? 8 : 0,
                                        left: meal == 'Lunch' ? 8 : 0,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (!isSelected) {
                                            setState(() {
                                              _mealType = meal;
                                              _isLoadingMealServings = true;
                                            });
                                            _loadTodaysMealServings();
                                          }
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
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                              const SizedBox(height: 20),

                              // People Served
                              TextFormField(
                                controller: _peopleController,
                                decoration: InputDecoration(
                                  labelText: 'Total People Served *',
                                  hintText: 'Enter number of people served',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.people_outline,
                                      color: Colors.blue[700]),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Waste Items Section
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Waste Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF172B4D),
                                    ),
                                  ),
                                  Button(
                                    label: 'Add Wasted Item',
                                    onPressed: () async {
                                      final existingItems = <int, int>{};
                                      for (final item in _addedWasteItems) {
                                        if (item['foodId'] != null) {
                                          existingItems[item['foodId'] as int] =
                                              item['portions'] as int;
                                        }
                                      }

                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SelectFoodScreen(
                                            mealType: _mealType,
                                            existingItems: existingItems,
                                          ),
                                        ),
                                      );

                                      if (result != null &&
                                          result is Map<String, dynamic>) {
                                        await _addWasteItem(
                                          result['foodName'],
                                          result['portions'],
                                          result['estimatedCost'],
                                          foodId: result['foodId'],
                                        );
                                      }
                                    },
                                    buttonColor: Colors.blue[700],
                                    textColor: Colors.white,
                                    height: 40,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Waste Items Table
                              if (_addedWasteItems.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No waste items added yet',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Click "Add Wasted Item" to record food waste',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            topRight: Radius.circular(7),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 16),
                                        child: const Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: Text('Food Item',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13))),
                                            Expanded(
                                                flex: 2,
                                                child: Text('Portions',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                                    textAlign:
                                                        TextAlign.center)),
                                            Expanded(
                                                flex: 2,
                                                child: Text('Cost (LKR)',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                                    textAlign:
                                                        TextAlign.right)),
                                            SizedBox(width: 50),
                                          ],
                                        ),
                                      ),
                                      // Table Rows
                                      ...List.generate(_addedWasteItems.length,
                                          (index) {
                                        final item = _addedWasteItems[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  item['foodName'],
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${item['portions']}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${item['estimatedCost'].toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _handleDeleteWasteItem(
                                                          index),
                                                  icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 18),
                                                  color: Colors.red.shade400,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      // Total Row
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(7),
                                            bottomRight: Radius.circular(7),
                                          ),
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 16),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                                flex: 4,
                                                child: Text('Total:',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${_addedWasteItems.fold<int>(0, (sum, item) => sum + (item['portions'] as int))}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${_addedWasteItems.fold<double>(0, (sum, item) => sum + (item['estimatedCost'] as double)).toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red),
                                              ),
                                            ),
                                            const SizedBox(width: 50),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Notes Section
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
                                'Additional Notes',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Add any additional notes about this waste log...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                maxLines: 3,
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
                              onPressed: () {
                                if (ModalRoute.of(context)?.isFirst == true) {
                                  RouteStateScope.of(context)
                                      .go('/food_wastage_dashboard');
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              buttonColor: Colors.grey[100],
                              textColor: Colors.grey[800],
                              height: 40,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 16),
                            Button(
                              label: isEditing ? 'Update Log' : 'Save Log',
                              onPressed: _saveLog,
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

  Future<void> _handleDeleteWasteItem(int index) async {
    final item = _addedWasteItems[index];
    final foodWasteId = item['foodWasteId'] as int?;
    final foodName = item['foodName'] as String;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Waste Item'),
        content: Text(
            'Are you sure you want to delete "$foodName" from the waste log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If user cancelled, return early
    if (confirmed != true) return;

    // Just remove from local list. It will be removed from the server
    // when updating the MealServing.
    setState(() {
      _addedWasteItems.removeAt(index);
    });
  }

  Future<void> _addWasteItem(
      String foodName, int portions, double estimatedCost,
      {int? foodId}) async {
    // Just update locally. It will be saved when updating/creating the MealServing.
    setState(() {
      final existingIndex =
          _addedWasteItems.indexWhere((item) => item['foodId'] == foodId);
      if (existingIndex >= 0) {
        _addedWasteItems[existingIndex]['portions'] = portions;
        _addedWasteItems[existingIndex]['estimatedCost'] = estimatedCost;
      } else {
        _addedWasteItems.add({
          'foodName': foodName,
          'foodId': foodId,
          'portions': portions,
          'estimatedCost': estimatedCost,
        });
      }
    });
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _isLoadingMealServings = true;
      });
      _loadTodaysMealServings();
    }
  }

  Future<void> _saveLog() async {
    // Prevent multiple saves
    if (!mounted) return;

    // Validate people served field
    if (_peopleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter the number of people served')),
      );
      return;
    }

    final peopleServed = int.tryParse(_peopleController.text.trim());
    if (peopleServed == null || peopleServed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter a valid number of people served (greater than 0)')),
      );
      return;
    }

    try {
      // Format date
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // Map local items to FoodWaste objects
      final List<FoodWaste> foodWastes =
          _addedWasteItems.where((item) => item['foodId'] != null).map((item) {
        final foodId = item['foodId'] as int;
        return FoodWaste(
          id: item['foodWasteId'] as int?,
          foodId: foodId,
          portions: item['portions'] as int,
          foodItem: FoodItem(
            id: foodId,
            name: item['foodName'],
            costPerPortion:
                (item['estimatedCost'] as double) / (item['portions'] as int),
            mealType: _mealType,
          ),
        );
      }).toList();

      MealServing mealServing;

      if (_editingMealServingId != null) {
        // UPDATE MODE: Update existing meal serving
        mealServing = MealServing(
          id: _editingMealServingId,
          date: dateStr,
          mealType: _mealType.toLowerCase(),
          servedCount: peopleServed,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          foodWastes: foodWastes,
        );

        // Check if still mounted before each async operation
        if (!mounted) return;
        await MealServingService.updateMealServing(mealServing);
      } else {
        // CREATE MODE: Check if meal serving already exists for this date/meal type
        final existingMealServingId = _existingMealServingId ??
            (_addedWasteItems.isNotEmpty
                ? _addedWasteItems.first['mealServingId'] as int?
                : null);

        if (existingMealServingId != null) {
          // Update existing meal serving found from date
          mealServing = MealServing(
            id: existingMealServingId,
            date: dateStr,
            mealType: _mealType.toLowerCase(),
            servedCount: peopleServed,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            foodWastes: foodWastes,
          );
          if (!mounted) return;
          await MealServingService.updateMealServing(mealServing);
        } else {
          // Create new meal serving
          mealServing = MealServing(
            date: dateStr,
            mealType: _mealType.toLowerCase(),
            servedCount: peopleServed,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            foodWastes: foodWastes,
          );
          if (!mounted) return;
          await MealServingService.createMealServing(mealServing);
        }
      }

      // Add small delay to ensure database operation completes
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        widget.onSave?.call();

        if (widget.logData != null) {
          Navigator.pop(context);
        } else {
          // If we're on the main screen, just refresh the data to reflect changes
          _loadTodaysMealServings();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_editingMealServingId != null
                  ? 'Waste log updated!'
                  : 'Waste log saved!')),
        );
      }
    } catch (e) {
      // Log the error for debugging
      print('Error saving waste log: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }
}
