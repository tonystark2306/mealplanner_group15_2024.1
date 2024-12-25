import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/meal_planning_provider.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({Key? key}) : super(key: key);

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanningProvider = Provider.of<MealPlanningProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kế hoạch bữa ăn',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white),
                  onPressed: () => _selectDate(context),
                  child: const Text('Chọn ngày'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                MealPlanSection(
                  title: 'Kế hoạch bữa sáng',
                  meals: mealPlanningProvider.getMealsForDateAndType(
                      selectedDate, 'breakfast'),
                  onEdit: () {
                    Navigator.pushNamed(context, '/edit-meal-plan', arguments: {
                      'mealType': 'breakfast',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(
                          selectedDate, 'breakfast'),
                    }).then((updatedMeals) {
                      if (updatedMeals != null) {
                        mealPlanningProvider.updateMealsForDateAndType(
                            selectedDate,
                            'breakfast',
                            updatedMeals as List<String>);
                      }
                    });
                  },
                ),
                MealPlanSection(
                  title: 'Kế hoạch bữa trưa',
                  meals: mealPlanningProvider.getMealsForDateAndType(
                      selectedDate, 'lunch'),
                  onEdit: () {
                    Navigator.pushNamed(context, '/edit-meal-plan', arguments: {
                      'mealType': 'lunch',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(
                          selectedDate, 'lunch'),
                    }).then((updatedMeals) {
                      if (updatedMeals != null) {
                        mealPlanningProvider.updateMealsForDateAndType(
                            selectedDate,
                            'lunch',
                            updatedMeals as List<String>);
                      }
                    });
                  },
                ),
                MealPlanSection(
                  title: 'Kế hoạch bữa tối',
                  meals: mealPlanningProvider.getMealsForDateAndType(
                      selectedDate, 'dinner'),
                  onEdit: () {
                    Navigator.pushNamed(context, '/edit-meal-plan', arguments: {
                      'mealType': 'dinner',
                      'date': selectedDate,
                      'meals': mealPlanningProvider.getMealsForDateAndType(
                          selectedDate, 'dinner'),
                    }).then((updatedMeals) {
                      if (updatedMeals != null) {
                        mealPlanningProvider.updateMealsForDateAndType(
                            selectedDate,
                            'dinner',
                            updatedMeals as List<String>);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // Thêm nút dấu cộng ở góc phải dưới
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pushNamed(context, '/edit-meal-plan', arguments: {
            'mealType': 'snack',
            'date': selectedDate,
            'meals': mealPlanningProvider.getMealsForDateAndType(
                selectedDate, 'snack'),
          }).then((updatedMeals) {
            if (updatedMeals != null) {
              mealPlanningProvider.updateMealsForDateAndType(
                  selectedDate, 'snack', updatedMeals as List<String>);
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class MealPlanSection extends StatelessWidget {
  final String title;
  final List<String> meals;
  final VoidCallback onEdit;

  const MealPlanSection({
    Key? key,
    required this.title,
    required this.meals,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 8),
            meals.isEmpty
                ? Text(
                    'Hiện tại chưa có món nào!',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meals.map((meal) => Text('- $meal')).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
