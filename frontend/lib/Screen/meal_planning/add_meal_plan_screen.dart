import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';
import '../../Models/meal_plan/meal_plan_model.dart';
import '../../Models/meal_plan/dish_model.dart';

class AddMealPlanScreen extends StatefulWidget {
  final String groupId;

  const AddMealPlanScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddMealPlanScreen> createState() => _AddMealPlanScreenState();
}

class _AddMealPlanScreenState extends State<AddMealPlanScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Dish> _selectedDishes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal Plan'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên bữa ăn
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả bữa ăn
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Thời gian bữa ăn
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

            // Thêm món ăn
            ElevatedButton(
              onPressed: _addDish,
              child: const Text('Add Dish'),
            ),
            const SizedBox(height: 16),

            // Danh sách món ăn
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

            // Lưu bữa ăn
            ElevatedButton(
              onPressed: _submitMealPlan,
              child: const Text('Save Meal Plan'),
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

      // Hiển thị dialog chọn món ăn
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
      id: DateTime.now().toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      scheduleTime: _selectedTime,
      dishes: _selectedDishes,
    );

    final provider = Provider.of<MealPlanProvider>(context, listen: false);
    try {
      await provider.addMealPlan(mealPlan, widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal Plan Added Successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
