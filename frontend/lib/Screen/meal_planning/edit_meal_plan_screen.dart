import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/meal_plan/meal_plan_model.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan/dish_model.dart';

class EditMealPlanScreen extends StatefulWidget {
  final String groupId;
  final MealPlanModel mealPlan;

  const EditMealPlanScreen({
    Key? key,
    required this.groupId,
    required this.mealPlan,
  }) : super(key: key);

  @override
  _EditMealPlanScreenState createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends State<EditMealPlanScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Dish> _selectedDishes = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.mealPlan.name;
    _descriptionController.text = widget.mealPlan.description;
    _selectedTime = widget.mealPlan.scheduleTime;
    _selectedDishes.addAll(widget.mealPlan.dishes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal Plan'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Meal Time
            Row(
              children: [
                Text(
                  'Time: ${_selectedTime.toLocal().toString().substring(11, 16)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: const Text('Select Time'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Dish Button
            ElevatedButton(
              onPressed: _addDish,
              child: const Text('Add Dish'),
            ),
            const SizedBox(height: 16),

            // Dish List
            _selectedDishes.isEmpty
                ? const Text('No dishes added yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedDishes.length,
                    itemBuilder: (context, index) {
                      final dish = _selectedDishes[index];
                      return ListTile(
                        title: Text(dish.recipeName),
                        subtitle: Text('Servings: ${dish.servings}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() {
                            _selectedDishes.removeAt(index);
                          }),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _submitMealPlan,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addDish() async {
    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    try {
      final dishes = await provider.fetchAllRecipes(widget.groupId);
      Dish? selectedDish;
      final servingsController = TextEditingController();

      // Show dialog for adding a dish
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Dish'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Dish>(
                  items: dishes.map((dish) {
                    return DropdownMenuItem<Dish>(
                      value: dish,
                      child: Text(dish.recipeName),
                    );
                  }).toList(),
                  onChanged: (value) => selectedDish = value,
                  decoration: const InputDecoration(
                    labelText: 'Select Dish',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: servingsController,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedDish != null &&
                      servingsController.text.isNotEmpty) {
                    setState(() {
                      _selectedDishes.add(Dish(
                        recipeId: selectedDish!.recipeId,
                        recipeName: selectedDish!.recipeName,
                        servings: double.parse(servingsController.text),
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _submitMealPlan() async {
    if (_nameController.text.isEmpty || _selectedDishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final mealPlan = MealPlanModel(
      id: widget.mealPlan.id, // Keep the same ID for updating
      name: _nameController.text,
      description: _descriptionController.text,
      scheduleTime: _selectedTime,
      dishes: _selectedDishes,
    );

    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    try {
      await provider.updateMealPlan(mealPlan, widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal Plan Updated Successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
