import 'package:flutter/material.dart';

class EditMealPlanScreen extends StatefulWidget {
  final String mealType; // Loại bữa (sáng, trưa, tối, bữa phụ)
  final List<String> initialMeals; // Danh sách món ăn ban đầu

  const EditMealPlanScreen({
    Key? key,
    required this.mealType,
    required this.initialMeals,
  }) : super(key: key);

  @override
  State<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends State<EditMealPlanScreen> {
  late List<String> meals;
  final TextEditingController _mealController = TextEditingController();

  @override
  void initState() {
    super.initState();
    meals = List.from(widget.initialMeals); // Initialize meals from arguments
  }

  void _addMeal() {
    if (_mealController.text.isNotEmpty) {
      setState(() {
        meals.add(_mealController.text);
        _mealController.clear();
      });
    }
  }

  void _removeMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
  }

  void _saveMealPlan() {
    // Save updated meal plan (can pass back to provider or callback)
    Navigator.pop(context, meals); // Returning updated meals list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa ${widget.mealType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMealPlan,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _mealController,
              decoration: InputDecoration(
                labelText: 'Thêm món ăn',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMeal,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(meals[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeMeal(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}